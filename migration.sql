--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.4

-- Started on 2022-12-28 14:30:13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS "openDB";
--
-- TOC entry 3339 (class 1262 OID 32833)
-- Name: openDB; Type: DATABASE; Schema: -; Owner: openDB
--

CREATE DATABASE "openDB" WITH TEMPLATE = template0 ENCODING = 'UTF8';


ALTER DATABASE "openDB" OWNER TO "openDB";

\connect "openDB"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 32891)
-- Name: databases; Type: SCHEMA; Schema: -; Owner: openDB
--

CREATE SCHEMA databases;


ALTER SCHEMA databases OWNER TO "openDB";

--
-- TOC entry 4 (class 2615 OID 32834)
-- Name: users; Type: SCHEMA; Schema: -; Owner: openDB
--

CREATE SCHEMA users;


ALTER SCHEMA users OWNER TO "openDB";

--
-- TOC entry 840 (class 1247 OID 32897)
-- Name: composite_database; Type: TYPE; Schema: databases; Owner: openDB
--

CREATE TYPE databases.composite_database AS (
	name character varying(256),
	unique_id character(15),
	user_id character(15),
	created date
);


ALTER TYPE databases.composite_database OWNER TO "openDB";

--
-- TOC entry 834 (class 1247 OID 32852)
-- Name: composite_user; Type: TYPE; Schema: users; Owner: openDB
--

CREATE TYPE users.composite_user AS (
	unique_id character(15),
	email character varying(256),
	username character varying(256),
	created date
);


ALTER TYPE users.composite_user OWNER TO "openDB";

--
-- TOC entry 221 (class 1255 OID 32865)
-- Name: assign_unique_id(); Type: FUNCTION; Schema: public; Owner: openDB
--

CREATE FUNCTION public.assign_unique_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.unique_id = users.alphanumeric();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.assign_unique_id() OWNER TO "openDB";

--
-- TOC entry 217 (class 1255 OID 32861)
-- Name: alphanumeric(integer); Type: FUNCTION; Schema: users; Owner: openDB
--

CREATE FUNCTION users.alphanumeric(size integer DEFAULT 15) RETURNS text
    LANGUAGE plpgsql
    AS $$DECLARE
    str varchar(25);
BEGIN
    SELECT substr(md5(random()::text), 0, size + 1) INTO str;
    RETURN str;
END;$$;


ALTER FUNCTION users.alphanumeric(size integer) OWNER TO "openDB";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 32880)
-- Name: basic; Type: TABLE; Schema: databases; Owner: openDB
--

CREATE TABLE databases.basic (
    name character varying(256) NOT NULL,
    id integer NOT NULL,
    unique_id character(15) NOT NULL,
    user_id integer NOT NULL,
    created date NOT NULL,
    deleted date
);


ALTER TABLE databases.basic OWNER TO "openDB";

--
-- TOC entry 214 (class 1259 OID 32879)
-- Name: databases_id_seq; Type: SEQUENCE; Schema: databases; Owner: openDB
--

ALTER TABLE databases.basic ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME databases.databases_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 211 (class 1259 OID 32835)
-- Name: basic; Type: TABLE; Schema: users; Owner: openDB
--

CREATE TABLE users.basic (
    id integer NOT NULL,
    full_name character varying(256),
    email character varying(256) NOT NULL,
    username character varying(15) NOT NULL,
    created date NOT NULL,
    deleted date,
    unique_id character(15) NOT NULL
);


ALTER TABLE users.basic OWNER TO "openDB";

--
-- TOC entry 212 (class 1259 OID 32840)
-- Name: basic_user_id_seq; Type: SEQUENCE; Schema: users; Owner: openDB
--

ALTER TABLE users.basic ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME users.basic_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 3189 (class 2606 OID 32884)
-- Name: basic databases_pkey; Type: CONSTRAINT; Schema: databases; Owner: openDB
--

ALTER TABLE ONLY databases.basic
    ADD CONSTRAINT databases_pkey PRIMARY KEY (id);


--
-- TOC entry 3191 (class 2606 OID 32894)
-- Name: basic id_unique; Type: CONSTRAINT; Schema: databases; Owner: openDB
--

ALTER TABLE ONLY databases.basic
    ADD CONSTRAINT id_unique UNIQUE (unique_id);


--
-- TOC entry 3183 (class 2606 OID 32842)
-- Name: basic basic_pkey; Type: CONSTRAINT; Schema: users; Owner: openDB
--

ALTER TABLE ONLY users.basic
    ADD CONSTRAINT basic_pkey PRIMARY KEY (id);


--
-- TOC entry 3185 (class 2606 OID 32874)
-- Name: basic email_username_uniques; Type: CONSTRAINT; Schema: users; Owner: openDB
--

ALTER TABLE ONLY users.basic
    ADD CONSTRAINT email_username_uniques UNIQUE (email, username);


--
-- TOC entry 3187 (class 2606 OID 32876)
-- Name: basic id_unique; Type: CONSTRAINT; Schema: users; Owner: openDB
--

ALTER TABLE ONLY users.basic
    ADD CONSTRAINT id_unique UNIQUE (unique_id);


--
-- TOC entry 3194 (class 2620 OID 32890)
-- Name: basic beforedatabasecreated; Type: TRIGGER; Schema: databases; Owner: openDB
--

CREATE TRIGGER beforedatabasecreated BEFORE INSERT ON databases.basic FOR EACH ROW EXECUTE FUNCTION public.assign_unique_id();


--
-- TOC entry 3193 (class 2620 OID 32866)
-- Name: basic beforeusercreated; Type: TRIGGER; Schema: users; Owner: openDB
--

CREATE TRIGGER beforeusercreated BEFORE INSERT ON users.basic FOR EACH ROW EXECUTE FUNCTION public.assign_unique_id();


--
-- TOC entry 3192 (class 2606 OID 32885)
-- Name: basic databases_user_id_fkey; Type: FK CONSTRAINT; Schema: databases; Owner: openDB
--

ALTER TABLE ONLY databases.basic
    ADD CONSTRAINT databases_user_id_fkey FOREIGN KEY (user_id) REFERENCES users.basic(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3340 (class 0 OID 0)
-- Dependencies: 3339
-- Name: DATABASE "openDB"; Type: ACL; Schema: -; Owner: openDB
--

REVOKE CONNECT,TEMPORARY ON DATABASE "openDB" FROM PUBLIC;
REVOKE ALL ON DATABASE "openDB" FROM "openDB";
GRANT CREATE,CONNECT ON DATABASE "openDB" TO "openDB";
GRANT TEMPORARY ON DATABASE "openDB" TO "openDB" WITH GRANT OPTION;


--
-- TOC entry 2042 (class 826 OID 32892)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: databases; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA databases GRANT ALL ON TABLES  TO "openDB";


-- Completed on 2022-12-28 14:30:13

--
-- PostgreSQL database dump complete
--

