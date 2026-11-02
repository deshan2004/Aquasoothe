-- ====================================================================
-- AquaSoothe Database Schema for Microsoft SQL Server (MS SQL)
-- Run this script in SQL Server Management Studio (SSMS) or Azure Data Studio
-- ====================================================================

-- 1. Create Database if it does not already exist
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'AquaSootheDB')
BEGIN
    CREATE DATABASE AquaSootheDB;
END
GO

USE AquaSootheDB;
GO

-- 2. Users Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        id NVARCHAR(100) PRIMARY KEY,
        name NVARCHAR(150) NOT NULL,
        email NVARCHAR(150) NOT NULL UNIQUE,
        password_hash NVARCHAR(255) NOT NULL,
        is_guest BIT DEFAULT 0,
        created_at DATETIME2 DEFAULT SYSUTCDATETIME()
    );
END
GO

-- 3. Hydration Goals Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'HydrationGoals')
BEGIN
    CREATE TABLE HydrationGoals (
        user_id NVARCHAR(100) PRIMARY KEY,
        daily_target_ml INT NOT NULL DEFAULT 2000,
        preferred_unit NVARCHAR(20) NOT NULL DEFAULT 'ml',
        reminder_interval_mins INT NOT NULL DEFAULT 60,
        updated_at DATETIME2 DEFAULT SYSUTCDATETIME(),
        FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
    );
END
GO

-- 4. Hydration Logs Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'HydrationLogs')
BEGIN
    CREATE TABLE HydrationLogs (
        id NVARCHAR(100) PRIMARY KEY,
        user_id NVARCHAR(100) NOT NULL,
        amount_ml INT NOT NULL,
        unit NVARCHAR(20) NOT NULL DEFAULT 'ml',
        logged_at DATETIME2 NOT NULL,
        created_at DATETIME2 DEFAULT SYSUTCDATETIME(),
        FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
    );
END
GO

-- 5. AI Custom Generated Sounds Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CustomSounds')
BEGIN
    CREATE TABLE CustomSounds (
        id NVARCHAR(100) PRIMARY KEY,
        user_id NVARCHAR(100) NOT NULL,
        title NVARCHAR(200) NOT NULL,
        description NVARCHAR(500) NULL,
        asset_path NVARCHAR(300) NOT NULL,
        icon_code INT NOT NULL DEFAULT 60219,
        category NVARCHAR(100) NOT NULL DEFAULT 'AI Custom',
        created_at DATETIME2 DEFAULT SYSUTCDATETIME(),
        FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
    );
END
GO

-- 6. Senior Medications Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Medications')
BEGIN
    CREATE TABLE Medications (
        id NVARCHAR(100) PRIMARY KEY,
        user_id NVARCHAR(100) NOT NULL,
        name NVARCHAR(200) NOT NULL,
        dosage NVARCHAR(100) NOT NULL,
        time NVARCHAR(50) NOT NULL,
        water_ml INT NOT NULL DEFAULT 250,
        is_taken_today BIT DEFAULT 0,
        last_taken_date DATETIME2 NULL,
        created_at DATETIME2 DEFAULT SYSUTCDATETIME(),
        FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
    );
END
GO

-- 7. Sleep Journal Logs Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SleepLogs')
BEGIN
    CREATE TABLE SleepLogs (
        id NVARCHAR(100) PRIMARY KEY,
        user_id NVARCHAR(100) NOT NULL,
        log_date DATE NOT NULL,
        rating NVARCHAR(50) NOT NULL,
        previous_day_water_ml INT NOT NULL DEFAULT 0,
        notes NVARCHAR(1000) NULL,
        logged_at DATETIME2 DEFAULT SYSUTCDATETIME(),
        FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
    );
END
GO

-- 8. Caregiver Settings Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'CaregiverSettings')
BEGIN
    CREATE TABLE CaregiverSettings (
        user_id NVARCHAR(100) PRIMARY KEY,
        is_enabled BIT DEFAULT 0,
        caregiver_name NVARCHAR(150) NULL,
        caregiver_phone NVARCHAR(50) NULL,
        invite_code NVARCHAR(50) NULL,
        cutoff_hour INT DEFAULT 20,
        cutoff_minute INT DEFAULT 0,
        updated_at DATETIME2 DEFAULT SYSUTCDATETIME(),
        FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
    );
END
GO

-- 9. Gentle Alarms Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Alarms')
BEGIN
    CREATE TABLE Alarms (
        user_id NVARCHAR(100) PRIMARY KEY,
        is_enabled BIT DEFAULT 1,
        hour INT DEFAULT 7,
        minute INT DEFAULT 0,
        sound_id NVARCHAR(100) DEFAULT 'gentle_brook',
        volume FLOAT DEFAULT 0.8,
        updated_at DATETIME2 DEFAULT SYSUTCDATETIME(),
        FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
    );
END
GO

PRINT 'AquaSoothe MS SQL Database Schema created successfully!';
