--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.4

-- Started on 2022-12-27 11:57:42

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
-- TOC entry 3321 (class 1262 OID 32833)
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
-- TOC entry 4 (class 2615 OID 32834)
-- Name: users; Type: SCHEMA; Schema: -; Owner: openDB
--

CREATE SCHEMA users;


ALTER SCHEMA users OWNER TO "openDB";

--
-- TOC entry 829 (class 1247 OID 32852)
-- Name: composite_user; Type: TYPE; Schema: users; Owner: openDB
--

CREATE TYPE users.composite_user AS (
	user_id integer,
	email character varying(256),
	username character varying(256),
	created date
);


ALTER TYPE users.composite_user OWNER TO "openDB";

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 213 (class 1259 OID 32853)
-- Name: composite_user; Type: TABLE; Schema: public; Owner: openDB
--

CREATE TABLE public.composite_user (
    user_id integer,
    email character varying(256),
    username character varying(15),
    created date
);


ALTER TABLE public.composite_user OWNER TO "openDB";

--
-- TOC entry 210 (class 1259 OID 32835)
-- Name: basic; Type: TABLE; Schema: users; Owner: openDB
--

CREATE TABLE users.basic (
    user_id integer NOT NULL,
    full_name character varying(256) NOT NULL,
    email character varying(256) NOT NULL,
    username character varying(15) NOT NULL,
    created date NOT NULL,
    deleted date
);


ALTER TABLE users.basic OWNER TO "openDB";

--
-- TOC entry 211 (class 1259 OID 32840)
-- Name: basic_user_id_seq; Type: SEQUENCE; Schema: users; Owner: openDB
--

ALTER TABLE users.basic ALTER COLUMN user_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME users.basic_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 3174 (class 2606 OID 32842)
-- Name: basic basic_pkey; Type: CONSTRAINT; Schema: users; Owner: openDB
--

ALTER TABLE ONLY users.basic
    ADD CONSTRAINT basic_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3176 (class 2606 OID 32846)
-- Name: basic username_unique; Type: CONSTRAINT; Schema: users; Owner: openDB
--

ALTER TABLE ONLY users.basic
    ADD CONSTRAINT username_unique UNIQUE (username, email);


--
-- TOC entry 3322 (class 0 OID 0)
-- Dependencies: 3321
-- Name: DATABASE "openDB"; Type: ACL; Schema: -; Owner: openDB
--

REVOKE ALL ON DATABASE "openDB" FROM "openDB";
GRANT CREATE,CONNECT ON DATABASE "openDB" TO "openDB";
GRANT TEMPORARY ON DATABASE "openDB" TO "openDB" WITH GRANT OPTION;


-- Completed on 2022-12-27 11:57:43

--
-- PostgreSQL database dump complete
--

