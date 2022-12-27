--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.4

-- Started on 2022-12-27 18:43:39

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
-- TOC entry 3325 (class 1262 OID 32833)
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

CREATE SCHEMA "users";


ALTER SCHEMA "users" OWNER TO "openDB";

--
-- TOC entry 832 (class 1247 OID 32852)
-- Name: composite_user; Type: TYPE; Schema: users; Owner: openDB
--

CREATE TYPE "users"."composite_user" AS (
	"user_id" character varying(15),
	"email" character varying(256),
	"username" character varying(256),
	"created" "date"
);


ALTER TYPE "users"."composite_user" OWNER TO "openDB";

--
-- TOC entry 215 (class 1255 OID 32864)
-- Name: user_created_trigge(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."user_created_trigge"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.user_id = users.alphanumeric();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."user_created_trigge"() OWNER TO "postgres";

--
-- TOC entry 214 (class 1255 OID 32861)
-- Name: alphanumeric(integer); Type: FUNCTION; Schema: users; Owner: openDB
--

CREATE FUNCTION "users"."alphanumeric"("size" integer DEFAULT 15) RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$DECLARE
    str varchar(25);
BEGIN
    SELECT substr(md5(random()::text), 0, size) INTO str;
    RETURN str;
END;$$;


ALTER FUNCTION "users"."alphanumeric"("size" integer) OWNER TO "openDB";

--
-- TOC entry 216 (class 1255 OID 32865)
-- Name: assign_user_id(); Type: FUNCTION; Schema: users; Owner: postgres
--

CREATE FUNCTION "users"."assign_user_id"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.user_id = users.alphanumeric();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "users"."assign_user_id"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- TOC entry 213 (class 1259 OID 32853)
-- Name: composite_user; Type: TABLE; Schema: public; Owner: openDB
--

CREATE TABLE "public"."composite_user" (
    "user_id" integer,
    "email" character varying(256),
    "username" character varying(15),
    "created" "date"
);


ALTER TABLE "public"."composite_user" OWNER TO "openDB";

--
-- TOC entry 210 (class 1259 OID 32835)
-- Name: basic; Type: TABLE; Schema: users; Owner: openDB
--

CREATE TABLE "users"."basic" (
    "id" integer NOT NULL,
    "full_name" character varying(256),
    "email" character varying(256) NOT NULL,
    "username" character varying(15) NOT NULL,
    "created" "date" NOT NULL,
    "deleted" "date",
    "user_id" character varying(15) NOT NULL
);


ALTER TABLE "users"."basic" OWNER TO "openDB";

--
-- TOC entry 211 (class 1259 OID 32840)
-- Name: basic_user_id_seq; Type: SEQUENCE; Schema: users; Owner: openDB
--

ALTER TABLE "users"."basic" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "users"."basic_user_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 3177 (class 2606 OID 32842)
-- Name: basic basic_pkey; Type: CONSTRAINT; Schema: users; Owner: openDB
--

ALTER TABLE ONLY "users"."basic"
    ADD CONSTRAINT "basic_pkey" PRIMARY KEY ("id");


--
-- TOC entry 3179 (class 2606 OID 32846)
-- Name: basic username_email_unique; Type: CONSTRAINT; Schema: users; Owner: openDB
--

ALTER TABLE ONLY "users"."basic"
    ADD CONSTRAINT "username_email_unique" UNIQUE ("username", "email");


--
-- TOC entry 3180 (class 2620 OID 32866)
-- Name: basic beforeuserupdate; Type: TRIGGER; Schema: users; Owner: openDB
--

CREATE TRIGGER "beforeuserupdate" BEFORE INSERT ON "users"."basic" FOR EACH ROW EXECUTE FUNCTION "users"."assign_user_id"();


--
-- TOC entry 3326 (class 0 OID 0)
-- Dependencies: 3325
-- Name: DATABASE "openDB"; Type: ACL; Schema: -; Owner: openDB
--

REVOKE CONNECT,TEMPORARY ON DATABASE "openDB" FROM PUBLIC;
REVOKE ALL ON DATABASE "openDB" FROM "openDB";
GRANT CREATE,CONNECT ON DATABASE "openDB" TO "openDB";
GRANT TEMPORARY ON DATABASE "openDB" TO "openDB" WITH GRANT OPTION;


-- Completed on 2022-12-27 18:43:39

--
-- PostgreSQL database dump complete
--

