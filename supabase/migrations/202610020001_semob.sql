BEGIN;
CREATE TABLE IF NOT EXISTS semob_imports(id BIGSERIAL PRIMARY KEY,name TEXT NOT NULL,sha256 TEXT UNIQUE NOT NULL,created_at TIMESTAMPTZ NOT NULL,statistics JSONB NOT NULL);
CREATE TABLE IF NOT EXISTS semob_lines(code TEXT PRIMARY KEY,name TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS semob_vehicles(code TEXT PRIMARY KEY);
CREATE TABLE IF NOT EXISTS semob_operation_daily(day DATE PRIMARY KEY,fleet INTEGER,fleet_planned INTEGER,trips_planned INTEGER CHECK(trips_planned>=0),trips_completed INTEGER CHECK(trips_completed>=0),trips_missed INTEGER CHECK(trips_missed>=0),km_productive NUMERIC CHECK(km_productive>=0),km_unproductive NUMERIC CHECK(km_unproductive>=0),km_total NUMERIC CHECK(km_total>=0),priority INTEGER NOT NULL CHECK(priority IN (1,2)),source TEXT NOT NULL,import_id BIGINT NOT NULL REFERENCES semob_imports(id));
CREATE TABLE IF NOT EXISTS semob_passenger_daily(day DATE PRIMARY KEY,paid INTEGER,unpaid INTEGER,passengers INTEGER,cash_passengers INTEGER,prepaid_passengers INTEGER,priority INTEGER NOT NULL CHECK(priority IN (1,2)),source TEXT NOT NULL,import_id BIGINT NOT NULL REFERENCES semob_imports(id));
CREATE TABLE IF NOT EXISTS semob_finance_daily(day DATE PRIMARY KEY,sales NUMERIC,usage NUMERIC,circulating NUMERIC,priority INTEGER NOT NULL CHECK(priority IN (1,2)),source TEXT NOT NULL,import_id BIGINT NOT NULL REFERENCES semob_imports(id));
CREATE TABLE IF NOT EXISTS semob_line_daily(day DATE NOT NULL,line_code TEXT NOT NULL REFERENCES semob_lines(code),km_productive NUMERIC,trips_completed INTEGER,priority INTEGER NOT NULL,source TEXT NOT NULL,import_id BIGINT NOT NULL REFERENCES semob_imports(id),PRIMARY KEY(day,line_code));
CREATE TABLE IF NOT EXISTS semob_documents(id BIGSERIAL PRIMARY KEY,import_id BIGINT NOT NULL REFERENCES semob_imports(id),source TEXT NOT NULL,table_index INTEGER NOT NULL,sha256 TEXT NOT NULL,document JSONB NOT NULL,UNIQUE(import_id,source,table_index));
CREATE TABLE IF NOT EXISTS semob_trips(id BIGSERIAL PRIMARY KEY,import_id BIGINT NOT NULL REFERENCES semob_imports(id),day DATE NOT NULL,line_code TEXT REFERENCES semob_lines(code),vehicle_code TEXT REFERENCES semob_vehicles(code),priority INTEGER NOT NULL,source TEXT NOT NULL,start_time TEXT,km_productive NUMERIC,km_unproductive NUMERIC,document JSONB NOT NULL);
CREATE INDEX IF NOT EXISTS semob_trips_day_rank ON semob_trips(day,priority,import_id);
CREATE INDEX IF NOT EXISTS semob_trips_line ON semob_trips(line_code);

CREATE INDEX IF NOT EXISTS semob_documents_gin ON semob_documents USING gin(document jsonb_path_ops);
ALTER TABLE public.semob_imports ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.semob_imports FROM anon, authenticated;
ALTER TABLE public.semob_lines ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.semob_lines FROM anon, authenticated;
ALTER TABLE public.semob_vehicles ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.semob_vehicles FROM anon, authenticated;
ALTER TABLE public.semob_operation_daily ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.semob_operation_daily FROM anon, authenticated;
ALTER TABLE public.semob_passenger_daily ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.semob_passenger_daily FROM anon, authenticated;
ALTER TABLE public.semob_finance_daily ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.semob_finance_daily FROM anon, authenticated;
ALTER TABLE public.semob_line_daily ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.semob_line_daily FROM anon, authenticated;
ALTER TABLE public.semob_documents ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.semob_documents FROM anon, authenticated;
ALTER TABLE public.semob_trips ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.semob_trips FROM anon, authenticated;

COMMIT;

