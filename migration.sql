--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.4

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

DROP DATABASE "openDB";
--
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
-- Name: databases; Type: SCHEMA; Schema: -; Owner: openDB
--

CREATE SCHEMA databases;


ALTER SCHEMA databases OWNER TO "openDB";

--
-- Name: permissions; Type: SCHEMA; Schema: -; Owner: openDB
--

CREATE SCHEMA permissions;


ALTER SCHEMA permissions OWNER TO "openDB";

--
-- Name: users; Type: SCHEMA; Schema: -; Owner: openDB
--

CREATE SCHEMA users;


ALTER SCHEMA users OWNER TO "openDB";

--
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
-- Name: databases; Type: TABLE; Schema: permissions; Owner: openDB
--

CREATE TABLE permissions.databases (
    id integer NOT NULL,
    user_id integer NOT NULL,
    database_id integer NOT NULL,
    permissions character(3) DEFAULT 'xxx'::bpchar NOT NULL
);


ALTER TABLE permissions.databases OWNER TO "openDB";

--
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
-- Name: basic databases_pkey; Type: CONSTRAINT; Schema: databases; Owner: openDB
--

ALTER TABLE ONLY databases.basic
    ADD CONSTRAINT databases_pkey PRIMARY KEY (id);


--
-- Name: basic id_unique; Type: CONSTRAINT; Schema: databases; Owner: openDB
--

ALTER TABLE ONLY databases.basic
    ADD CONSTRAINT id_unique UNIQUE (unique_id);


--
-- Name: databases databases_pkey; Type: CONSTRAINT; Schema: permissions; Owner: openDB
--

ALTER TABLE ONLY permissions.databases
    ADD CONSTRAINT databases_pkey PRIMARY KEY (id);


--
-- Name: basic basic_pkey; Type: CONSTRAINT; Schema: users; Owner: openDB
--

ALTER TABLE ONLY users.basic
    ADD CONSTRAINT basic_pkey PRIMARY KEY (id);


--
-- Name: basic email_username_uniques; Type: CONSTRAINT; Schema: users; Owner: openDB
--

ALTER TABLE ONLY users.basic
    ADD CONSTRAINT email_username_uniques UNIQUE (email, username);


--
-- Name: basic id_unique; Type: CONSTRAINT; Schema: users; Owner: openDB
--

ALTER TABLE ONLY users.basic
    ADD CONSTRAINT id_unique UNIQUE (unique_id);


--
-- Name: basic beforedatabasecreated; Type: TRIGGER; Schema: databases; Owner: openDB
--

CREATE TRIGGER beforedatabasecreated BEFORE INSERT ON databases.basic FOR EACH ROW EXECUTE FUNCTION public.assign_unique_id();


--
-- Name: basic beforeusercreated; Type: TRIGGER; Schema: users; Owner: openDB
--

CREATE TRIGGER beforeusercreated BEFORE INSERT ON users.basic FOR EACH ROW EXECUTE FUNCTION public.assign_unique_id();


--
-- Name: basic databases_user_id_fkey; Type: FK CONSTRAINT; Schema: databases; Owner: openDB
--

ALTER TABLE ONLY databases.basic
    ADD CONSTRAINT databases_user_id_fkey FOREIGN KEY (user_id) REFERENCES users.basic(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: databases permissions_database_id_fkey; Type: FK CONSTRAINT; Schema: permissions; Owner: openDB
--

ALTER TABLE ONLY permissions.databases
    ADD CONSTRAINT permissions_database_id_fkey FOREIGN KEY (database_id) REFERENCES databases.basic(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: databases permissions_user_id_fkey; Type: FK CONSTRAINT; Schema: permissions; Owner: openDB
--

ALTER TABLE ONLY permissions.databases
    ADD CONSTRAINT permissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES users.basic(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: DATABASE "openDB"; Type: ACL; Schema: -; Owner: openDB
--

REVOKE CONNECT,TEMPORARY ON DATABASE "openDB" FROM PUBLIC;
REVOKE ALL ON DATABASE "openDB" FROM "openDB";
GRANT CREATE,CONNECT ON DATABASE "openDB" TO "openDB";
GRANT TEMPORARY ON DATABASE "openDB" TO "openDB" WITH GRANT OPTION;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: openDB
--

REVOKE ALL ON SCHEMA public FROM postgres;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO "openDB";
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

