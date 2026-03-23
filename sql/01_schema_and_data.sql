-- ============================================================
-- Oilfield Services: Field Operations & Equipment Performance
-- File 1: Schema Creation & Synthetic Data
-- ============================================================
-- Compatible with: PostgreSQL, MySQL 8+, SQLite (minor adjustments)
-- Run this file first before running analysis queries
-- ============================================================


-- ─────────────────────────────────────────
-- TABLE CREATION
-- ─────────────────────────────────────────

CREATE TABLE regions (
    region_id     INT PRIMARY KEY,
    region_name   VARCHAR(50),
    state         VARCHAR(20)
);

CREATE TABLE clients (
    client_id     INT PRIMARY KEY,
    client_name   VARCHAR(100),
    industry      VARCHAR(50)
);

CREATE TABLE wells (
    well_id       INT PRIMARY KEY,
    well_name     VARCHAR(100),
    client_id     INT REFERENCES clients(client_id),
    region_id     INT REFERENCES regions(region_id),
    well_type     VARCHAR(30),   -- 'Horizontal', 'Vertical', 'Directional'
    spud_date     DATE
);

CREATE TABLE equipment (
    equipment_id      INT PRIMARY KEY,
    equipment_name    VARCHAR(100),
    equipment_type    VARCHAR(50),  -- 'Drill Bit', 'Mud Pump', 'BHA', 'RSS', 'Casing Tool'
    manufacturer      VARCHAR(50),
    purchase_date     DATE,
    status            VARCHAR(20)   -- 'Active', 'Retired', 'In Repair'
);

CREATE TABLE technicians (
    technician_id   INT PRIMARY KEY,
    full_name       VARCHAR(100),
    role            VARCHAR(50),   -- 'Field Engineer', 'Directional Driller', 'Completion Tech'
    region_id       INT REFERENCES regions(region_id),
    hire_date       DATE,
    certification   VARCHAR(50)
);

CREATE TABLE service_jobs (
    job_id          INT PRIMARY KEY,
    well_id         INT REFERENCES wells(well_id),
    equipment_id    INT REFERENCES equipment(equipment_id),
    technician_id   INT REFERENCES technicians(technician_id),
    service_type    VARCHAR(50),   -- 'Drilling', 'Completion', 'Workover', 'Cementing'
    start_date      DATE,
    end_date        DATE,
    job_duration_days INT,
    revenue_usd     NUMERIC(12,2),
    job_rating      NUMERIC(3,1)   -- 1.0 to 5.0 client satisfaction score
);

CREATE TABLE maintenance_logs (
    log_id          INT PRIMARY KEY,
    equipment_id    INT REFERENCES equipment(equipment_id),
    log_date        DATE,
    event_type      VARCHAR(30),   -- 'Failure', 'Preventive', 'Inspection'
    failure_reason  VARCHAR(100),
    repair_cost_usd NUMERIC(10,2),
    downtime_days   INT,
    resolved_by     INT REFERENCES technicians(technician_id)
);


-- ─────────────────────────────────────────
-- SEED DATA: REGIONS
-- ─────────────────────────────────────────

INSERT INTO regions VALUES
(1, 'Permian Basin',  'Texas'),
(2, 'Eagle Ford',     'Texas'),
(3, 'Gulf Coast',     'Texas'),
(4, 'Haynesville',   'Texas'),
(5, 'Barnett Shale',  'Texas');


-- ─────────────────────────────────────────
-- SEED DATA: CLIENTS
-- ─────────────────────────────────────────

INSERT INTO clients VALUES
(1,  'Pioneer Energy Corp',      'E&P'),
(2,  'Lone Star Petroleum',      'E&P'),
(3,  'Gulf Meridian Resources',  'E&P'),
(4,  'Texaco Basin Partners',    'E&P'),
(5,  'Sabine River Oil Co',      'E&P'),
(6,  'Horizon Drilling Group',   'E&P'),
(7,  'Delta Crude Inc',          'E&P');


-- ─────────────────────────────────────────
-- SEED DATA: WELLS
-- ─────────────────────────────────────────

