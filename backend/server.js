const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const { sql, getPool } = require('./db');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5001;

app.use(cors());
app.use(express.json());

// ---------------------------------------------------------
// 1. Health Check
// ---------------------------------------------------------
app.get('/api/health', async (req, res) => {
  try {
    const pool = await getPool();
    const result = await pool.request().query('SELECT GETDATE() AS serverTime');
    res.json({
      status: 'online',
      database: 'Microsoft SQL Server',
      serverTime: result.recordset[0].serverTime,
    });
  } catch (err) {
    res.status(500).json({
      status: 'error',
      message: 'MS SQL Server not connected',
      error: err.message,
    });
  }
});

// ---------------------------------------------------------
// 2. Authentication Endpoints
// ---------------------------------------------------------
app.post('/api/auth/signup', async (req, res) => {
  const { id, name, email, password } = req.body;
  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Name, email, and password are required' });
  }

  const cleanEmail = email.trim().toLowerCase();
  const userId = id || `user_${Date.now()}`;

  try {
    const pool = await getPool();

    // Check if user exists
    const existing = await pool
      .request()
      .input('email', sql.NVarChar, cleanEmail)
      .query('SELECT id FROM Users WHERE email = @email');

    if (existing.recordset.length > 0) {
      return res.status(409).json({ error: 'Account with this email already exists' });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    await pool
      .request()
      .input('id', sql.NVarChar, userId)
      .input('name', sql.NVarChar, name.trim())
      .input('email', sql.NVarChar, cleanEmail)
      .input('password_hash', sql.NVarChar, passwordHash)
      .input('is_guest', sql.Bit, 0)
      .query(`
        INSERT INTO Users (id, name, email, password_hash, is_guest)
        VALUES (@id, @name, @email, @password_hash, @is_guest)
      `);

    res.status(201).json({
      id: userId,
      name: name.trim(),
      email: cleanEmail,
      isGuest: false,
      createdAt: new Date().toISOString(),
    });
  } catch (err) {
    console.error('Signup error:', err);
    res.status(500).json({ error: 'Database signup error', details: err.message });
  }
});

app.post('/api/auth/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const cleanEmail = email.trim().toLowerCase();

  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('email', sql.NVarChar, cleanEmail)
      .query('SELECT * FROM Users WHERE email = @email');

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Account not found. Please sign up.' });
    }

    const user = result.recordset[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: 'Incorrect password. Please try again.' });
    }

    res.json({
      id: user.id,
      name: user.name,
      email: user.email,
      isGuest: Boolean(user.is_guest),
      createdAt: user.created_at,
    });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Database login error', details: err.message });
  }
});

app.post('/api/auth/guest', async (req, res) => {
  const guestId = `guest_${Date.now()}`;
  try {
    const pool = await getPool();
    await pool
      .request()
      .input('id', sql.NVarChar, guestId)
      .input('name', sql.NVarChar, 'Guest User')
      .input('email', sql.NVarChar, `${guestId}@aquasoothe.app`)
      .input('password_hash', sql.NVarChar, 'guest_none')
      .input('is_guest', sql.Bit, 1)
      .query(`
        INSERT INTO Users (id, name, email, password_hash, is_guest)
        VALUES (@id, @name, @email, @password_hash, @is_guest)
      `);

    res.json({
      id: guestId,
      name: 'Guest User',
      email: `${guestId}@aquasoothe.app`,
      isGuest: true,
      createdAt: new Date().toISOString(),
    });
  } catch (err) {
    console.error('Guest error:', err);
    res.status(500).json({ error: 'Database guest creation error', details: err.message });
  }
});

// ---------------------------------------------------------
// 3. Hydration Endpoints
// ---------------------------------------------------------
app.get('/api/hydration/goal', async (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'userId is required' });

  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('user_id', sql.NVarChar, userId)
      .query('SELECT * FROM HydrationGoals WHERE user_id = @user_id');

    if (result.recordset.length === 0) {
      return res.json({ dailyTargetMl: 2000, preferredUnit: 'ml', reminderIntervalMinutes: 60 });
    }

    const row = result.recordset[0];
    res.json({
      dailyTargetMl: row.daily_target_ml,
      preferredUnit: row.preferred_unit,
      reminderIntervalMinutes: row.reminder_interval_mins,
    });
  } catch (err) {
    res.status(500).json({ error: 'Error fetching goal', details: err.message });
  }
});

