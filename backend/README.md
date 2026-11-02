# AquaSoothe MS SQL Backend

A secure REST API backend connecting Flutter to Microsoft SQL Server (MS SQL).

## 1. Prerequisites
- **Node.js**: v18+ (You already have Node installed!)
- **Microsoft SQL Server**: Running locally or via Docker or on a remote server.

### Running MS SQL Server via Docker (Quickest for Mac):
```bash
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=YourStrongPassword123!" \
   -p 1433:1433 --name aquasoothe-mssql --hostname mssql \
   -d mcr.microsoft.com/azure-sql-edge
```

## 2. Setup Database Schema
Open SQL Server Management Studio (SSMS), Azure Data Studio, or execute `schema.sql`:
```bash
sqlcmd -S localhost -U sa -P 'YourStrongPassword123!' -i schema.sql
```

## 3. Install Dependencies & Run
```bash
cd backend
npm install
npm start
```
The server will run on `http://localhost:5001`.

## 4. API Health Check
Test in browser or terminal:
```bash
curl http://localhost:5001/api/health
```