INSERT INTO wells VALUES
(1,  'Pioneer 14-A',       1, 1, 'Horizontal',   '2022-03-10'),
(2,  'Pioneer 22-B',       1, 1, 'Horizontal',   '2022-06-15'),
(3,  'Lone Star W-7',      2, 2, 'Directional',  '2022-04-01'),
(4,  'Lone Star W-9',      2, 2, 'Horizontal',   '2022-09-20'),
(5,  'Gulf Meridian GC-1', 3, 3, 'Vertical',     '2022-01-05'),
(6,  'Gulf Meridian GC-4', 3, 3, 'Horizontal',   '2022-11-12'),
(7,  'Texaco BP-3',        4, 4, 'Horizontal',   '2023-02-18'),
(8,  'Texaco BP-5',        4, 1, 'Directional',  '2023-05-07'),
(9,  'Sabine SR-11',       5, 2, 'Horizontal',   '2023-01-25'),
(10, 'Horizon DG-2',       6, 3, 'Vertical',     '2023-07-14'),
(11, 'Delta CR-6',         7, 5, 'Horizontal',   '2023-03-30'),
(12, 'Delta CR-8',         7, 5, 'Directional',  '2023-08-22');


-- ─────────────────────────────────────────
-- SEED DATA: EQUIPMENT
-- ─────────────────────────────────────────

INSERT INTO equipment VALUES
(1,  'Atlas PDC Bit 8.5"',      'Drill Bit',    'National Oilwell', '2021-06-01', 'Active'),
(2,  'Atlas PDC Bit 6.75"',     'Drill Bit',    'National Oilwell', '2021-09-15', 'Active'),
(3,  'Titan Mud Pump 1600HP',   'Mud Pump',     'Gardner Denver',   '2020-11-20', 'Active'),
(4,  'Titan Mud Pump 2000HP',   'Mud Pump',     'Gardner Denver',   '2021-03-08', 'In Repair'),
(5,  'Viper RSS MWD System',    'RSS',          'Schlumberger',     '2022-01-14', 'Active'),
(6,  'Cobra BHA Assembly',      'BHA',          'Weatherford',      '2021-07-30', 'Active'),
(7,  'FlexSteel Casing Tool A', 'Casing Tool',  'TenarisHydril',    '2022-04-05', 'Active'),
(8,  'FlexSteel Casing Tool B', 'Casing Tool',  'TenarisHydril',    '2022-08-19', 'Retired'),
(9,  'PowerPulse MWD Unit',     'MWD',          'Halliburton',      '2021-12-01', 'Active'),
(10, 'Centrifugal Separator X', 'Separator',    'MI Swaco',         '2020-05-15', 'Active');


-- ─────────────────────────────────────────
-- SEED DATA: TECHNICIANS
-- ─────────────────────────────────────────

INSERT INTO technicians VALUES
(1,  'Marcus Webb',     'Directional Driller',  1, '2019-04-01', 'IADC Certified'),
(2,  'Rosa Delgado',    'Field Engineer',        2, '2020-08-15', 'IWCF Well Control'),
(3,  'James Okafor',    'Completion Tech',       3, '2021-01-10', 'IADC Certified'),
(4,  'Priya Nair',      'Field Engineer',        1, '2020-03-22', 'IWCF Well Control'),
(5,  'Derrick Tran',    'Directional Driller',   4, '2018-11-05', 'IADC Certified'),
(6,  'Camille Bouchard', 'Completion Tech',      5, '2022-02-14', 'API Certified'),
(7,  'Kevin Osei',      'Field Engineer',        3, '2021-06-30', 'IWCF Well Control'),
(8,  'Anita Flores',    'Directional Driller',   2, '2019-09-17', 'IADC Certified');


-- ─────────────────────────────────────────
-- SEED DATA: SERVICE JOBS
-- ─────────────────────────────────────────