app.post('/api/hydration/goal', async (req, res) => {
  const { userId, dailyTargetMl, preferredUnit, reminderIntervalMinutes } = req.body;
  if (!userId) return res.status(400).json({ error: 'userId is required' });

  try {
    const pool = await getPool();
    await pool
      .request()
      .input('user_id', sql.NVarChar, userId)
      .input('daily_target_ml', sql.Int, dailyTargetMl || 2000)
      .input('preferred_unit', sql.NVarChar, preferredUnit || 'ml')
      .input('reminder_interval_mins', sql.Int, reminderIntervalMinutes || 60)
      .query(`
        MERGE HydrationGoals AS target
        USING (SELECT @user_id AS user_id) AS source
        ON (target.user_id = source.user_id)
        WHEN MATCHED THEN
          UPDATE SET daily_target_ml = @daily_target_ml,
                     preferred_unit = @preferred_unit,
                     reminder_interval_mins = @reminder_interval_mins,
                     updated_at = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN
          INSERT (user_id, daily_target_ml, preferred_unit, reminder_interval_mins)
          VALUES (@user_id, @daily_target_ml, @preferred_unit, @reminder_interval_mins);
      `);

    res.json({ success: true, message: 'Hydration goal saved' });
  } catch (err) {
    res.status(500).json({ error: 'Error saving goal', details: err.message });
  }
});

app.get('/api/hydration/logs', async (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'userId is required' });

  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('user_id', sql.NVarChar, userId)
      .query('SELECT * FROM HydrationLogs WHERE user_id = @user_id ORDER BY logged_at DESC');

    const logs = result.recordset.map((r) => ({
      id: r.id,
      amountMl: r.amount_ml,
      unit: r.unit,
      timestamp: r.logged_at,
    }));

    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: 'Error fetching hydration logs', details: err.message });
  }
});

app.post('/api/hydration/logs', async (req, res) => {
  const { id, userId, amountMl, unit, timestamp } = req.body;
  if (!userId || !amountMl) return res.status(400).json({ error: 'userId and amountMl are required' });

  const logId = id || `log_${Date.now()}`;
  const loggedAt = timestamp ? new Date(timestamp) : new Date();

  try {
    const pool = await getPool();
    await pool
      .request()
      .input('id', sql.NVarChar, logId)
      .input('user_id', sql.NVarChar, userId)
      .input('amount_ml', sql.Int, amountMl)
      .input('unit', sql.NVarChar, unit || 'ml')
      .input('logged_at', sql.DateTime2, loggedAt)
      .query(`
        INSERT INTO HydrationLogs (id, user_id, amount_ml, unit, logged_at)
        VALUES (@id, @user_id, @amount_ml, @unit, @logged_at)
      `);

    res.status(201).json({ id: logId, amountMl, unit: unit || 'ml', timestamp: loggedAt.toISOString() });
  } catch (err) {
    res.status(500).json({ error: 'Error adding hydration log', details: err.message });
  }
});

app.delete('/api/hydration/logs', async (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'userId is required' });

  try {
    const pool = await getPool();
    await pool
      .request()
      .input('user_id', sql.NVarChar, userId)
      .query('DELETE FROM HydrationLogs WHERE user_id = @user_id');

    res.json({ success: true, message: 'Logs cleared' });
  } catch (err) {
    res.status(500).json({ error: 'Error clearing hydration logs', details: err.message });
  }
});

// ---------------------------------------------------------
// 4. Custom Sounds Endpoints
// ---------------------------------------------------------
app.get('/api/sounds', async (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'userId is required' });

  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('user_id', sql.NVarChar, userId)
      .query('SELECT * FROM CustomSounds WHERE user_id = @user_id ORDER BY created_at DESC');

    const sounds = result.recordset.map((r) => ({
      id: r.id,
      title: r.title,
      description: r.description,
      assetPath: r.asset_path,
      iconCode: r.icon_code,
      category: r.category,
    }));

    res.json(sounds);
  } catch (err) {
    res.status(500).json({ error: 'Error fetching sounds', details: err.message });
  }
});

app.post('/api/sounds', async (req, res) => {
  const { id, userId, title, description, assetPath, iconCode, category } = req.body;
  if (!userId || !title || !assetPath) {
    return res.status(400).json({ error: 'userId, title, and assetPath are required' });
  }

  const soundId = id || `sound_${Date.now()}`;

  try {
    const pool = await getPool();
    await pool
      .request()
      .input('id', sql.NVarChar, soundId)
      .input('user_id', sql.NVarChar, userId)
      .input('title', sql.NVarChar, title)
      .input('description', sql.NVarChar, description || '')
      .input('asset_path', sql.NVarChar, assetPath)
      .input('icon_code', sql.Int, iconCode || 60219)
      .input('category', sql.NVarChar, category || 'AI Custom')
      .query(`
        INSERT INTO CustomSounds (id, user_id, title, description, asset_path, icon_code, category)
        VALUES (@id, @user_id, @title, @description, @asset_path, @icon_code, @category)
      `);

    res.status(201).json({ success: true, id: soundId });
  } catch (err) {
    res.status(500).json({ error: 'Error saving custom sound', details: err.message });
  }
});

app.delete('/api/sounds/:id', async (req, res) => {
  const soundId = req.params.id;
  const userId = req.query.userId;
  if (!userId || !soundId) return res.status(400).json({ error: 'userId and soundId are required' });

  try {
    const pool = await getPool();
    await pool
      .request()
      .input('id', sql.NVarChar, soundId)
      .input('user_id', sql.NVarChar, userId)
      .query('DELETE FROM CustomSounds WHERE id = @id AND user_id = @user_id');

    res.json({ success: true, message: 'Sound deleted' });
  } catch (err) {
    res.status(500).json({ error: 'Error deleting sound', details: err.message });
  }
});

// ---------------------------------------------------------
// 5. Senior Medications Endpoints
// ---------------------------------------------------------
app.get('/api/medications', async (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'userId is required' });

  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('user_id', sql.NVarChar, userId)
      .query('SELECT * FROM Medications WHERE user_id = @user_id ORDER BY time ASC');

    const meds = result.recordset.map((r) => ({
      id: r.id,
      name: r.name,
      dosage: r.dosage,
      time: r.time,
      waterMl: r.water_ml,
      isTakenToday: Boolean(r.is_taken_today),
      lastTakenDate: r.last_taken_date,
    }));

    res.json(meds);
  } catch (err) {
    res.status(500).json({ error: 'Error fetching medications', details: err.message });
  }
});

app.post('/api/medications', async (req, res) => {
  const { userId, items } = req.body;
  if (!userId || !Array.isArray(items)) {
    return res.status(400).json({ error: 'userId and items array are required' });
  }

  try {
    const pool = await getPool();
    const transaction = new sql.Transaction(pool);
    await transaction.begin();

    // Clear existing for user and reinsert
    await transaction
      .request()
      .input('user_id', sql.NVarChar, userId)
      .query('DELETE FROM Medications WHERE user_id = @user_id');

    for (const m of items) {
      await transaction
        .request()
        .input('id', sql.NVarChar, m.id || `med_${Date.now()}_${Math.random()}`)
        .input('user_id', sql.NVarChar, userId)
        .input('name', sql.NVarChar, m.name)
        .input('dosage', sql.NVarChar, m.dosage || '')
        .input('time', sql.NVarChar, m.time || '')
        .input('water_ml', sql.Int, m.waterMl || 250)
        .input('is_taken_today', sql.Bit, m.isTakenToday ? 1 : 0)
        .input('last_taken_date', sql.DateTime2, m.lastTakenDate ? new Date(m.lastTakenDate) : null)
        .query(`
          INSERT INTO Medications (id, user_id, name, dosage, time, water_ml, is_taken_today, last_taken_date)
          VALUES (@id, @user_id, @name, @dosage, @time, @water_ml, @is_taken_today, @last_taken_date)
        `);
    }

    await transaction.commit();
    res.json({ success: true, message: 'Medications saved' });
  } catch (err) {
    res.status(500).json({ error: 'Error saving medications', details: err.message });
  }
});

// ---------------------------------------------------------
// 6. Sleep Journal Endpoints
// ---------------------------------------------------------
app.get('/api/sleep', async (req, res) => {
  const userId = req.query.userId;
  if (!userId) return res.status(400).json({ error: 'userId is required' });

  try {
    const pool = await getPool();
    const result = await pool
      .request()
      .input('user_id', sql.NVarChar, userId)
      .query('SELECT * FROM SleepLogs WHERE user_id = @user_id ORDER BY log_date DESC');

    const logs = result.recordset.map((r) => ({
      id: r.id,
      date: r.log_date,
      rating: r.rating,
      previousDayWaterMl: r.previous_day_water_ml,
      notes: r.notes,
    }));

    res.json(logs);
  } catch (err) {
    res.status(500).json({ error: 'Error fetching sleep logs', details: err.message });
  }
});

app.post('/api/sleep', async (req, res) => {
  const { id, userId, date, rating, previousDayWaterMl, notes } = req.body;
  if (!userId || !rating) return res.status(400).json({ error: 'userId and rating are required' });

  const sleepId = id || `sleep_${Date.now()}`;
  const logDate = date ? new Date(date) : new Date();

  try {
    const pool = await getPool();
    await pool
      .request()
      .input('id', sql.NVarChar, sleepId)
      .input('user_id', sql.NVarChar, userId)
      .input('log_date', sql.Date, logDate)
      .input('rating', sql.NVarChar, rating)
      .input('previous_day_water_ml', sql.Int, previousDayWaterMl || 0)
      .input('notes', sql.NVarChar, notes || '')
      .query(`
        INSERT INTO SleepLogs (id, user_id, log_date, rating, previous_day_water_ml, notes)
        VALUES (@id, @user_id, @log_date, @rating, @previous_day_water_ml, @notes)
      `);

    res.status(201).json({ success: true, id: sleepId });
  } catch (err) {
    res.status(500).json({ error: 'Error logging sleep', details: err.message });
  }
});

// Start Server
app.listen(PORT, () => {
  console.log(`[AquaSoothe API] Server listening on http://localhost:${PORT}`);
});