INSERT INTO service_jobs VALUES
(1,  1,  1,  1,  'Drilling',    '2023-01-05', '2023-01-19', 14, 38500.00,  4.5),
(2,  1,  5,  4,  'Completion',  '2023-02-01', '2023-02-22', 21, 62000.00,  4.8),
(3,  2,  2,  1,  'Drilling',    '2023-02-10', '2023-02-22', 12, 33000.00,  4.2),
(4,  3,  6,  2,  'Workover',    '2023-01-18', '2023-01-25', 7,  18500.00,  3.9),
(5,  4,  3,  8,  'Drilling',    '2023-03-01', '2023-03-16', 15, 41000.00,  4.6),
(6,  5,  7,  3,  'Completion',  '2023-03-10', '2023-04-01', 22, 58000.00,  4.3),
(7,  6,  9,  7,  'Cementing',   '2023-04-05', '2023-04-10', 5,  14000.00,  4.7),
(8,  7,  1,  5,  'Drilling',    '2023-04-12', '2023-04-29', 17, 46000.00,  4.1),
(9,  8,  6,  4,  'Workover',    '2023-05-01', '2023-05-09', 8,  22000.00,  4.0),
(10, 9,  2,  2,  'Drilling',    '2023-05-15', '2023-05-28', 13, 36000.00,  4.4),
(11, 10, 10, 3,  'Completion',  '2023-06-01', '2023-06-25', 24, 67000.00,  4.9),
(12, 11, 5,  6,  'Drilling',    '2023-06-10', '2023-06-24', 14, 39000.00,  4.2),
(13, 12, 7,  6,  'Cementing',   '2023-07-01', '2023-07-06', 5,  13500.00,  4.5),
(14, 1,  3,  1,  'Workover',    '2023-07-15', '2023-07-22', 7,  19500.00,  4.3),
(15, 3,  9,  8,  'Drilling',    '2023-08-01', '2023-08-18', 17, 47000.00,  4.6),
(16, 5,  1,  7,  'Completion',  '2023-08-20', '2023-09-12', 23, 64000.00,  4.7),
(17, 7,  6,  5,  'Drilling',    '2023-09-01', '2023-09-14', 13, 35500.00,  4.0),
(18, 9,  10, 2,  'Workover',    '2023-09-18', '2023-09-25', 7,  20000.00,  3.8),
(19, 11, 2,  6,  'Drilling',    '2023-10-01', '2023-10-15', 14, 38000.00,  4.3),
(20, 6,  5,  3,  'Completion',  '2023-10-20', '2023-11-10', 21, 59500.00,  4.8),
(21, 2,  9,  4,  'Cementing',   '2023-11-01', '2023-11-06', 5,  13000.00,  4.6),
(22, 4,  3,  8,  'Drilling',    '2023-11-10', '2023-11-25', 15, 42000.00,  4.4),
(23, 8,  7,  1,  'Completion',  '2023-12-01', '2023-12-22', 21, 57000.00,  4.5),
(24, 10, 6,  7,  'Workover',    '2023-12-05', '2023-12-12', 7,  21000.00,  4.2),
(25, 12, 1,  5,  'Drilling',    '2023-12-15', '2023-12-29', 14, 37500.00,  4.1);


-- ─────────────────────────────────────────
-- SEED DATA: MAINTENANCE LOGS
-- ─────────────────────────────────────────

INSERT INTO maintenance_logs VALUES
(1,  1,  '2023-02-14', 'Failure',    'PDC cutter wear beyond spec',       4200.00,  3, 1),
(2,  3,  '2023-03-22', 'Failure',    'Liner seal failure',                7800.00,  5, 4),
(3,  5,  '2023-04-01', 'Preventive', NULL,                                1200.00,  1, 5),
(4,  2,  '2023-04-18', 'Failure',    'Nozzle blockage',                   2100.00,  2, 8),
(5,  6,  '2023-05-10', 'Inspection', NULL,                                 500.00,  0, 2),
(6,  1,  '2023-05-30', 'Failure',    'Bearing overheating',               3500.00,  2, 1),
(7,  4,  '2023-06-05', 'Failure',    'Crankshaft seal leak',              9200.00,  7, 4),
(8,  9,  '2023-06-20', 'Preventive', NULL,                                1500.00,  1, 7),
(9,  3,  '2023-07-08', 'Failure',    'Valve seat erosion',                6100.00,  4, 4),
(10, 7,  '2023-07-25', 'Inspection', NULL,                                 400.00,  0, 3),
(11, 2,  '2023-08-12', 'Failure',    'PDC cutter wear beyond spec',       2800.00,  2, 8),
(12, 5,  '2023-08-28', 'Failure',    'Shock tool malfunction',            5500.00,  3, 5),
(13, 10, '2023-09-05', 'Preventive', NULL,                                 900.00,  1, 3),
(14, 1,  '2023-09-18', 'Failure',    'Formation damage - abrasion',       3100.00,  2, 1),
(15, 6,  '2023-10-02', 'Failure',    'MWD communication dropout',         4800.00,  3, 2),
(16, 3,  '2023-10-20', 'Failure',    'Liner seal failure',                7200.00,  5, 4),
(17, 9,  '2023-11-07', 'Failure',    'Pulser membrane failure',           3900.00,  2, 7),
(18, 2,  '2023-11-22', 'Preventive', NULL,                                1100.00,  1, 8),
(19, 5,  '2023-12-01', 'Failure',    'Bearing overheating',               5200.00,  3, 5),
(20, 7,  '2023-12-18', 'Inspection', NULL,                                 350.00,  0, 3);
