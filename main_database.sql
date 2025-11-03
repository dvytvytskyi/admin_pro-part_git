--
-- PostgreSQL database dump
--

\restrict ZKc0HVN5alacYfjtbFZivdZbISJihwSyAvXr4KOEsz3yFDPdzeXzdb8riin2aRQ

-- Dumped from database version 15.14 (Debian 15.14-1.pgdg13+1)
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg13+1)

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: course_contents_type_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.course_contents_type_enum AS ENUM (
    'text',
    'image',
    'video'
);


ALTER TYPE public.course_contents_type_enum OWNER TO admin;

--
-- Name: news_contents_type_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.news_contents_type_enum AS ENUM (
    'text',
    'image',
    'video'
);


ALTER TYPE public.news_contents_type_enum OWNER TO admin;

--
-- Name: properties_propertytype_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.properties_propertytype_enum AS ENUM (
    'off-plan',
    'secondary'
);


ALTER TYPE public.properties_propertytype_enum OWNER TO admin;

--
-- Name: property_units_type_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.property_units_type_enum AS ENUM (
    'apartment',
    'villa',
    'penthouse',
    'townhouse',
    'office'
);


ALTER TYPE public.property_units_type_enum OWNER TO admin;

--
-- Name: support_requests_status_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.support_requests_status_enum AS ENUM (
    'pending',
    'in-progress',
    'resolved',
    'closed'
);


ALTER TYPE public.support_requests_status_enum OWNER TO admin;

--
-- Name: users_role_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.users_role_enum AS ENUM (
    'CLIENT',
    'BROKER',
    'INVESTOR',
    'ADMIN'
);


ALTER TYPE public.users_role_enum OWNER TO admin;

--
-- Name: users_status_enum; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.users_status_enum AS ENUM (
    'PENDING',
    'ACTIVE',
    'BLOCKED',
    'REJECTED'
);


ALTER TYPE public.users_status_enum OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.api_keys (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    "apiKey" character varying(255) NOT NULL,
    "apiSecret" text NOT NULL,
    name character varying(255),
    "isActive" boolean DEFAULT true NOT NULL,
    "lastUsedAt" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.api_keys OWNER TO admin;

--
-- Name: areas; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.areas (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "cityId" uuid NOT NULL,
    "nameEn" character varying NOT NULL,
    "nameRu" character varying NOT NULL,
    "nameAr" character varying NOT NULL
);


ALTER TABLE public.areas OWNER TO admin;

--
-- Name: cities; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.cities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "countryId" uuid NOT NULL,
    "nameEn" character varying NOT NULL,
    "nameRu" character varying NOT NULL,
    "nameAr" character varying NOT NULL
);


ALTER TABLE public.cities OWNER TO admin;

--
-- Name: countries; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.countries (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "nameEn" character varying NOT NULL,
    "nameRu" character varying NOT NULL,
    "nameAr" character varying NOT NULL,
    code character varying NOT NULL
);


ALTER TABLE public.countries OWNER TO admin;

--
-- Name: course_contents; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.course_contents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "courseId" uuid NOT NULL,
    type public.course_contents_type_enum NOT NULL,
    title character varying NOT NULL,
    description text,
    "imageUrl" character varying,
    "videoUrl" character varying,
    "order" integer NOT NULL
);


ALTER TABLE public.course_contents OWNER TO admin;

--
-- Name: course_links; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.course_links (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "courseId" uuid NOT NULL,
    title character varying NOT NULL,
    url character varying NOT NULL,
    "order" integer NOT NULL
);


ALTER TABLE public.course_links OWNER TO admin;

--
-- Name: courses; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.courses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    "order" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.courses OWNER TO admin;

--
-- Name: developers; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.developers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying NOT NULL,
    logo character varying,
    description text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.developers OWNER TO admin;

--
-- Name: facilities; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.facilities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "nameEn" character varying NOT NULL,
    "nameRu" character varying NOT NULL,
    "nameAr" character varying NOT NULL,
    "iconName" character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.facilities OWNER TO admin;

--
-- Name: news; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.news (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    "imageUrl" character varying,
    "isPublished" boolean DEFAULT false NOT NULL,
    "publishedAt" timestamp with time zone,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.news OWNER TO admin;

--
-- Name: news_contents; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.news_contents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "newsId" uuid NOT NULL,
    type public.news_contents_type_enum NOT NULL,
    title character varying NOT NULL,
    description text,
    "imageUrl" character varying,
    "videoUrl" character varying,
    "order" integer NOT NULL
);


ALTER TABLE public.news_contents OWNER TO admin;

--
-- Name: properties; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.properties (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "propertyType" public.properties_propertytype_enum NOT NULL,
    name character varying NOT NULL,
    photos text NOT NULL,
    "countryId" uuid NOT NULL,
    "cityId" uuid NOT NULL,
    "areaId" uuid NOT NULL,
    latitude numeric(10,8) NOT NULL,
    longitude numeric(11,8) NOT NULL,
    description text NOT NULL,
    "developerId" uuid,
    "priceFrom" numeric(15,2),
    "bedroomsFrom" integer,
    "bedroomsTo" integer,
    "bathroomsFrom" integer,
    "bathroomsTo" integer,
    "sizeFrom" numeric(10,2),
    "sizeTo" numeric(10,2),
    "paymentPlan" text,
    price numeric(15,2),
    bedrooms integer,
    bathrooms integer,
    size numeric(10,2),
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.properties OWNER TO admin;

--
-- Name: properties_facilities_facilities; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.properties_facilities_facilities (
    "propertiesId" uuid NOT NULL,
    "facilitiesId" uuid NOT NULL
);


ALTER TABLE public.properties_facilities_facilities OWNER TO admin;

--
-- Name: property_units; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.property_units (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "propertyId" uuid NOT NULL,
    "unitId" character varying NOT NULL,
    type public.property_units_type_enum NOT NULL,
    "planImage" character varying,
    "totalSize" numeric(10,2) NOT NULL,
    "balconySize" numeric(10,2),
    price numeric(15,2) NOT NULL
);


ALTER TABLE public.property_units OWNER TO admin;

--
-- Name: support_requests; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.support_requests (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "userId" uuid NOT NULL,
    subject character varying NOT NULL,
    message text NOT NULL,
    status public.support_requests_status_enum DEFAULT 'pending'::public.support_requests_status_enum NOT NULL,
    priority character varying DEFAULT 'normal'::character varying NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.support_requests OWNER TO admin;

--
-- Name: support_responses; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.support_responses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "supportRequestId" uuid NOT NULL,
    "userId" uuid,
    message text NOT NULL,
    "isFromAdmin" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.support_responses OWNER TO admin;

--
-- Name: users; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying NOT NULL,
    phone character varying NOT NULL,
    password_hash character varying NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    role public.users_role_enum DEFAULT 'CLIENT'::public.users_role_enum NOT NULL,
    status public.users_status_enum DEFAULT 'ACTIVE'::public.users_status_enum NOT NULL,
    license_number character varying,
    google_id character varying,
    apple_id character varying,
    avatar character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO admin;

--
-- Data for Name: api_keys; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.api_keys (id, "apiKey", "apiSecret", name, "isActive", "lastUsedAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: areas; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.areas (id, "cityId", "nameEn", "nameRu", "nameAr") FROM stdin;
1b6f0f1f-0587-4d5f-96b2-5cb76844b1a3	93d991f3-2468-4506-8417-f117f42a5b5b	Downtown Dubai	Downtown Dubai	Downtown Dubai
a22870e9-9d1e-4dfb-aaba-9cc647afe23b	93d991f3-2468-4506-8417-f117f42a5b5b	Palm Jumeirah	Palm Jumeirah	Palm Jumeirah
e0e4aacc-0fa7-447e-973a-467799c8a74d	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Marina	Dubai Marina	Dubai Marina
2a4cae04-f928-4206-99c1-447fb02d5e71	93d991f3-2468-4506-8417-f117f42a5b5b	JBR	JBR	JBR
7924f2dd-94bf-4ec3-b3fe-cbc5606a073a	93d991f3-2468-4506-8417-f117f42a5b5b	Business Bay	Business Bay	Business Bay
d041653e-552a-4a89-bc5e-13f4e76d30a7	93d991f3-2468-4506-8417-f117f42a5b5b	JLT	JLT	JLT
f593e70a-b7ba-4646-8f81-6bf8398ce9fe	93d991f3-2468-4506-8417-f117f42a5b5b	Arabian Ranches	Arabian Ranches	Arabian Ranches
2a295d06-8184-40d0-a68a-18cf529173af	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Hills	Dubai Hills	Dubai Hills
24211934-94ef-4d71-aa94-900825858a4c	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai	Dubai	Dubai
87df5a24-035b-4a50-8f7f-c800afdc66f5	93d991f3-2468-4506-8417-f117f42a5b5b	Al Aryam	Al Aryam	Al Aryam
e5670b5a-f27f-4079-9cdf-317a74fd49c3	93d991f3-2468-4506-8417-f117f42a5b5b	Al Barari	Al Barari	Al Barari
ed6aac3f-cc3f-4740-b387-692d2597b6a4	93d991f3-2468-4506-8417-f117f42a5b5b	Al Barsha	Al Barsha	Al Barsha
3b542863-2800-4e23-b31e-c2abe9e84a21	93d991f3-2468-4506-8417-f117f42a5b5b	Al Barsha First	Al Barsha First	Al Barsha First
0345bb0a-b3f3-4c2b-9aa8-d22ecdcaffe6	93d991f3-2468-4506-8417-f117f42a5b5b	Al Barsha Second	Al Barsha Second	Al Barsha Second
c4f90a10-806b-4855-a8ec-25092b0f3eef	93d991f3-2468-4506-8417-f117f42a5b5b	Al Barsha South Fifth	Al Barsha South Fifth	Al Barsha South Fifth
2e65030a-b26d-4ff3-9738-35d047a7acc7	93d991f3-2468-4506-8417-f117f42a5b5b	Al Barsha South Fourth	Al Barsha South Fourth	Al Barsha South Fourth
c8318bfc-0e3a-4842-acc6-33224c9d2fdd	93d991f3-2468-4506-8417-f117f42a5b5b	Al Barsha South Second	Al Barsha South Second	Al Barsha South Second
ea2e2930-5c45-4965-b880-b8a832a56839	93d991f3-2468-4506-8417-f117f42a5b5b	Al Barsha South Third	Al Barsha South Third	Al Barsha South Third
30547901-2454-4963-8d7b-0f81845dd1d8	93d991f3-2468-4506-8417-f117f42a5b5b	Al Corniche	Al Corniche	Al Corniche
88a36108-7c13-425a-93b4-645f04e9a8f9	93d991f3-2468-4506-8417-f117f42a5b5b	Al Furjan	Al Furjan	Al Furjan
92474e8d-054c-4ae8-8ca4-c042eb96dff1	93d991f3-2468-4506-8417-f117f42a5b5b	Al Hebiah Fifth	Al Hebiah Fifth	Al Hebiah Fifth
e82a2c9a-2ad4-4fea-ad85-972e4a8d40d4	93d991f3-2468-4506-8417-f117f42a5b5b	Al Hebiah First	Al Hebiah First	Al Hebiah First
a39da8df-a21d-4fc6-b471-a90166a4f7a2	93d991f3-2468-4506-8417-f117f42a5b5b	Al Hebiah Fourth	Al Hebiah Fourth	Al Hebiah Fourth
6d0c3207-15c4-46d3-8acf-9f031b4b1463	93d991f3-2468-4506-8417-f117f42a5b5b	Al Hebiah Second	Al Hebiah Second	Al Hebiah Second
d90f959c-6b57-434a-a9fb-c54a56252254	93d991f3-2468-4506-8417-f117f42a5b5b	Al Hebiah Third	Al Hebiah Third	Al Hebiah Third
5cec6742-835e-4c9a-85d9-5e63fb36218f	93d991f3-2468-4506-8417-f117f42a5b5b	Al Jadaf	Al Jadaf	Al Jadaf
d8d32231-40b3-436e-811a-4cf7feea21fc	93d991f3-2468-4506-8417-f117f42a5b5b	Al Khairan First	Al Khairan First	Al Khairan First
38772b22-ebc8-471c-85f4-141751dff015	93d991f3-2468-4506-8417-f117f42a5b5b	Al Kheeran	Al Kheeran	Al Kheeran
5806b562-125e-4f44-80ab-2862099b4642	93d991f3-2468-4506-8417-f117f42a5b5b	Al Kifaf	Al Kifaf	Al Kifaf
e7003b89-1a49-4eaa-9349-9b34490dc6b6	93d991f3-2468-4506-8417-f117f42a5b5b	Al Merkadh	Al Merkadh	Al Merkadh
97b200cf-a017-4c4a-890e-7f26f177f098	93d991f3-2468-4506-8417-f117f42a5b5b	Al Nahda First	Al Nahda First	Al Nahda First
7fd7094a-9eea-4604-bdf0-05ca064f1510	93d991f3-2468-4506-8417-f117f42a5b5b	Al Nahda Second	Al Nahda Second	Al Nahda Second
8229b1ef-ad19-4e5b-a179-967c2c9f59fc	93d991f3-2468-4506-8417-f117f42a5b5b	Al Quoz	Al Quoz	Al Quoz
94af890c-7267-4a70-a5d1-e9f7287a4ef9	93d991f3-2468-4506-8417-f117f42a5b5b	Al Quoz 2	Al Quoz 2	Al Quoz 2
dbb7d8c9-d77e-4f03-9673-74e29459c40f	93d991f3-2468-4506-8417-f117f42a5b5b	Al Quoz 4	Al Quoz 4	Al Quoz 4
4467c97c-39ad-4ec9-badc-dec209627776	93d991f3-2468-4506-8417-f117f42a5b5b	Al Safouh First	Al Safouh First	Al Safouh First
30680a42-53bb-4517-a23b-e04caa0b9d1d	93d991f3-2468-4506-8417-f117f42a5b5b	Al Safouh Second	Al Safouh Second	Al Safouh Second
5b1a7312-bb0f-445c-916f-8b4cdbe64f20	93d991f3-2468-4506-8417-f117f42a5b5b	Al Thanyah Fifth	Al Thanyah Fifth	Al Thanyah Fifth
bf4f73fa-87a0-4f8b-960b-0d70598b4aa6	93d991f3-2468-4506-8417-f117f42a5b5b	Al Thanyah First	Al Thanyah First	Al Thanyah First
f49ae4e1-9e78-4ada-a483-1323a256e8a5	93d991f3-2468-4506-8417-f117f42a5b5b	Al Thanyah Third	Al Thanyah Third	Al Thanyah Third
3253d18e-90b3-4ca2-97c3-d6f31f8ff57d	93d991f3-2468-4506-8417-f117f42a5b5b	Al Wasl	Al Wasl	Al Wasl
a4920567-aca8-4d6f-8070-ce3e0753b5dd	93d991f3-2468-4506-8417-f117f42a5b5b	Al Yelayiss 1	Al Yelayiss 1	Al Yelayiss 1
15b0048f-640d-4d1a-af93-f77361074f73	93d991f3-2468-4506-8417-f117f42a5b5b	Al Yelayiss 2	Al Yelayiss 2	Al Yelayiss 2
e9fcb83d-13b7-47c0-b4a3-92bcdc950a20	93d991f3-2468-4506-8417-f117f42a5b5b	Al Yelayiss 5	Al Yelayiss 5	Al Yelayiss 5
ca9e8ceb-4239-404c-9066-c41f91e205a0	93d991f3-2468-4506-8417-f117f42a5b5b	Al Yufrah 1	Al Yufrah 1	Al Yufrah 1
a894a558-bba1-443c-a78a-5d9e561a414e	93d991f3-2468-4506-8417-f117f42a5b5b	Al Yufrah 2	Al Yufrah 2	Al Yufrah 2
350c02b5-8a32-47ac-a14a-59ab1183614f	93d991f3-2468-4506-8417-f117f42a5b5b	Al Yufrah 3	Al Yufrah 3	Al Yufrah 3
c8467ca2-79b2-4edd-81dd-2cb2de6b938a	93d991f3-2468-4506-8417-f117f42a5b5b	Arabian Ranches I	Arabian Ranches I	Arabian Ranches I
fbcc58b7-899d-4ced-a27a-353fb1e00cab	93d991f3-2468-4506-8417-f117f42a5b5b	Arjan	Arjan	Arjan
f47e2c31-b26a-4261-a949-291a8fd52c60	93d991f3-2468-4506-8417-f117f42a5b5b	Barsha Heights	Barsha Heights	Barsha Heights
4811bb28-d527-4c12-a9dd-5ef08a16ed30	93d991f3-2468-4506-8417-f117f42a5b5b	Bluewaters	Bluewaters	Bluewaters
2cc741ff-f6f1-40f7-bd1a-514c8baf1f4c	93d991f3-2468-4506-8417-f117f42a5b5b	Bu Kadra	Bu Kadra	Bu Kadra
a5c9fc10-c16c-4877-b0d3-5acd4e852697	93d991f3-2468-4506-8417-f117f42a5b5b	Burj Khalifa	Burj Khalifa	Burj Khalifa
4ca29ccf-c72f-4d64-a3b9-f31f7185650e	93d991f3-2468-4506-8417-f117f42a5b5b	Cherrywoods	Cherrywoods	Cherrywoods
599de105-6125-405c-9a9c-cd4e1c80bc38	93d991f3-2468-4506-8417-f117f42a5b5b	City Walk	City Walk	City Walk
1d2255f7-8078-4b16-a277-88a6f62f6ceb	93d991f3-2468-4506-8417-f117f42a5b5b	City of Arabia	City of Arabia	City of Arabia
f4727cff-c6b5-4e7b-9732-d874c903a9f3	93d991f3-2468-4506-8417-f117f42a5b5b	Corniche Deira	Corniche Deira	Corniche Deira
ab4c5845-e13d-4487-83fc-e00ba9c651c0	93d991f3-2468-4506-8417-f117f42a5b5b	Damac Hills	Damac Hills	Damac Hills
1179631e-2700-4b72-ab0a-7f51cc7cecd3	93d991f3-2468-4506-8417-f117f42a5b5b	Damac Hills 2	Damac Hills 2	Damac Hills 2
e7043496-e57e-49a4-b09e-fa7fedf8c3fa	93d991f3-2468-4506-8417-f117f42a5b5b	Damac Lagoons	Damac Lagoons	Damac Lagoons
d01db1ac-7d1a-4c21-ba2c-946163a517b9	93d991f3-2468-4506-8417-f117f42a5b5b	Deira	Deira	Deira
41eb3cfd-38bc-4d16-bba1-82abcf20d11b	93d991f3-2468-4506-8417-f117f42a5b5b	Discovery Gardens	Discovery Gardens	Discovery Gardens
12ed858b-b256-4482-b4df-47f489a715de	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Creek Harbour	Dubai Creek Harbour	Dubai Creek Harbour
8c329393-0690-4abd-b14a-a3d756b912bd	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Design District	Dubai Design District	Dubai Design District
6f200b2f-31f2-415e-9bf0-6a059097d113	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Festival City	Dubai Festival City	Dubai Festival City
358ede6c-3538-4c8b-94a6-b86abcd248ad	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Golf City	Dubai Golf City	Dubai Golf City
98a85795-7689-4ba6-abad-8f5b2163a45c	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Harbour	Dubai Harbour	Dubai Harbour
a6cf4860-6fd8-4105-a8e2-b074a29b2a45	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Healthcare City Phase 2	Dubai Healthcare City Phase 2	Dubai Healthcare City Phase 2
09a31aa3-080f-4ee3-9c8a-2c233dcd2c2e	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Industrial City	Dubai Industrial City	Dubai Industrial City
e12ba239-3265-4665-b6b4-4124058ac5b5	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai International City	Dubai International City	Dubai International City
a1ed9da4-689a-45a4-92c5-e9c1b839ca48	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Internet City	Dubai Internet City	Dubai Internet City
e64fe38e-08d3-43a2-bca5-993652b9d513	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Investment Park	Dubai Investment Park	Dubai Investment Park
d94c4219-ae04-4144-b4c0-fed0ed1f5682	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Investment Park First	Dubai Investment Park First	Dubai Investment Park First
09b40291-e2c5-47b3-803e-06c7e6763fd6	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Investment Park Second	Dubai Investment Park Second	Dubai Investment Park Second
12fa2f6e-d34f-4b9f-82ff-7a2c3559bb54	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Islands	Dubai Islands	Dubai Islands
cf8bf1a1-64b0-47bc-aad0-ed58de738673	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Land	Dubai Land	Dubai Land
7cd62b2f-964c-4a2d-911d-c1439a827678	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Media City	Dubai Media City	Dubai Media City
63bca911-05e2-480a-8bad-dd9ccb6fb72c	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Production City	Dubai Production City	Dubai Production City
c63c8dfa-3589-46b7-becf-7851a440a436	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Science Park	Dubai Science Park	Dubai Science Park
97fb26d0-540b-44f4-af4b-b77221f7c345	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Silicon Oasis	Dubai Silicon Oasis	Dubai Silicon Oasis
b5bac788-d0fd-45f9-9e11-11bcff6f45c0	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Sports City	Dubai Sports City	Dubai Sports City
6402d19b-ffd2-4b30-b4fb-ae9f19abb921	93d991f3-2468-4506-8417-f117f42a5b5b	Dubai Studio City	Dubai Studio City	Dubai Studio City
4184ee77-1bdd-4333-99f1-73c118687b79	93d991f3-2468-4506-8417-f117f42a5b5b	Falconcity of Wonders	Falconcity of Wonders	Falconcity of Wonders
9ed892eb-046b-4a3b-a4c0-3ba076e33a5f	93d991f3-2468-4506-8417-f117f42a5b5b	Hadaeq Sheikh Mohammed Bin Rashid	Hadaeq Sheikh Mohammed Bin Rashid	Hadaeq Sheikh Mohammed Bin Rashid
844648b7-f86d-4b39-96eb-eb8e1688a00e	93d991f3-2468-4506-8417-f117f42a5b5b	International City	International City	International City
39bddefb-f557-4b4a-93d5-75a032669cce	93d991f3-2468-4506-8417-f117f42a5b5b	Jabal Ali First	Jabal Ali First	Jabal Ali First
47356631-9c82-4ea7-bf46-667d71497bc4	93d991f3-2468-4506-8417-f117f42a5b5b	Jabal Ali Industrial Second	Jabal Ali Industrial Second	Jabal Ali Industrial Second
6c764476-1998-4979-ac13-5f9b1920ad23	93d991f3-2468-4506-8417-f117f42a5b5b	Jumeira Second	Jumeira Second	Jumeira Second
15005d51-1592-45cf-920e-ec8e18e1dd3d	93d991f3-2468-4506-8417-f117f42a5b5b	Jumeirah	Jumeirah	Jumeirah
fb4b0cd1-7015-444d-9738-7d3964e7184b	93d991f3-2468-4506-8417-f117f42a5b5b	Jumeirah Beach Residence (JBR)	Jumeirah Beach Residence (JBR)	Jumeirah Beach Residence (JBR)
04c591de-dc91-433c-9ded-339c05e1053e	93d991f3-2468-4506-8417-f117f42a5b5b	Jumeirah Gardens	Jumeirah Gardens	Jumeirah Gardens
63f3aea6-f12e-4fb1-a34f-e7fa21c5f3d0	93d991f3-2468-4506-8417-f117f42a5b5b	Jumeirah Island One	Jumeirah Island One	Jumeirah Island One
49591050-de6c-4764-97a2-1e3b32b23f8a	93d991f3-2468-4506-8417-f117f42a5b5b	Jumeirah Lake Towers (JLT)	Jumeirah Lake Towers (JLT)	Jumeirah Lake Towers (JLT)
e2a0aa7e-b00e-4670-9fbe-8b38a2e2ef91	93d991f3-2468-4506-8417-f117f42a5b5b	Jumeirah Lakes Towers	Jumeirah Lakes Towers	Jumeirah Lakes Towers
c9f2c230-e3b5-465a-9c5f-cf7bebc35905	93d991f3-2468-4506-8417-f117f42a5b5b	Jumeirah Village Circle (JVC)	Jumeirah Village Circle (JVC)	Jumeirah Village Circle (JVC)
057e3b70-8aa8-4064-8f4c-33df293bc63d	93d991f3-2468-4506-8417-f117f42a5b5b	Jumeirah Village Triangle (JVT)	Jumeirah Village Triangle (JVT)	Jumeirah Village Triangle (JVT)
81d88974-2aee-43e1-8dba-5b1bc174d902	93d991f3-2468-4506-8417-f117f42a5b5b	MJL (Madinat Jumeirah Living)	MJL (Madinat Jumeirah Living)	MJL (Madinat Jumeirah Living)
cd10c58e-cdbe-4984-b671-ef8d2a5accd7	93d991f3-2468-4506-8417-f117f42a5b5b	Madinat Al Mataar	Madinat Al Mataar	Madinat Al Mataar
5fa23faf-1d65-45eb-bd71-6777e1bf8a32	93d991f3-2468-4506-8417-f117f42a5b5b	Madinat Dubai Al Melaheyah	Madinat Dubai Al Melaheyah	Madinat Dubai Al Melaheyah
82cf5b41-5f13-4a87-b060-d3c40613f8cf	93d991f3-2468-4506-8417-f117f42a5b5b	Majan	Majan	Majan
883022cc-b7f4-4c8c-a8a3-8e18cfdaf12e	93d991f3-2468-4506-8417-f117f42a5b5b	Maritime city	Maritime city	Maritime city
4d422869-1d4f-4906-b2dd-29e4afad946e	93d991f3-2468-4506-8417-f117f42a5b5b	Marsa Dubai	Marsa Dubai	Marsa Dubai
c2f6f866-f1ca-493c-abf4-98a267bbc803	93d991f3-2468-4506-8417-f117f42a5b5b	Meydan	Meydan	Meydan
03e6a905-b763-4b16-b621-69b3c5ee4a9a	93d991f3-2468-4506-8417-f117f42a5b5b	Me´Aisem First	Me´Aisem First	Me´Aisem First
3400966c-86a6-4b62-9e75-7b65cb81ebbd	93d991f3-2468-4506-8417-f117f42a5b5b	Me´Aisem Second	Me´Aisem Second	Me´Aisem Second
54bb9eee-1830-4fb8-a752-02668383bb68	93d991f3-2468-4506-8417-f117f42a5b5b	Mina Rashid	Mina Rashid	Mina Rashid
fd7a25cd-92dd-4b46-9fb6-a26c7ee787ee	93d991f3-2468-4506-8417-f117f42a5b5b	Mirdif	Mirdif	Mirdif
73a52a82-d3ba-480f-b108-dd27e8f4149d	93d991f3-2468-4506-8417-f117f42a5b5b	Mohammed Bin Rashid City (MBR)	Mohammed Bin Rashid City (MBR)	Mohammed Bin Rashid City (MBR)
19321fec-f276-4bde-8964-1654a1c6f290	93d991f3-2468-4506-8417-f117f42a5b5b	Motor City	Motor City	Motor City
a3449f16-c143-42c6-a4f5-9632519f6636	93d991f3-2468-4506-8417-f117f42a5b5b	Nadd Al Shiba First	Nadd Al Shiba First	Nadd Al Shiba First
77bb0f84-f18a-4c43-931b-9509af222141	93d991f3-2468-4506-8417-f117f42a5b5b	Nadd Al Shiba Third	Nadd Al Shiba Third	Nadd Al Shiba Third
dc0d6494-ab05-4c05-902b-20d1872beee6	93d991f3-2468-4506-8417-f117f42a5b5b	Nadd Hessa	Nadd Hessa	Nadd Hessa
184a996f-4e14-4281-9810-1d19f243288c	93d991f3-2468-4506-8417-f117f42a5b5b	Nakhlat Deira	Nakhlat Deira	Nakhlat Deira
0b7c15d3-de9e-4fa8-a876-69e50a05b116	93d991f3-2468-4506-8417-f117f42a5b5b	Nakhlat Jabal Ali	Nakhlat Jabal Ali	Nakhlat Jabal Ali
1be07f63-298a-4763-9f10-a2daaa83130e	93d991f3-2468-4506-8417-f117f42a5b5b	Palm Jabal Ali	Palm Jabal Ali	Palm Jabal Ali
7fe02b5e-86b5-452e-8ffe-159f2c3ca11d	93d991f3-2468-4506-8417-f117f42a5b5b	Port De La Mer	Port De La Mer	Port De La Mer
bb6ec95b-1ac4-4dee-9a39-aee7a08213d6	93d991f3-2468-4506-8417-f117f42a5b5b	Ras Al Khor Ind. First	Ras Al Khor Ind. First	Ras Al Khor Ind. First
83000656-6fc3-4813-a42a-59d643a9e844	93d991f3-2468-4506-8417-f117f42a5b5b	Remraam	Remraam	Remraam
ed0d236f-bd28-4b58-a27d-4852add65745	93d991f3-2468-4506-8417-f117f42a5b5b	Saih Shuaib 2	Saih Shuaib 2	Saih Shuaib 2
5f79c8f5-249b-4a5a-9b76-aa3a8d634a84	93d991f3-2468-4506-8417-f117f42a5b5b	Sobha Hartland	Sobha Hartland	Sobha Hartland
2ffaf08f-7166-4241-bbd4-6072c063f7c8	93d991f3-2468-4506-8417-f117f42a5b5b	Sobha Hartland 2	Sobha Hartland 2	Sobha Hartland 2
e8a0f753-5695-4a83-9a81-b503bad27650	93d991f3-2468-4506-8417-f117f42a5b5b	Sobha Reserve	Sobha Reserve	Sobha Reserve
36ee1567-fd2e-4de3-833a-3fa8113cac39	93d991f3-2468-4506-8417-f117f42a5b5b	The Dubai International Financial Centre (DIFC)	The Dubai International Financial Centre (DIFC)	The Dubai International Financial Centre (DIFC)
4211d15c-d16a-41f4-839c-018a50231684	93d991f3-2468-4506-8417-f117f42a5b5b	The Greens	The Greens	The Greens
16a909ba-8c36-49e9-96b5-d8cc4d6936ea	93d991f3-2468-4506-8417-f117f42a5b5b	Tilal Al Ghaf	Tilal Al Ghaf	Tilal Al Ghaf
7b7d21ec-03e7-4ad6-aab0-c98ed5bf9546	93d991f3-2468-4506-8417-f117f42a5b5b	Town Square	Town Square	Town Square
93e7ca6a-efc2-4b78-a209-fb475cd7f7cd	93d991f3-2468-4506-8417-f117f42a5b5b	Trade Center First	Trade Center First	Trade Center First
01995720-47a6-4c4f-a54b-f5037d804c83	93d991f3-2468-4506-8417-f117f42a5b5b	Umm Suqeim	Umm Suqeim	Umm Suqeim
6caf2982-3882-4dd0-899a-217f24eea2dc	93d991f3-2468-4506-8417-f117f42a5b5b	Umm Suqeim First	Umm Suqeim First	Umm Suqeim First
bcd0b86d-912d-41d9-9644-db4d2fb0081a	93d991f3-2468-4506-8417-f117f42a5b5b	Umm Suqeim Second	Umm Suqeim Second	Umm Suqeim Second
a9174fd3-a021-4cdb-b648-2b1d3ffd0ade	93d991f3-2468-4506-8417-f117f42a5b5b	Umm Suqeim Third	Umm Suqeim Third	Umm Suqeim Third
f7084611-a1b8-4672-aa13-2e819da4cd43	93d991f3-2468-4506-8417-f117f42a5b5b	Uptown	Uptown	Uptown
8f187bcb-ce75-42ca-8227-81ebb521e9be	93d991f3-2468-4506-8417-f117f42a5b5b	Wadi Al Safa 3	Wadi Al Safa 3	Wadi Al Safa 3
a5317e04-9370-4502-b237-52ae1d095841	93d991f3-2468-4506-8417-f117f42a5b5b	Wadi Al Safa 4	Wadi Al Safa 4	Wadi Al Safa 4
9d066c84-5273-4fd5-8ef1-26ccd22a0626	93d991f3-2468-4506-8417-f117f42a5b5b	Wadi Al Safa 5	Wadi Al Safa 5	Wadi Al Safa 5
e3a48c16-e511-4dd5-9202-87093ad05604	93d991f3-2468-4506-8417-f117f42a5b5b	Wadi Al Safa 6	Wadi Al Safa 6	Wadi Al Safa 6
a8a75e83-d47c-43a4-a784-7b80bf81186a	93d991f3-2468-4506-8417-f117f42a5b5b	Wadi Al Safa 7	Wadi Al Safa 7	Wadi Al Safa 7
cb78d29f-12e9-4c0f-bf9d-2a03b79d966f	93d991f3-2468-4506-8417-f117f42a5b5b	Warsan Fourth	Warsan Fourth	Warsan Fourth
52bc128c-732d-4e3c-b91b-b574afc33d11	93d991f3-2468-4506-8417-f117f42a5b5b	Warsan Second	Warsan Second	Warsan Second
867c1576-1dd5-44aa-8b6a-734e729c1070	93d991f3-2468-4506-8417-f117f42a5b5b	World Islands	World Islands	World Islands
e452f6be-56ba-40f8-ae3d-805902487ecc	93d991f3-2468-4506-8417-f117f42a5b5b	Za'abeel	Za'abeel	Za'abeel
17c50bae-f4c7-40a8-b488-d2b0c0faaca8	93d991f3-2468-4506-8417-f117f42a5b5b	Za´Abeel First	Za´Abeel First	Za´Abeel First
ad877a8b-bcb2-42fe-8b16-05e711f0c3d1	93d991f3-2468-4506-8417-f117f42a5b5b	Za´Abeel Second	Za´Abeel Second	Za´Abeel Second
\.


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.cities (id, "countryId", "nameEn", "nameRu", "nameAr") FROM stdin;
93d991f3-2468-4506-8417-f117f42a5b5b	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	Dubai	Дубай	دبي
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.countries (id, "nameEn", "nameRu", "nameAr", code) FROM stdin;
d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	United Arab Emirates	Объединенные Арабские Эмираты	الإمارات العربية المتحدة	AE
161c0414-325a-46fe-9d61-c8c8e03ee5fe	Test Country	Тест	اختبار	TC
\.


--
-- Data for Name: course_contents; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.course_contents (id, "courseId", type, title, description, "imageUrl", "videoUrl", "order") FROM stdin;
d641aa49-9464-4fac-9fe6-f9e747738a0f	4f3d2679-f186-4813-9055-6ce5c399d1b0	text	Welcome	Introduction text	\N	\N	1
6176ec63-0eed-44a9-80ed-07b841973a8b	4f3d2679-f186-4813-9055-6ce5c399d1b0	image	Dubai Skyline	\N	https://example.com/skyline.jpg	\N	2
daf6fa1a-aa40-419b-8605-d6e1d5256b79	7db91e41-ea95-43d9-8e9e-fd5a68313be8	text	Welcome	Introduction text	\N	\N	1
60c77add-4fb3-46a1-a16e-bbf1813708ab	7db91e41-ea95-43d9-8e9e-fd5a68313be8	image	Dubai Skyline	\N	https://example.com/skyline.jpg	\N	2
1de17882-6b74-45ef-be9f-a9fe2d5f1755	b2573442-4e7e-44e0-be9f-89274070ad85	image	asfmko	asfkmo	https://res.cloudinary.com/dgv0rxd60/image/upload/v1762092066/properties/cv7sj5wmydy3p1jlnnbk.png	\N	0
29df489a-aaaa-4ddb-aca7-98fad14914e6	b2573442-4e7e-44e0-be9f-89274070ad85	text	dsfmpdsamf	asmfpkmasf	\N	\N	1
9b8ae7ae-942f-4530-ada3-d6cd9c909b21	b2573442-4e7e-44e0-be9f-89274070ad85	video	sfmkmas	asf jas f	\N	https://www.youtube.com/watch?v=Qh1IHbm1QYQ&list=RDQh1IHbm1QYQ&start_radio=1	2
\.


--
-- Data for Name: course_links; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.course_links (id, "courseId", title, url, "order") FROM stdin;
efd51237-53f3-4ee2-920e-c13560a40757	4f3d2679-f186-4813-9055-6ce5c399d1b0	Official Website	https://example.com	1
fdf2c919-a687-4536-8009-093902e4f875	7db91e41-ea95-43d9-8e9e-fd5a68313be8	Official Website	https://example.com	1
11688eea-3256-4556-a1ae-4b365031ba69	b2573442-4e7e-44e0-be9f-89274070ad85	dsfdsf	https://reforyou.amocrm.ru/leads/detail/37662693	0
\.


--
-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.courses (id, title, description, "order", "createdAt", "updatedAt") FROM stdin;
4f3d2679-f186-4813-9055-6ce5c399d1b0	Introduction to Dubai Market	Learn about Dubai real estate	1	2025-11-01 14:38:05.544829	2025-11-01 14:38:05.544829
7db91e41-ea95-43d9-8e9e-fd5a68313be8	Introduction to Dubai Market	Learn about Dubai real estate	1	2025-11-01 14:38:11.757225	2025-11-01 14:38:11.757225
b2573442-4e7e-44e0-be9f-89274070ad85	dmlkmsd	safasfasf	0	2025-11-02 14:01:53.990712	2025-11-02 14:01:53.990712
\.


--
-- Data for Name: developers; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.developers (id, name, logo, description, "createdAt") FROM stdin;
2d0d3a61-3290-40c8-87cc-5dc07e7e90bb	Mr. Eight	\N	\N	2025-11-02 20:37:51.635686
3b70689b-b74e-4ea1-8f70-89e4c106f492	Segrex Development	\N	\N	2025-11-02 20:37:51.667092
8f3b6c16-7ab2-4351-9516-9ceed860b98b	Major Developments	\N	\N	2025-11-02 20:37:51.671652
4bd08a66-abb9-4f28-8cc0-bb444c7f76c2	Palladium Development	\N	\N	2025-11-02 20:37:51.679263
4cc30cd4-e4e9-470b-860d-2eaad67bb53e	Vision developments	\N	\N	2025-11-02 20:37:51.685492
3b7d2c70-4658-4d1d-b969-e1c5ebfd0851	Emaar Properties	\N	\N	2025-11-02 20:37:51.687779
47c81f9a-ea8d-4e90-b161-fed5002f3692	AMIS Properties	\N	\N	2025-11-02 20:37:51.691169
3836449c-72ff-473e-a0e0-88e5ae2f3fac	Rabdan Real Estate Developments	\N	\N	2025-11-02 20:37:51.705949
225eabc6-3f50-4322-9807-7dbc9d5e8ad1	Ellington	\N	\N	2025-11-02 20:37:51.710834
58fe1784-53b9-43e0-9fad-f82335da5b6f	Imtiaz	\N	\N	2025-11-02 20:37:51.712483
7a93bee6-7391-464d-b44f-916ffad6622a	Forum Real Estate Development	\N	\N	2025-11-02 20:37:51.71427
2d0c3f86-7925-4ecb-90cd-b9a87b8b0fea	BT Properties	\N	\N	2025-11-02 20:37:51.719118
11ec3fc2-3492-4fa3-b5bb-7859a4d2fa07	Rvl Real Estate	\N	\N	2025-11-02 20:37:51.720683
8ffc609c-5433-4494-a6dc-6ac688318546	SOL Properties	\N	\N	2025-11-02 20:37:51.731652
0979c804-b6e3-41e3-85ae-6846e77faf69	London Gate	\N	\N	2025-11-02 20:37:51.733258
891e1fc4-17cb-4e7e-b992-d2beaf927f58	Arete Developments	\N	\N	2025-11-02 20:37:51.736264
7fa51e52-1d80-4cb6-b3eb-da9486b74eba	Object One	\N	\N	2025-11-02 20:37:51.737683
3434540a-9884-4068-a179-b8baf2ad24c6	7th Key	\N	\N	2025-11-02 20:37:51.739242
08ef76dc-0af4-40dd-853a-f3c63bff4120	New MFOUR Real Estate Development	\N	\N	2025-11-02 20:37:51.740779
8917ba51-3bc1-4023-986c-ac4001ff56f9	Tasmeer Indigo Properties	\N	\N	2025-11-02 20:37:51.745085
1d0da11d-1eee-4cb1-9902-cf361741f75b	AHS Properties	\N	\N	2025-11-02 20:37:51.749744
0cc6c7c0-c554-423a-a637-8bb3342a8286	Deyaar	\N	\N	2025-11-02 20:37:51.751122
72e676c1-c3bc-4ce0-8793-a8e31c14f18d	Confident Group	\N	\N	2025-11-02 20:37:51.752606
15b618ff-644d-4d27-984e-b2e823b591e5	QUBE Development	\N	\N	2025-11-02 20:37:51.754029
51a30934-327f-4cd9-adb5-1ba33a241dff	AB Developers	\N	\N	2025-11-02 20:37:51.755468
33a6f2ce-e08b-4aae-bf50-20315a08fdf9	Laraix	\N	\N	2025-11-02 20:37:51.758396
27b3daf7-9faa-4238-955a-c0288fdf79cd	Calgary Properties	\N	\N	2025-11-02 20:37:51.760542
abc6d788-e502-4bf2-a17a-3e005acf2ef5	DHG Real Estate Group	\N	\N	2025-11-02 20:37:51.762669
27823b3f-6a80-4c07-a72c-27bb6c3966c7	Nakheel	\N	\N	2025-11-02 20:37:51.764059
49118011-f96d-4d03-a12f-af75a466ee5e	Fakhruddin Properties	\N	\N	2025-11-02 20:37:51.766699
cc7dce26-de37-42e0-8b58-6f26df319c6c	Credo Investments	\N	\N	2025-11-02 20:37:51.76923
096760e9-b0e6-4f22-9078-05b884f541ad	Azizi	\N	\N	2025-11-02 20:37:51.773289
0334316d-d862-4111-a9e9-d0d3a9203032	Peace Homes Development	\N	\N	2025-11-02 20:37:51.780664
0225189f-0990-42e0-9c52-5ef837dddd46	Beyond	\N	\N	2025-11-02 20:37:51.790152
133e44d6-3c78-4154-bae2-a5e13a72da3d	Iquna Properties	\N	\N	2025-11-02 20:37:51.808514
039672ee-bacf-4da0-b13b-655d2e93703e	Elysian Development	\N	\N	2025-11-02 20:37:51.812422
5e7edb77-3591-4ac5-9dd7-a10c07c6f612	AUM Development	\N	\N	2025-11-02 20:37:51.818041
7f72f7e9-273a-4da5-a3be-c2126a9558ba	Barco Developers	\N	\N	2025-11-02 20:37:51.819484
060dc5c4-a9e7-44a8-a3ff-6e5573ea71e0	MAG Property Development	\N	\N	2025-11-02 20:37:51.822664
53db6940-f002-4ab5-bbe6-06fc4653dd74	Zimaya Properties	\N	\N	2025-11-02 20:37:51.824071
177aeada-8895-40b3-adc7-8b09517631dd	Wasl	\N	\N	2025-11-02 20:37:51.826714
70fe169b-e8e2-4d15-8691-32d0487a280e	Skyline Builders	\N	\N	2025-11-02 20:37:51.829349
463deebc-2dcc-4a92-99be-1b381435f0b1	MAK Developers	\N	\N	2025-11-02 20:37:51.830761
3b03ad7b-4bf1-4169-9eb5-fd5c3db9c37d	Avenew Development	\N	\N	2025-11-02 20:37:51.832116
b42d1cba-1945-4621-85e0-704f40383dd3	Shakirov Developments	\N	\N	2025-11-02 20:37:51.837733
11b52253-b0fe-40a8-8384-b4f0fd43490e	Marquis	\N	\N	2025-11-02 20:37:51.83904
828dc346-003b-4f0f-ba72-9c50c9bbb6fd	Taraf	\N	\N	2025-11-02 20:37:51.842994
153a3e90-e3db-4802-a957-735a614394ad	Elton Real Estate Development	\N	\N	2025-11-02 20:37:51.844307
8315af5e-2d12-4537-9e25-a7fcc29d3619	Maakdream Properties	\N	\N	2025-11-02 20:37:51.847156
475b0d4e-227e-44b1-9d91-eb631721acaf	AMBER Developments	\N	\N	2025-11-02 20:37:51.854065
5689c9d7-d0df-4971-9e6c-82d5d3bf74d1	Dubai South	\N	\N	2025-11-02 20:37:51.855472
20ff0114-813f-481c-8e28-e31084f70ac1	The Heart of Europe	\N	\N	2025-11-02 20:37:51.856831
18e5093e-5033-4abc-9b1b-91c4814fa397	SCC Vertex Development	\N	\N	2025-11-02 20:37:51.859544
bec04587-7596-449c-8623-01bf6b4ed0a4	Tomorrow World Properties	\N	\N	2025-11-02 20:37:51.862318
1af52f70-34bc-4b1f-a9d6-a0e9463b6d5f	FIM Partners	\N	\N	2025-11-02 20:37:51.864693
721a3eeb-3897-41f7-b73d-ffa70d5b7a40	DECA Development	\N	\N	2025-11-02 20:37:51.870033
a6dba6c4-4495-4ab8-b588-4d1a79db3b59	Dubai Properties	\N	\N	2025-11-02 20:37:51.875594
96874cc1-553c-4b43-aa2e-f34f76e7b76f	Centurion Development	\N	\N	2025-11-02 20:37:51.878273
40f6a19d-6357-4ea3-afe3-82236f2f9160	Peak Summit Real Estate Development	\N	\N	2025-11-02 20:37:51.883293
92fb134c-9ec9-4559-9b31-20735cf24b5b	West F5 Development	\N	\N	2025-11-02 20:37:51.891312
745a2f89-c490-4bb8-aae7-167a3da9f4cd	Nabni	\N	\N	2025-11-02 20:37:51.895617
b1d130c1-2d19-4def-8cc1-d8821f34522f	Urban Venture	\N	\N	2025-11-02 20:37:51.899607
357327cf-be51-4004-93e9-2663ed5f9fe3	Pantheon	\N	\N	2025-11-02 20:37:51.90344
0041926b-1b13-46b3-8bd8-af785f0b4e81	Arady Properties	\N	\N	2025-11-02 20:37:51.907487
2d0ba099-33df-4456-bf25-779962d5bc39	Madar Developments	\N	\N	2025-11-02 20:37:51.90882
0e0b323b-fc8c-4381-ad3d-ddff1a6d4277	Ahmadyar Real Estate Development	\N	\N	2025-11-02 20:37:51.913037
1c302aa3-6780-43ed-b39d-f42fa8cd39ef	Swank Development	\N	\N	2025-11-02 20:37:51.914411
8a9237a1-3313-4cab-bfd3-bd966cfd1d38	Expo City	\N	\N	2025-11-02 20:37:51.91573
580e1012-93f2-4583-ad95-6f30fa3b9332	Gulf House Real Estate Development	\N	\N	2025-11-02 20:37:51.917047
b6f4bc21-9601-49d3-b70e-e4e3c075acf6	Alaia Developments	\N	\N	2025-11-02 20:37:51.919686
3211ecd1-f0f7-4504-89ff-40c0ccb5caf4	Roz Real Estate Development	\N	\N	2025-11-02 20:37:51.927149
26956958-8698-46b6-b675-a667e43356b6	Rijas Developers	\N	\N	2025-11-02 20:37:51.932592
80888293-d556-45a2-8bc8-6b27546c397d	Reportage	\N	\N	2025-11-02 20:37:51.940583
2cbfca24-e917-4f69-a2bd-0d449167a3ff	Al Ali Property Investment	\N	\N	2025-11-02 20:37:51.960242
042ae0a2-5de2-47d9-b1b1-0f2c615df675	Acube Developers	\N	\N	2025-11-02 20:37:51.961596
185fb0e6-a324-44f8-ac56-5d09dcfd595c	Irth Development	\N	\N	2025-11-02 20:37:51.963005
85e16f50-94a0-481d-954c-af66269eb3df	Pearlshire	\N	\N	2025-11-02 20:37:51.964488
5708803d-ed29-4e49-8eff-5d41c1dac02c	LIV	\N	\N	2025-11-02 20:37:51.96701
7fed7b2f-b0db-46b9-81db-bc1626463413	Pinnacle A K S Real Estate Development	\N	\N	2025-11-02 20:37:51.970561
27f9d0a5-ce17-4233-80d0-65c6075a77c4	Arabian Gulf Properties	\N	\N	2025-11-02 20:37:51.979478
2acb5e91-bd7f-44d5-b341-5ce95e16bff7	Siroya	\N	\N	2025-11-02 20:37:51.980747
313cf729-8e6d-4e0f-926a-26d7f7b517ca	SAAS	\N	\N	2025-11-02 20:37:51.982109
40d01551-efe5-42e7-8ac5-c71eac1f00ac	Al Mawared Properties	\N	\N	2025-11-02 20:37:51.98464
81346634-8d65-428d-8de8-c58484153bc2	Fortune 5	\N	\N	2025-11-02 20:37:51.985866
634456ed-9932-4366-b361-71d99edf2f9f	Manchester Real Estate	\N	\N	2025-11-02 20:37:51.994405
0118cd54-2c29-474d-841d-39084776548e	Riviera Group	\N	\N	2025-11-02 20:37:51.995666
db473267-33d4-4cd3-ba5a-2d0774f638d2	Seven Tides	\N	\N	2025-11-02 20:37:51.996954
40760df0-74c8-4757-a4e4-a3ae12a0f735	Tranquil Infra Developers	\N	\N	2025-11-02 20:37:52.000794
af5b3f30-89d1-4c5d-a381-cdaca881ed4f	Amaal Development	\N	\N	2025-11-02 20:37:52.002051
5bd02e3b-782e-4e26-8a07-ab92fc3336c7	Januss Developers	\N	\N	2025-11-02 20:37:52.004525
747eb3c4-6dd7-4b5f-9d67-1effc8eaa141	Al Sayyah Group	\N	\N	2025-11-02 20:37:52.006992
0e11d369-e620-4b77-a0e8-f88c03802840	Crystal Bay Development	\N	\N	2025-11-02 20:37:52.008233
30632594-50e4-4a84-93b6-e484858ca209	Svarn Development	\N	\N	2025-11-02 20:37:52.009455
c76bf131-b935-4fff-a32c-ec3ff62f14d1	Yas Developers	\N	\N	2025-11-02 20:37:52.012165
436df9b6-308e-492a-bc67-0c55e4ac874d	Select Group	\N	\N	2025-11-02 20:37:52.018447
12c33103-c496-4379-a8e6-b3bf10a3aa35	Casa Vista & Golden Woods Developers	\N	\N	2025-11-02 20:37:52.019644
377c0417-52b0-4bea-8612-fb10e9f27b0b	Meteora	\N	\N	2025-11-02 20:37:52.023581
7bc1e826-02b9-45bb-a466-f5dbd26aaebf	Rashed Aljabri	\N	\N	2025-11-02 20:37:52.029806
803b633b-c4ea-48bd-b97f-4a5311c450d2	MERED	\N	\N	2025-11-02 20:37:52.033399
11dbe63e-2e4b-42c4-a973-c78f80bac1f7	Mada'in	\N	\N	2025-11-02 20:37:52.034563
7b51a7e4-4dc4-424b-8d73-a1b444122a2e	ONE YARD	\N	\N	2025-11-02 20:37:52.035799
122c8bdc-1431-49d2-8262-df414dc54ab8	Laya Developers	\N	\N	2025-11-02 20:37:52.041103
9d496fff-0235-47e7-bbc7-083af060f2b5	Orange.Life!	\N	\N	2025-11-02 20:37:52.043544
1d85f8c0-5691-48d6-973a-aff4ccaea05c	DMCC	\N	\N	2025-11-02 20:37:52.047106
25f6f063-b89b-4a84-906c-c37512f69861	Aras Development	\N	\N	2025-11-02 20:37:52.048265
6735e9a6-61c8-46f1-9dd3-d70d26eed688	Swiss Property	\N	\N	2025-11-02 20:37:52.05169
47d39177-422c-4e52-b9a2-7d98b015ad9e	Albait Al Duwaliy Real Estate Development	\N	\N	2025-11-02 20:37:52.052908
b9e7316d-0149-474f-96fa-ee6571b49729	GJ Properties	\N	\N	2025-11-02 20:37:52.054079
ddffca4c-ae42-4613-a172-156a775db8dc	National Properties	\N	\N	2025-11-02 20:37:52.055248
160e5ada-5a0d-4ecf-9e8f-df303ff125de	SRG	\N	\N	2025-11-02 20:37:52.056406
6ae7c5d4-4d7b-43a1-ab71-dabc9fa5963e	UniEstate Properties	\N	\N	2025-11-02 20:37:52.059877
bec5ad73-37c2-4261-8644-c88960e28851	The Developer Properties	\N	\N	2025-11-02 20:37:52.064541
19ae94ea-c1d6-4e2f-b034-c2ddab050e8d	Tebyan Real Estate Development Enterprises	\N	\N	2025-11-02 20:37:52.067316
13b2585a-e798-499a-8491-1d872be84fd3	Ithra Dubai	\N	\N	2025-11-02 20:37:52.068487
36fe6b2e-b16c-4862-a378-4404b41ee4e4	Bonyan International Investment Group	\N	\N	2025-11-02 20:37:52.069678
a69dd7b4-c53e-45f5-bbcf-18fcfcd3224c	Gemini Property Developers	\N	\N	2025-11-02 20:37:52.072927
42068ab4-2fc1-4952-ac34-4fe94afa1a5e	Five Holdings	\N	\N	2025-11-02 20:37:52.074005
063b226d-d22d-42f9-ae68-8e2a9853071b	Triplanet Range Developements	\N	\N	2025-11-02 20:37:52.076109
1d5ed922-22d9-4130-9949-d778e4508046	Dar Al Arkan Properties	\N	\N	2025-11-02 20:37:52.077225
9d116d93-4c8c-4c01-82cc-6fc2309c1017	Bloom Heights Properties L.L.C	\N	\N	2025-11-02 20:37:52.079392
60839a3c-88de-449c-b4a1-6c6cf83fe824	Myra Properties	\N	\N	2025-11-02 20:37:52.080486
e501338b-bfd3-455b-a74f-c7a8512af7a5	Aces Property Development L.L.C	\N	\N	2025-11-02 20:37:52.081633
0c5d100e-e84b-4035-820a-a8898d1140d2	CDS Developments	\N	\N	2025-11-02 20:37:52.082759
2f33eb22-edaf-4576-a551-12ce9f237ef7	Bold Living	\N	\N	2025-11-02 20:37:52.083831
ee2b442c-0273-42de-bbb4-9895724e9d6e	WELL Concept RED	\N	\N	2025-11-02 20:37:52.084914
754dcfba-5ca2-4157-984a-e93d75072ac2	Test Developer	\N	\N	2025-11-02 20:58:37.224801
7816ab6e-04e2-4a46-b759-25e9e8b15ef5	Test Developer Direct	\N	\N	2025-11-02 21:02:25.560685
0d92ab87-2add-4981-b169-c01bd9f48aa1	Cirrera Development	\N	\N	2025-11-02 21:42:55.261739
2d651a1b-02b6-4097-9643-15780c2be4fb	ENSO	\N	\N	2025-11-02 21:42:55.274223
a6972647-f568-43cb-8fe9-799aea670099	MVS Real Estate Development	\N	\N	2025-11-02 21:42:55.280648
38c8b3b2-2426-45b7-9175-88438dba20f6	Green Horizon Development	\N	\N	2025-11-02 21:42:55.302674
e8dff1ac-1771-4c52-97ca-9265c7ee45ae	Topero Properties	\N	\N	2025-11-02 21:42:55.316769
7d0313ac-b8a1-442a-a962-501f92b22c54	Tabeer	\N	\N	2025-11-02 21:42:55.334877
6b943c81-024d-4f98-b4ea-30a841a22f9c	Wellington Developments	\N	\N	2025-11-02 21:42:55.342057
a13dd8ca-d6e1-4d9a-8f90-4d2b7102df1e	True Future Real Estate Development	\N	\N	2025-11-02 21:42:55.346041
342af2c3-688b-4e08-a4ad-30a2e1ab23f8	Abou Eid Real Estate Development	\N	\N	2025-11-02 21:42:55.362192
4e3d71dd-2644-44ab-b07f-17f13ee73227	Majid Al Futtaim	\N	\N	2025-11-02 21:42:55.365889
a45adfa1-9f07-48ed-a4d3-ba8f0d2021cd	Empire Developments	\N	\N	2025-11-02 21:42:55.39096
1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	Binghatti	\N	\N	2025-11-02 21:42:55.399727
081fa9d3-a0f7-4d05-ab75-aa99feb00da8	HRE Development	\N	\N	2025-11-02 21:42:55.426394
6577dd65-71ee-4552-9286-4f98df3cc883	Tarrad Development	\N	\N	2025-11-02 21:42:55.432711
3636d588-69e3-4d16-b9a8-725d1bdf8629	Vincitore	\N	\N	2025-11-02 21:42:55.442043
d4b3354c-36e1-4395-ad29-70911062e48d	Dugasta Properties Development	\N	\N	2025-11-02 21:42:55.447248
99645cf2-c7a2-460f-877e-77360827f5de	Casagrand	\N	\N	2025-11-02 21:42:55.462882
3611fe79-1291-46e6-b063-1609fa3131d8	Amirah Developments	\N	\N	2025-11-02 21:42:55.489172
8f713edb-84d7-465d-8744-965901f5d7e7	Leos Development	\N	\N	2025-11-02 21:42:55.533922
a8f3e258-b760-40e9-84d9-58ee3dbdad07	Casa Vista Development	\N	\N	2025-11-02 21:42:55.577382
d0237faa-190d-4fdc-a15f-b0a451b0dbaa	LMD	\N	\N	2025-11-02 21:42:55.626817
437bbab3-070e-4838-b712-56a54b45167d	Black Soil	\N	\N	2025-11-02 21:42:55.651329
349c8063-9c0f-43db-a3ae-d06dc7833bfc	Lamar Development	\N	\N	2025-11-02 21:42:55.655736
0cf130e8-a1e3-4657-9dd6-06a6d9a6dd8a	Confident Group	\N	\N	2025-11-02 21:42:55.674713
3323282f-72a8-48b7-a6c2-8d6380bb0973	AYS Property Development	\N	\N	2025-11-02 21:42:55.695249
0edd8c13-a7a3-4042-98f2-7b74e0791c14	Stamn Development	\N	\N	2025-11-02 21:42:55.714734
268cb9db-0ed0-43b6-bc57-a1ec58075e50	Pasha 1	\N	\N	2025-11-02 21:42:55.725895
5f637246-907f-4e44-9b90-7c3065602155	Sobha	\N	\N	2025-11-02 21:42:55.734099
deaaebdd-4cef-4c79-bb86-7df0a24cd413	Golden Woods	\N	\N	2025-11-02 21:42:55.739934
16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	Meraas	\N	\N	2025-11-02 21:42:55.752562
0aed7712-3f82-4975-8d86-7bcf4076abfe	Symbolic Developments	\N	\N	2025-11-02 21:42:55.757274
727f3a59-7a12-4d51-ad65-563e2b9ff558	Tiger Properties	\N	\N	2025-11-02 21:42:55.761938
6e10dff0-abd2-49b5-9c98-71ec8f1b446f	Omniyat	\N	\N	2025-11-02 21:42:55.773727
a42c2981-0130-49cb-b00d-dc732e2d88c0	Samana	\N	\N	2025-11-02 21:42:55.80325
854e1059-f59d-4ff6-8bf9-368829493fbb	Anax Developments	\N	\N	2025-11-02 21:42:55.819853
3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	Nshama	\N	\N	2025-11-02 21:42:55.825885
b5311f1a-0732-4d83-aa70-ef1778a1ea71	Wadan Developments	\N	\N	2025-11-02 21:42:55.836176
a0e1ea1f-6442-4058-9b2f-0d2c038b516f	Valores Property Development	\N	\N	2025-11-02 21:42:55.850942
10858bd2-9e62-4c95-977d-0de1ed4c3d9c	BnW Developments	\N	\N	2025-11-02 21:42:55.859166
cd0e36ac-7988-43f3-9aa0-b33902187156	Aldar	\N	\N	2025-11-02 21:42:55.871148
c59901e7-ae45-4aec-a968-46bd2e627a3e	Danube	\N	\N	2025-11-02 21:42:55.883572
285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	Damac	\N	\N	2025-11-02 21:42:55.887526
99ffeec2-1bf9-478b-b6a5-29f1a06aaeba	Newbury Developments	\N	\N	2025-11-02 21:42:55.907426
5e76bc8e-626d-4bac-a67f-215db9f997ff	HMB Homes	\N	\N	2025-11-02 21:42:55.967873
33c35d4c-3611-42e4-9043-c83f202fedeb	Meraki Developers	\N	\N	2025-11-02 21:42:55.982629
7ee243f4-7ce8-47ec-98d5-22959269d404	Atmosphere Living	\N	\N	2025-11-02 21:42:56.012034
01a96495-fe84-4b5f-8d33-66eb5b31dcad	HZ Development	\N	\N	2025-11-02 21:42:56.020245
4cf53671-daf4-4685-be03-9329745ae0a3	Nuri Living	\N	\N	2025-11-02 21:42:56.024932
e8a79f19-2efe-4d72-9a9e-0e4ebc39a9ca	Reef Luxury Developments	\N	\N	2025-11-02 21:42:56.055093
213e3c41-196f-436f-ba93-1c5a0d689912	Grid Properties	\N	\N	2025-11-02 21:42:56.058755
95773061-50af-429b-ab24-d3b738a4e758	TownX	\N	\N	2025-11-02 21:42:56.073541
32ac4703-74ea-4f3d-ade8-96cf54c65bb6	Infracorp	\N	\N	2025-11-02 21:42:56.087456
11570d4f-1857-4fbe-ad1e-b96b23517513	Grovy Real Estate Development	\N	\N	2025-11-02 21:42:56.09483
b4a3fbad-46eb-4799-8e96-8f9c8e68c554	Unique Saray	\N	\N	2025-11-02 21:42:56.105438
2fdc703a-9a4e-4dc7-9ff4-61f71970b5e9	ARIB Developments	\N	\N	2025-11-02 21:42:56.122601
011a56d6-22b9-4e65-a12d-dbbd170458b5	City View Development	\N	\N	2025-11-02 21:42:56.172139
37ec3b05-f9ee-4770-bc0e-2aeaf2df57df	Al Tareq Star Real Estate Development	\N	\N	2025-11-02 21:42:56.189621
9ac691dd-fc8e-4f5a-8a06-e72173cbc5ab	Prestige One	\N	\N	2025-11-02 21:42:56.209735
6ad5348a-4fe7-4ee9-b98b-aa545a89e019	Iman Developers	\N	\N	2025-11-02 21:42:56.218887
043afefa-17ab-488c-93ff-b781995b857d	One Development	\N	\N	2025-11-02 21:42:56.249165
7d6bd1e9-574b-4682-b1b0-f6ef56f1dcae	ARADA	\N	\N	2025-11-02 21:42:56.265936
2bef585a-c3c2-460f-abf2-64c54d018053	Manam RED	\N	\N	2025-11-02 21:42:56.283605
ceb370e3-0562-4a9d-974c-ba77713c7b5c	AMWAJ Development	\N	\N	2025-11-02 21:42:56.304087
3e7baa61-256f-4abd-9603-57f6cf367106	Lapis Properties	\N	\N	2025-11-02 21:42:56.327247
2ce0c346-938b-4984-b686-5fbf92f65fbc	Mulk Properties	\N	\N	2025-11-02 21:42:56.332922
9caa94ea-ce2e-4bf5-bf95-b8f6f61a8e75	Avelon Developments	\N	\N	2025-11-02 21:42:56.355592
1c770976-459d-4f31-9dba-3fa8161b0fd8	Bling Development	\N	\N	2025-11-02 21:42:56.36077
1d615bb7-3aee-46d9-a084-bd77590328f0	OCTA Development	\N	\N	2025-11-02 21:42:56.364468
5ef5c942-6e90-430d-b8ba-eb466d332c4d	Me Do Re	\N	\N	2025-11-02 21:42:56.375302
62e4c532-429d-485b-bb6e-2342d13e665b	Citi Developers	\N	\N	2025-11-02 21:42:56.378699
d455a56f-fc60-458a-864a-efe2ca9f6df1	Majid Developments	\N	\N	2025-11-02 21:42:56.385087
160f8678-e67b-4617-bd1b-69f252f451da	IKR Development	\N	\N	2025-11-02 21:42:56.388479
35f5e2f9-6f3f-4b6b-bd91-465e583df72b	AYAT Development	\N	\N	2025-11-02 21:42:56.402223
087f0279-b93a-4dc1-aab3-0735b577e84e	Mashriq Elite Real Estate Development	\N	\N	2025-11-02 21:42:56.413977
85da470d-ea6e-4b00-ad63-d22a52b5dced	Hayaat Developments	\N	\N	2025-11-02 21:42:56.418635
4b39b795-8d4c-4141-b0e7-2d6e9a8ba72f	DarGlobal	\N	\N	2025-11-02 21:42:56.445368
012910c3-b7c5-4260-8f83-919436c52ab7	MAAIA Developers	\N	\N	2025-11-02 21:42:56.448749
506e86f8-e9a6-4cf0-87d2-a7db97ac97b9	Ginco Properties	\N	\N	2025-11-02 21:42:56.529409
4b4be146-17ea-4781-ac9d-a76499af62d8	S&S Developments	\N	\N	2025-11-02 21:42:56.543215
b99a2707-a8ba-4b3f-a4d2-ed2cf388a8a9	Mira Developments	\N	\N	2025-11-02 21:42:56.546665
48841087-0b08-4dbe-837e-7e87737849d9	Zenith Ventures Real Estate Development	\N	\N	2025-11-02 21:42:56.553612
5b8b35fb-2293-44cf-bb20-a1dd6ecd4d5e	Ever Glory Developments	\N	\N	2025-11-02 21:42:56.559771
83505ce5-4591-436e-9a41-2c69c0108b0f	Palma Development	\N	\N	2025-11-02 21:42:56.585401
1f23062c-cf5e-4891-ac2b-8045bb65b65e	Regent Developments	\N	\N	2025-11-02 21:42:56.607528
47bc978d-34b3-4000-bc2b-4e1216920aeb	ADE Properties	\N	\N	2025-11-02 21:42:56.623718
43273c82-1e85-43bb-9d05-e9b2ae9c2e0f	Oksa Developer	\N	\N	2025-11-02 21:42:56.642491
526a05d5-8cbd-4749-9067-ea34da40c35e	Al Seeb Real Estate Development	\N	\N	2025-11-02 21:42:56.652745
6617d5c6-80a6-4d8c-b92a-8fc64a09c3c8	Mill Hill	\N	\N	2025-11-02 21:42:56.658408
552c1026-d364-4ea2-95ff-65710cce5b5d	Condor	\N	\N	2025-11-02 21:42:56.661971
b1781062-53b7-4448-a786-f2bab2542727	Prescott Development	\N	\N	2025-11-02 21:42:56.665851
4aa6000a-30a9-4069-a021-62b731ed9c4f	Vantage Ventures	\N	\N	2025-11-02 21:42:56.669437
0ab53acf-bb57-47bc-8291-3dee23232e18	Heilbronn Properties Ltd.	\N	\N	2025-11-02 21:42:56.672581
15c1585b-4896-460c-9554-4298141fb1f3	Nexus	\N	\N	2025-11-02 21:42:56.676258
4141aec9-21ce-4490-8df8-f81950a8242f	Green Group	\N	\N	2025-11-02 21:42:56.680237
4a3d26da-ed01-40c1-aba3-778761748561	SABA Properties	\N	\N	2025-11-02 21:42:56.683752
0f7c019a-0553-415e-9c8f-d37bdb0fb1d6	Ag Properties	\N	\N	2025-11-02 21:42:56.730115
48b7a963-81b0-47db-ac01-5ce171b0a57c	Glorious Future	\N	\N	2025-11-02 21:42:56.774291
be42958b-d8c4-401b-8619-0b0cedcdd5c5	Aqua	\N	\N	2025-11-02 21:42:56.785918
0b2242eb-087d-487b-984e-5d529cc4c380	EMS Development	\N	\N	2025-11-02 21:42:56.799387
1b338acc-2755-400d-a415-3a983f896d20	Kasco Real Estate Development	\N	\N	2025-11-02 21:42:56.816266
0e9a7b4c-dcea-4e7c-8d11-a232c5ddafb1	Vantage Developments	\N	\N	2025-11-02 21:42:56.826707
b9e3db1f-eda1-44b1-8332-62be8b825be8	H&H Development	\N	\N	2025-11-02 21:42:56.830402
11f94184-adb1-4ac0-b41e-0fa99203b5ed	DV8 Developers	\N	\N	2025-11-02 21:42:56.84113
603248a2-002d-4a62-8f0f-6f6758bb124f	Arsenal East	\N	\N	2025-11-02 21:42:56.892003
460b5059-9409-43e7-b7a1-c9c78727daf8	SIDO Developer	\N	\N	2025-11-02 21:42:56.923848
97585794-da8b-483e-8ee8-eefe8f66fa43	NED Properties	\N	\N	2025-11-02 21:42:56.937611
33f0f509-0aaf-499e-8557-9ecc46fcf990	MS Homes	\N	\N	2025-11-02 21:42:56.95801
561fbee3-e86f-45d6-8539-fc385b1fe3d2	PG Properties	\N	\N	2025-11-02 21:42:56.965152
041913a8-13d7-47ec-b576-4705512c83ac	Time Properties	\N	\N	2025-11-02 21:42:56.971329
b1a9c547-6be6-4905-b1fe-73a103b0d4d0	Urban Properties	\N	\N	2025-11-02 21:42:57.034442
7f9e7c95-ca62-47ae-8388-5e4d22362c86	Union Properties	\N	\N	2025-11-02 21:42:57.037116
38bcb8fc-3257-4311-90fa-8a5712e8ec0a	Karma Development	\N	\N	2025-11-02 21:42:57.054155
7c89a325-c002-4997-bdce-842f3a4c1771	Vakson First Property Development	\N	\N	2025-11-02 21:42:57.063239
514a33cd-4a28-4acd-a796-47147d8869cc	Galaxy Realty	\N	\N	2025-11-02 21:42:57.104227
a11dafe3-3354-4f2c-863b-1917905fd9f7	ABA Real Estate Development	\N	\N	2025-11-02 21:42:57.110802
032304fb-fc12-40e2-8ff8-bee6699c0b0d	Gulf Land Property Developers	\N	\N	2025-11-02 21:42:57.115561
6db578c9-b07e-4778-abc6-fb33ce70d277	Iraz Developments	\N	\N	2025-11-02 21:42:57.123623
5d91183a-b2e6-4072-95fd-a408857cd44c	Sama Ezdan	\N	\N	2025-11-02 21:42:57.137414
31f110a8-7428-43b4-a91e-ab7e13c58595	AMBS Real Estate Development	\N	\N	2025-11-02 21:42:57.167354
7476b6f6-9c5d-44f4-80e2-f254031f4964	Muraba Properties	\N	\N	2025-11-02 21:42:57.18581
723ce433-e943-43c4-b416-25e3cac11fdc	The 100	\N	\N	2025-11-02 21:42:57.196683
36e9f280-55ae-417d-9730-075feb51ed84	Lucky Aeon	\N	\N	2025-11-02 21:42:57.200862
1ff4a488-52a3-4779-aa13-8aa0a6651aa6	Arista Properties	\N	\N	2025-11-02 21:42:57.203658
85f34ca0-84b8-4638-a6c5-2e55353e9f8d	Sankari Property	\N	\N	2025-11-02 21:42:57.209037
68607746-dd6d-42bf-8ebb-36d8a9d7bba7	East & West Properties	\N	\N	2025-11-02 21:42:57.231259
a1854004-59ab-4cd2-a89f-9d2f22c5130a	Al Habtoor Group	\N	\N	2025-11-02 21:42:57.247138
7ddbd659-2584-4bec-8e99-def860eaffd2	Metac Development	\N	\N	2025-11-02 21:42:57.304972
d9f29021-91e5-4324-843d-990cb7733f9c	Dar Al Karama	\N	\N	2025-11-02 21:42:57.313392
e96f8225-8f64-4d77-9f6c-5a53d89dd69d	Kappa Acca Real Estate Development	\N	\N	2025-11-02 21:42:57.317824
9ece548a-5211-4966-b1e1-e45c7943fa4f	B N H Real Estate Developer	\N	\N	2025-11-02 21:42:57.330193
0d9fe3ae-dfe1-4e55-a775-c00afb116de3	Premier Choice	\N	\N	2025-11-02 21:42:57.381849
7e7cb721-5edf-428b-8097-ed48a0e32fb9	Khamas Group	\N	\N	2025-11-02 21:42:57.395466
46244c19-1223-4c52-9da6-55149c5e3538	Naseeb Group	\N	\N	2025-11-02 21:42:57.427321
67f5aab0-438f-4003-be9f-1ae5d83638f4	IGO	\N	\N	2025-11-02 21:42:57.429852
b9d1bc58-eb15-408d-ad99-96b1e4c32090	Zumurud Real Estate - Sole Proprietorship	\N	\N	2025-11-02 21:42:57.555398
613fbfee-a324-4dcc-9171-4250d1bdd082	A S I Real Estate Development	\N	\N	2025-11-02 21:42:57.557747
b959b878-b6ea-49ed-be77-fe3cf58e4ac1	Oro 24	\N	\N	2025-11-02 21:42:57.586721
01165192-e54e-4462-a26a-1d25fb43ef67	C Fourteen	\N	\N	2025-11-02 21:42:57.606959
2b26e7a0-973d-4322-a459-9a15ca2bf683	The First Group	\N	\N	2025-11-02 21:42:57.610195
088d080f-1e60-46e1-933b-30b62400b221	SOL Properties (managed by You&Co)	\N	\N	2025-11-02 21:42:57.616267
8f550297-85dc-49ea-b052-09148a7f9709	Alta Real Estate Development	\N	\N	2025-11-02 21:42:57.678287
4f6abe53-a3ea-461e-acab-913d3731d66e	Green Yard Properties Development	\N	\N	2025-11-02 21:42:57.691572
6766f261-20e5-4ab5-9ba8-065c34360da0	Escan Real Estate	\N	\N	2025-11-02 21:42:57.708523
538c3f6b-28d9-4c28-986f-15abbd0a3c9d	Emirates National Investment	\N	\N	2025-11-02 21:42:57.73303
378511a2-e46d-48ad-88a8-72584c46191c	Mr. Eight	\N	\N	2025-11-02 21:43:05.866358
6782ccc1-f602-40f2-b1f9-2360519488e2	Segrex Development	\N	\N	2025-11-02 21:43:05.88467
ef6ff897-a25c-4bfb-b3f3-f11c41492ee6	Major Developments	\N	\N	2025-11-02 21:43:05.89041
bb633fa5-9394-484e-a17b-feaaf78ce422	Palladium Development	\N	\N	2025-11-02 21:43:05.897146
e155b5fb-b446-446a-b47d-90bc8f6d55d6	Vision developments	\N	\N	2025-11-02 21:43:05.90382
b52fa283-ff1a-4047-b20e-92537a522889	Emaar Properties	\N	\N	2025-11-02 21:43:05.906825
930bd2d2-cfc4-4ae6-8d21-0a27559e4030	AMIS Properties	\N	\N	2025-11-02 21:43:05.910138
8147c5dd-d275-4d04-84d4-4fce9ce87e0e	Rabdan Real Estate Developments	\N	\N	2025-11-02 21:43:05.921997
d5689e4a-18d7-4a2a-87f6-5aa334be13a9	Ellington	\N	\N	2025-11-02 21:43:05.930731
7c08726a-4e53-4d93-a5a1-5b8df7b407da	Imtiaz	\N	\N	2025-11-02 21:43:05.934253
d6473fdf-38b7-4cf9-be95-c2b2a32f8a3d	Forum Real Estate Development	\N	\N	2025-11-02 21:43:05.9375
b8070f8b-8568-4d29-af7a-6f55156d0233	BT Properties	\N	\N	2025-11-02 21:43:05.946606
336d541b-8383-44f1-8e00-15f663df4b51	Rvl Real Estate	\N	\N	2025-11-02 21:43:05.951779
da59d484-2f29-4f4b-849b-6f69819597ac	SOL Properties	\N	\N	2025-11-02 21:43:05.967746
4b47b8ee-6457-403f-81cf-12bbbf751d23	London Gate	\N	\N	2025-11-02 21:43:05.974225
c8156430-944d-4829-9d5e-964b1bf8c792	Arete Developments	\N	\N	2025-11-02 21:43:05.981296
9d128f32-1c6c-474d-b911-61803444decc	Object One	\N	\N	2025-11-02 21:43:05.984717
74c7e714-1039-4845-b648-5c575084c119	7th Key	\N	\N	2025-11-02 21:43:05.990422
75028747-cbc2-42d0-b3ab-d598d854c10d	New MFOUR Real Estate Development	\N	\N	2025-11-02 21:43:05.994498
a90315f8-75de-4e44-bd69-d890cae817b0	Tasmeer Indigo Properties	\N	\N	2025-11-02 21:43:06.018996
b634bdb5-0543-4401-bc7a-d5a9dbf181a7	AHS Properties	\N	\N	2025-11-02 21:43:06.025386
562c648e-bd2d-453f-83dc-6595824a64d8	Deyaar	\N	\N	2025-11-02 21:43:06.030818
26973590-be04-4f9c-a384-25536dc2ba8d	QUBE Development	\N	\N	2025-11-02 21:43:06.035241
823c1424-3caa-4a77-97e7-553cd5f04f2d	AB Developers	\N	\N	2025-11-02 21:43:06.039482
d190bf02-5336-42e6-bba1-91ee1ab4b2d5	Nakheel	\N	\N	2025-11-02 21:43:06.048612
7aa8d80f-f1da-438b-a8ac-a57d0b201cd8	Fakhruddin Properties	\N	\N	2025-11-02 21:43:06.052805
fe699655-b30d-4690-b8f7-bb62ac05dadf	Credo Investments	\N	\N	2025-11-02 21:43:06.057899
b638b075-b76f-42d5-8455-ee7474f84d79	Azizi	\N	\N	2025-11-02 21:43:06.064498
b8fb9b75-948a-4296-82c3-953c9d1bc61e	Peace Homes Development	\N	\N	2025-11-02 21:43:06.079562
d91870ea-e002-4706-b7d4-0251346ea15a	DHG Real Estate Group	\N	\N	2025-11-02 21:43:06.086084
7b5842d5-1b0f-4c98-900e-f6d8112df185	Beyond	\N	\N	2025-11-02 21:43:06.09667
6a6bd530-ed34-4c83-8524-d06836cf429e	Iquna Properties	\N	\N	2025-11-02 21:43:06.115433
ba852eb1-4aa8-42a9-af72-47201dd387bc	Elysian Development	\N	\N	2025-11-02 21:43:06.12034
940f3091-35c4-4af6-b1e5-eb9804af0d8c	AUM Development	\N	\N	2025-11-02 21:43:06.132325
915b0a0a-177f-48b2-abfc-6c79d4ea741a	Barco Developers	\N	\N	2025-11-02 21:43:06.13528
d5dfad6f-2582-4be3-89ae-c5625e33a996	MAG Property Development	\N	\N	2025-11-02 21:43:06.150632
d40a0781-0f89-4ee7-8edb-0d371bceadae	Zimaya Properties	\N	\N	2025-11-02 21:43:06.157935
e0b7a2e8-0ba5-44cc-8ae0-f2450afb524a	Wasl	\N	\N	2025-11-02 21:43:06.163762
859f7e44-eab3-46ce-9366-53c19ef3cffb	Skyline Builders	\N	\N	2025-11-02 21:43:06.17119
d512be0a-9cdd-4edc-9e4c-b5dc93232758	MAK Developers	\N	\N	2025-11-02 21:43:06.175524
a84f875a-d9e5-456e-a713-29a09b730d2a	Avenew Development	\N	\N	2025-11-02 21:43:06.18124
e7cf121d-3ef4-4943-a36a-a5dc0d8f00ec	Shakirov Developments	\N	\N	2025-11-02 21:43:06.205901
ff247dca-88f3-41ab-96c8-84b760a6c768	Marquis	\N	\N	2025-11-02 21:43:06.208714
a5fa31f8-5b72-4718-a5d1-2c22a14d0782	Taraf	\N	\N	2025-11-02 21:43:06.21771
87cc7df8-ee5d-4f2a-9a75-21616d1ec6a3	Elton Real Estate Development	\N	\N	2025-11-02 21:43:06.221991
8e755238-bd3c-4c95-a877-c4b679ad0b94	Maakdream Properties	\N	\N	2025-11-02 21:43:06.229802
a73a2a07-60b2-4148-971d-e663a13fc0ad	AMBER Developments	\N	\N	2025-11-02 21:43:06.255933
e0931680-f521-469b-8c27-42de9933fb4c	Dubai South	\N	\N	2025-11-02 21:43:06.258961
de44570c-141e-4809-a5a9-9dbc9556999c	The Heart of Europe	\N	\N	2025-11-02 21:43:06.261384
e1cda1ae-5c7b-4a98-8194-83279c7a1d5d	SCC Vertex Development	\N	\N	2025-11-02 21:43:06.273971
e939ccf8-e520-4b87-82b1-fa43b179ccc6	Tomorrow World Properties	\N	\N	2025-11-02 21:43:06.282144
edcece73-1333-439c-b5ed-30f2cf1443af	FIM Partners	\N	\N	2025-11-02 21:43:06.285063
eb6b2103-6b04-4464-86b2-7a5e0d082452	DECA Development	\N	\N	2025-11-02 21:43:06.300733
d62dd549-3ac4-4f60-bbc6-b2eb7dedf5b8	Dubai Properties	\N	\N	2025-11-02 21:43:06.335396
dee72273-e224-48e8-b4f8-9acc72306a94	Centurion Development	\N	\N	2025-11-02 21:43:06.347782
919708eb-abe9-4e30-b104-990f07b7a9c2	Peak Summit Real Estate Development	\N	\N	2025-11-02 21:43:06.360745
f6337bc9-ff93-46d6-b8a7-875c52b5bf7c	West F5 Development	\N	\N	2025-11-02 21:43:06.374176
918debfb-40e2-4fb6-b357-ce145abb1fbf	Nabni	\N	\N	2025-11-02 21:43:06.38109
fa973820-d554-4ddd-941e-d6edb580e70c	Urban Venture	\N	\N	2025-11-02 21:43:06.387594
a8c243a7-ac10-4ed9-a660-d05ee9b7ca60	Pantheon	\N	\N	2025-11-02 21:43:06.398872
070d7165-6484-4529-a35b-b8243677e229	Arady Properties	\N	\N	2025-11-02 21:43:06.415574
56ee7ade-96e8-483c-b2e4-7734335eacf9	Madar Developments	\N	\N	2025-11-02 21:43:06.418373
e3027be7-b577-4695-abbe-4d676b3667ed	Ahmadyar Real Estate Development	\N	\N	2025-11-02 21:43:06.439797
66b21269-e00c-43f6-9877-fe1e96f961fd	Swank Development	\N	\N	2025-11-02 21:43:06.462285
6a09ba6f-ee6e-4928-a2cb-193aef26db85	Laraix	\N	\N	2025-11-02 21:43:06.46429
f152c1f4-6ec3-4c04-8438-a8190b3b68de	Expo City	\N	\N	2025-11-02 21:43:06.484046
d4806be0-1e85-4fe0-8a32-d8a7e98fc72e	Gulf House Real Estate Development	\N	\N	2025-11-02 21:43:06.486889
ea962861-233a-4782-8270-9dec56e616c5	Alaia Developments	\N	\N	2025-11-02 21:43:06.496735
b095241c-35b6-4088-bc89-60827819da86	Roz Real Estate Development	\N	\N	2025-11-02 21:43:06.518343
c3dde52b-a111-456b-b000-a0ad359199a1	Rijas Developers	\N	\N	2025-11-02 21:43:06.562559
f810a543-a616-442d-b964-99e9d3cb8e11	Reportage	\N	\N	2025-11-02 21:43:06.573724
736859dd-b040-4f6e-82c5-8a1c4b0b8f23	Al Ali Property Investment	\N	\N	2025-11-02 21:43:06.599075
f937a811-2827-40a6-a476-25e4dc248127	Acube Developers	\N	\N	2025-11-02 21:43:06.617983
f62d2c43-fdd2-42ca-a285-58271ad51d03	Irth Development	\N	\N	2025-11-02 21:43:06.625851
e705edd8-148f-473b-8694-c22aaede2859	Pearlshire	\N	\N	2025-11-02 21:43:06.629437
8c05fb6a-02a5-434a-a584-09ab3ac7d67c	LIV	\N	\N	2025-11-02 21:43:06.637167
f882965f-35fa-4483-9652-0d429c776d09	Pinnacle A K S Real Estate Development	\N	\N	2025-11-02 21:43:06.668314
c05eb1e7-0720-4b45-8bc5-6c86b1efb977	Arabian Gulf Properties	\N	\N	2025-11-02 21:43:06.708875
6ba52c81-99af-4838-951e-16e6d4e7a057	Siroya	\N	\N	2025-11-02 21:43:06.722168
518dfa5d-38e9-4f39-b2b1-7d543b332cb9	SAAS	\N	\N	2025-11-02 21:43:06.729732
58f85f83-676e-493e-836c-48a308084479	Al Mawared Properties	\N	\N	2025-11-02 21:43:06.77026
9ec513c1-685a-4c58-b25d-e6cbc636b894	Fortune 5	\N	\N	2025-11-02 21:43:06.773094
98de99b1-9599-4bea-bd9b-23a7b3ec1f8a	Riviera Group	\N	\N	2025-11-02 21:43:06.839393
f605b496-c28f-452d-b005-c5f1a77748fc	Seven Tides	\N	\N	2025-11-02 21:43:06.841276
7331f038-7b3e-4359-8f89-e23a2f080bb9	Tranquil Infra Developers	\N	\N	2025-11-02 21:43:06.861162
c1ea77b0-4cd5-470a-8fb4-70b3b14f5442	Amaal Development	\N	\N	2025-11-02 21:43:06.869015
7fd8611b-101f-4330-8412-747e19f6a03a	Januss Developers	\N	\N	2025-11-02 21:43:06.874958
b8f64de0-e740-47ce-9fd4-0acb0a1037ee	Al Sayyah Group	\N	\N	2025-11-02 21:43:06.884126
9f67106b-4370-4084-b925-9c601f3c0deb	Crystal Bay Development	\N	\N	2025-11-02 21:43:06.888086
6a29a5e4-6067-4ba8-845d-498af9a81c79	Svarn Development	\N	\N	2025-11-02 21:43:06.890753
d590865e-aad9-42c8-b68e-c02693960240	Yas Developers	\N	\N	2025-11-02 21:43:06.913586
e5e2dd29-98f2-4191-8f60-5eb6dc3cad47	Select Group	\N	\N	2025-11-02 21:43:06.939522
473bcd76-c441-4ac5-b6de-b68468c54b34	Casa Vista & Golden Woods Developers	\N	\N	2025-11-02 21:43:06.954117
fb4692a7-86dc-4258-85b6-c25bebac8361	Meteora	\N	\N	2025-11-02 21:43:06.979419
89db6da6-014b-4199-bada-74e94dca2987	MERED	\N	\N	2025-11-02 21:43:07.040233
c4c61e8a-fb15-41ce-8ae9-68fe535bfd61	Mada'in	\N	\N	2025-11-02 21:43:07.053433
f7df9890-0677-44aa-9ad3-dd3826a235d3	ONE YARD	\N	\N	2025-11-02 21:43:07.068745
42e7ce4f-1170-4048-a329-a2deca8e8155	Laya Developers	\N	\N	2025-11-02 21:43:07.094502
bacd3d97-a234-40e2-ba5b-8676e52b60da	Orange.Life!	\N	\N	2025-11-02 21:43:07.109377
ab652251-7fa5-453d-b5f6-58b781fce89b	DMCC	\N	\N	2025-11-02 21:43:07.175038
48b7c726-9e46-4ca6-a33a-3fbdac7f59df	Aras Development	\N	\N	2025-11-02 21:43:07.179565
97eb81d9-3fdf-41e7-a755-8edd7dd452d4	Swiss Property	\N	\N	2025-11-02 21:43:07.198396
987b03aa-8763-4914-b617-14db66cc1a0d	Albait Al Duwaliy Real Estate Development	\N	\N	2025-11-02 21:43:07.207998
e2a13819-82db-42ef-8e4a-7f032f505483	GJ Properties	\N	\N	2025-11-02 21:43:07.259463
e7a986d2-b373-4dc8-9e18-2773bb89196a	National Properties	\N	\N	2025-11-02 21:43:07.274322
c238e765-c565-4254-bdaa-cfc6436228d1	SRG	\N	\N	2025-11-02 21:43:07.281385
a5117555-5abc-43cb-b185-2bbaea11e442	UniEstate Properties	\N	\N	2025-11-02 21:43:07.329508
d85b9fd0-43cf-4fc6-b55c-be404a13216d	The Developer Properties	\N	\N	2025-11-02 21:43:07.374053
9c2c1f0d-f2cc-4b8a-8805-b8342818550c	Tebyan Real Estate Development Enterprises	\N	\N	2025-11-02 21:43:07.382936
a7f8b821-2ea7-47e5-8816-9e0faa539e24	Ithra Dubai	\N	\N	2025-11-02 21:43:07.428822
528973c5-b454-4be0-a1f7-eebcabb2a9e9	Bonyan International Investment Group	\N	\N	2025-11-02 21:43:07.43611
ab7309fe-f4bc-4c87-a6a0-e6d0cf4a4cd6	Gemini Property Developers	\N	\N	2025-11-02 21:43:07.464101
c636e99b-1eeb-4ac6-81f9-4e4277b67681	Five Holdings	\N	\N	2025-11-02 21:43:07.468612
43bfecc8-91eb-4c77-9696-ff85ecd40e95	Triplanet Range Developements	\N	\N	2025-11-02 21:43:07.481377
9fa4bb66-b625-4832-b192-317c10120d60	Dar Al Arkan Properties	\N	\N	2025-11-02 21:43:07.500544
a26fdd28-bae5-458a-bcfc-6a45d9e2d2d4	Myra Properties	\N	\N	2025-11-02 21:43:07.543458
fc46aaf9-7bd6-4149-bdae-d6ae3414f690	Aces Property Development L.L.C	\N	\N	2025-11-02 21:43:07.555314
\.


--
-- Data for Name: facilities; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.facilities (id, "nameEn", "nameRu", "nameAr", "iconName", "createdAt") FROM stdin;
fb75b270-71b9-4b9d-8d59-1f107c1c8f5f	Swimming Pool	Swimming Pool	Swimming Pool	water	2025-11-01 14:35:15.54262
8c5cfbce-fe7d-469e-bc7d-3b66fdf1e0c5	Gym	Gym	Gym	fitness	2025-11-01 14:35:15.546808
65f25261-fe72-4a1e-862c-af9885f9e2d9	Parking	Parking	Parking	car	2025-11-01 14:35:15.548782
ccd05a45-e8aa-4dda-961a-38613bd97ebd	24/7 Security	24/7 Security	24/7 Security	shield-checkmark	2025-11-01 14:35:15.551181
a64561a6-e1e9-4c8f-9c5b-46f58c98266c	Kids Play Area	Kids Play Area	Kids Play Area	happy	2025-11-01 14:35:15.553289
61af8938-fc45-4b7b-a239-c5876e59407b	BBQ Area	BBQ Area	BBQ Area	flame	2025-11-01 14:35:15.554822
b9dded26-4003-4757-839a-0dc4e197a73f	Beach Access	Доступ к пляжу	وصول الشاطئ	beach	2025-11-01 14:37:20.57853
bb9a55aa-4bcd-430d-83d2-92ad27a24690	Shared Pool	Общий бассейн	بركة مشتركه	shared-pool	2025-11-02 20:39:51.033547
f94c9cc9-8d72-400b-9b14-2a48595def26	Concierge Service	Консьерж-сервис	خدمة الكونسيرج	concierge-service	2025-11-02 20:39:51.054846
00ca1251-b52f-4fda-913e-f245afe098e1	Security	Охрана	حماية	security	2025-11-02 20:39:51.059913
f8ea2226-c4f2-4dbb-9097-491738baa3b8	Lobby	Лобби	ردهة	lobby	2025-11-02 20:39:51.062513
715ac9fe-6ee4-4266-90c3-1c9621bfe8d6	Central A/C & Heating	Центральный кондиционер и отопление	تدفئة وتكييف مركزي	central-ac-heating	2025-11-02 20:39:51.064981
5150beb7-f73a-4237-badd-9ba9c787d2b1	Covered Parking	Крытый паркинг	مواقف مغطاة للسيارات	covered-parking	2025-11-02 20:39:51.066712
c3fecf59-3a0e-4fed-81ec-bb4418aa77f4	Shared Jacuzzi	Общее джакузи	جاكوزي مشترك	shared-jacuzzi	2025-11-02 20:39:51.068255
40a76d95-493a-4892-892b-0300315c820f	Shared SPA	Общий SPA	صالون سبا مشترك	shared-spa	2025-11-02 20:39:51.069999
91810ae7-c0e6-47e0-90b7-5a2f22f3f020	Children's pool	Детский бассейн	حمام سباحة للأطفال	childrens-pool	2025-11-02 20:39:51.073554
6a8df41d-7f13-4d00-b84e-6a6fa64c084f	Pets Allowed	Домашние животные разрешены	مسموح بدخول الحيوانات الأليفة	pets-allowed	2025-11-02 20:39:51.076029
c1f4e809-a2b0-4b1b-aaed-7553b18dc4a0	Broadband Internet	Широкополосный Интернет	الإنترنت ذات النطاق العريض	broadband-internet	2025-11-02 20:39:51.07759
1d6c96f5-2455-47d9-8736-909630be38e4	ATM Facility	Банкоматы	مرفق أجهزة الصراف الآلي	atm-facility	2025-11-02 20:39:51.079138
3290472e-9fbd-49b0-a1ed-d573e4e7b99d	Laundry Room	Прачечная	غسيل	laundry-room	2025-11-02 20:39:51.080618
becd4911-5fad-4813-b9e2-a14aa05c44fd	Intercom	Переговорное устройство	انتركم	intercom	2025-11-02 20:39:51.082029
3e4c95b2-fd81-4a81-bb71-cf20b8affa73	Storage Areas	Складские помещения	مناطق التخزين	storage-areas	2025-11-02 20:39:51.084687
2d84748f-35cb-4668-9647-43e61fdb392a	Facilities for Disabled (accessibility)	Доступность для людей с ограничениями	مرافق لذوي الاحتياجات الخاصة (سهولة الوصول)	facilities-for-disabled-accessibility	2025-11-02 20:39:51.086328
2cee5ce7-b44d-4d9e-923f-cf4aca1fd673	Electric Car Charger	Зарядка для электроавтомобиля	شاحن سيارة كهربائي	electric-car-charger	2025-11-02 20:39:51.088998
0cc2f4ee-ca63-4b60-80ab-6fffb3692972	Test Facility	Тест	اختبار	test	2025-11-02 20:59:00.900922
\.


--
-- Data for Name: news; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.news (id, title, description, "imageUrl", "isPublished", "publishedAt", "createdAt", "updatedAt") FROM stdin;
7ee50904-409d-4967-ba49-ecd5b4628194	Dubai Real Estate Boom	Market is thriving	https://example.com/news.jpg	t	\N	2025-11-01 14:38:19.623954	2025-11-01 14:38:19.623954
693928e1-562d-4954-afc4-1e75d337e10c	sfmpasmf	asfkasmfok	https://res.cloudinary.com/dgv0rxd60/image/upload/v1762093960/properties/baqs4y3zu3vaozkjwtes.png	t	2025-11-02 14:32:44.352+00	2025-11-02 14:32:44.432728	2025-11-02 14:32:44.432728
\.


--
-- Data for Name: news_contents; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.news_contents (id, "newsId", type, title, description, "imageUrl", "videoUrl", "order") FROM stdin;
02bdb2cf-bb7e-495e-a51d-12aa9e31567e	7ee50904-409d-4967-ba49-ecd5b4628194	text	Article Start	News content here	\N	\N	1
1dd26585-e8aa-402b-9621-c0daa442dfcc	693928e1-562d-4954-afc4-1e75d337e10c	text	saklfmasf	salkmfaskmf	\N	\N	0
\.


--
-- Data for Name: properties; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.properties (id, "propertyType", name, photos, "countryId", "cityId", "areaId", latitude, longitude, description, "developerId", "priceFrom", "bedroomsFrom", "bedroomsTo", "bathroomsFrom", "bathroomsTo", "sizeFrom", "sizeTo", "paymentPlan", price, bedrooms, bathrooms, size, "createdAt", "updatedAt") FROM stdin;
cd431336-7ee0-45dc-a834-e6bf230f0602	off-plan	Interstellar Tower	https://files.alnair.ae/uploads/2025/8/16/5c/165cf1ccac4c31c7f0ae121ab1a2e35b.jpg,https://files.alnair.ae/uploads/2025/7/44/e5/44e5aee152da661401863774cdb42297.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03763325	55.17955596	Off-plan property: Interstellar Tower by Mr. Eight	378511a2-e46d-48ad-88a8-72584c46191c	311712.00	1	2	1	2	63.27	390.29	\N	\N	\N	\N	\N	2025-11-02 21:43:05.869949	2025-11-02 21:43:05.869949
86f31645-39b5-4028-8f80-0730fb715ce7	off-plan	Capital Horizon Terraces	https://files.alnair.ae/uploads/2025/7/62/b2/62b21ac14c084d79cc8dab08259c690e.jpg,https://files.alnair.ae/uploads/2025/7/69/ae/69ae40160c30c713e2680ebc9c4c4fd4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29898595	55.31639680	Off-plan property: Capital Horizon Terraces by Cirrera Development	0d92ab87-2add-4981-b169-c01bd9f48aa1	564650.24	1	3	1	3	68.50	370.37	\N	\N	\N	\N	\N	2025-11-02 21:43:05.874748	2025-11-02 21:43:05.874748
378ed650-fd95-4d9d-b360-b701711b9ed3	off-plan	Amber by Enso	https://files.alnair.ae/uploads/2025/7/56/a2/56a25461e08b5ab6a085bcf8a7789da9.jpg,https://files.alnair.ae/uploads/2024/8/b2/bf/b2bf15b8992305de5310c70d1e9048bb.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22455815	55.27935650	Off-plan property: Amber by Enso by ENSO	2d651a1b-02b6-4097-9643-15780c2be4fb	328521.60	0	3	1	3	47.94	163.79	\N	\N	\N	\N	\N	2025-11-02 21:43:05.878104	2025-11-02 21:43:05.878104
b7e97fb2-b092-4232-853e-0cd5b668530a	off-plan	Sea Legend One	https://files.alnair.ae/uploads/2025/5/a8/c1/a8c10c5c8b806e53620b06fd33837e08.jpg,https://files.alnair.ae/uploads/2025/6/fd/e4/fde44ee90292225098720e3b849802e3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29951974	55.29738732	Off-plan property: Sea Legend One by MVS Real Estate Development	a6972647-f568-43cb-8fe9-799aea670099	648127.58	1	3	1	3	76.03	314.71	\N	\N	\N	\N	\N	2025-11-02 21:43:05.880752	2025-11-02 21:43:05.880752
e884faed-b135-417a-b9a5-07e7e681a095	off-plan	Olivia Gardens Residence	https://files.alnair.ae/uploads/2025/3/85/97/8597d3cedde9db988a082b6525987b7d.jpg,https://files.alnair.ae/uploads/2025/3/de/f2/def252a6ec26bd550434552cd2aa2fdc.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22490692	55.27642116	Off-plan property: Olivia Gardens Residence by Segrex Development	6782ccc1-f602-40f2-b1f9-2360519488e2	351449.02	0	2	1	2	52.82	98.87	\N	\N	\N	\N	\N	2025-11-02 21:43:05.885632	2025-11-02 21:43:05.885632
e696cf56-1e75-4a13-a320-52472dd51466	off-plan	Vitality Residence	https://files.alnair.ae/uploads/2024/4/97/c4/97c4031af021178c977b49fbb053ff02.jpg,https://files.alnair.ae/uploads/2024/4/1a/64/1a648820b3489863d4f35453dc3da31a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06129645	55.20850539	Off-plan property: Vitality Residence by Segrex Development	6782ccc1-f602-40f2-b1f9-2360519488e2	396872.48	1	1	1	2	73.60	77.08	\N	\N	\N	\N	\N	2025-11-02 21:43:05.887631	2025-11-02 21:43:05.887631
83912222-afd3-4022-8a2b-ce4674be154a	off-plan	Colibri Views	https://files.alnair.ae/uploads/2025/7/e6/3e/e63e5b8194b52dcb53bcb78c5580f35d.jpg,https://files.alnair.ae/uploads/2025/7/11/47/114752ed0005c5b7f3232f06e01cf576.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.69079033	55.79891618	Off-plan property: Colibri Views by Major Developments	ef6ff897-a25c-4bfb-b3f3-f11c41492ee6	326666.56	1	1	1	2	53.61	54.81	\N	\N	\N	\N	\N	2025-11-02 21:43:05.891319	2025-11-02 21:43:05.891319
2118ba29-225f-49cd-91a8-b2bcc895a36b	off-plan	Lumea Residences	https://files.alnair.ae/uploads/2025/10/40/1e/401ef6b377077c78b1650f89636aa15f.jpg,https://files.alnair.ae/uploads/2025/10/3b/5e/3b5eeb0036f21e91cf2c5170f8568149.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29202005	55.30798137	Off-plan property: Lumea Residences by Green Horizon Development	38c8b3b2-2426-45b7-9175-88438dba20f6	432208.00	1	3	1	3	69.12	171.87	\N	\N	\N	\N	\N	2025-11-02 21:43:05.89404	2025-11-02 21:43:05.89404
1a1a95be-a667-4221-aa77-d19db954185d	off-plan	The Grandala	https://files.alnair.ae/uploads/2024/1/44/4f/444f34a111f47f449c7be7cc1a5923f8.jpg,https://files.alnair.ae/uploads/2024/1/04/72/0472d8b9bc7f3948b97143c7f0f101d1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21779419	55.27401135	Off-plan property: The Grandala by Palladium Development	bb633fa5-9394-484e-a17b-feaaf78ce422	272000.00	0	1	1	2	45.99	85.65	\N	\N	\N	\N	\N	2025-11-02 21:43:05.897904	2025-11-02 21:43:05.897904
6b91fcf0-46c9-453a-8ef3-6b881374e2f4	off-plan	Fortune Bay Residences	https://files.alnair.ae/uploads/2025/10/8f/42/8f425728d3e4caf4292b20d47e0c6fff.jpg,https://files.alnair.ae/uploads/2024/12/54/d0/54d09c94e9dc0b1ca6fcabd56f07a1ca.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.67426078	55.74076784	Off-plan property: Fortune Bay Residences by Topero Properties	e8dff1ac-1771-4c52-97ca-9265c7ee45ae	820053.07	1	3	1	3	63.27	794.79	\N	\N	\N	\N	\N	2025-11-02 21:43:05.900034	2025-11-02 21:43:05.900034
488374c6-9ac9-4f8d-b462-27cf29356f25	off-plan	Verde by Vision	https://files.alnair.ae/uploads/2025/8/c1/ee/c1ee824f12df53d197adef17ca92ebec.jpg,https://files.alnair.ae/uploads/2025/8/93/3a/933a381035f18dbaf7c3a991c0a36459.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03277628	55.22455967	Off-plan property: Verde by Vision by Vision developments	e155b5fb-b446-446a-b47d-90bc8f6d55d6	435964.32	2	2	2	2	110.40	117.51	\N	\N	\N	\N	\N	2025-11-02 21:43:05.904577	2025-11-02 21:43:05.904577
a3602bf8-69e1-4c9e-b602-dfca95b8975a	off-plan	Terra Gardens	https://files.alnair.ae/uploads/2025/10/ad/7c/ad7c2677f4ff8dc5532431483d5e126d.jpg,https://files.alnair.ae/uploads/2025/10/3b/df/3bdf361714ac7b41a84a1757fd95e8ef.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.96861809	55.14548192	Off-plan property: Terra Gardens by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	421600.00	1	3	1	3	68.93	239.69	\N	\N	\N	\N	\N	2025-11-02 21:43:05.907649	2025-11-02 21:43:05.907649
759cf321-9c76-4bbc-8815-0a0b744b2123	off-plan	Derby Heights	https://files.alnair.ae/uploads/2025/10/b1/08/b1085d6cc5dd76ed67837312fb2cdd14.jpg,https://files.alnair.ae/uploads/2025/10/15/01/15019060827bba0419b420d5d061f9ca.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13466762	55.35094114	Off-plan property: Derby Heights by AMIS Properties	930bd2d2-cfc4-4ae6-8d21-0a27559e4030	326768.29	1	2	1	2	55.37	106.10	\N	\N	\N	\N	\N	2025-11-02 21:43:05.91092	2025-11-02 21:43:05.91092
dbb5eb25-b30e-4056-b893-f012fba2de32	off-plan	368 Park Ln.	https://files.alnair.ae/uploads/2025/10/9a/59/9a59f20fbba3a8bd170455e3f63a7f5b.png,https://files.alnair.ae/uploads/2025/10/85/96/8596d1e0132a9cc16bef51b941052eb4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06201550	55.20863950	Off-plan property: 368 Park Ln. by Tabeer	7d0313ac-b8a1-442a-a962-501f92b22c54	182240.00	0	3	1	3	40.88	214.88	\N	\N	\N	\N	\N	2025-11-02 21:43:05.913035	2025-11-02 21:43:05.913035
9cdd252f-b888-4483-8785-ca872908e284	off-plan	Palace Residences Hillside	https://files.alnair.ae/uploads/2025/10/b5/da/b5dac99b389cb7d5a85a287eb8592c5b.jpg,https://files.alnair.ae/uploads/2025/10/17/86/1786de029626679553e5993063ce52de.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11493417	55.24940327	Off-plan property: Palace Residences Hillside by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	465120.00	1	3	1	3	62.80	243.69	\N	\N	\N	\N	\N	2025-11-02 21:43:05.914811	2025-11-02 21:43:05.914811
ae229b7f-546f-4f68-9687-44b42334d8d1	off-plan	Wellington Ocean Walk	https://files.alnair.ae/uploads/2025/7/0d/95/0d9598a8cd8c7402fffaab0e87a42cb1.png,https://files.alnair.ae/uploads/2025/8/d5/63/d563dc538423d80de9055550825d22f1.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.30052492	55.31557765	Off-plan property: Wellington Ocean Walk by Wellington Developments	6b943c81-024d-4f98-b4ea-30a841a22f9c	601888.13	1	3	1	3	83.24	241.54	\N	\N	\N	\N	\N	2025-11-02 21:43:05.917514	2025-11-02 21:43:05.917514
51ac60bf-3a6b-4c5d-8848-ebe85dd0bef3	off-plan	Future Residence	https://files.alnair.ae/uploads/2025/9/c3/98/c398133149a96f49b8b27a8e5d44f568.jpg,https://files.alnair.ae/uploads/2025/9/c2/1e/c21e4a416c95a34f25db757dfee3204c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17949807	55.32407999	Off-plan property: Future Residence by True Future Real Estate Development	a13dd8ca-d6e1-4d9a-8f90-4d2b7102df1e	330295.31	1	2	1	2	53.64	436.88	\N	\N	\N	\N	\N	2025-11-02 21:43:05.919578	2025-11-02 21:43:05.919578
3def36cc-594f-4f1a-8975-a2819abac85b	off-plan	Rabdan Square	https://files.alnair.ae/uploads/2025/10/ea/1e/ea1e868de5847625453aca7441434666.jpg,https://files.alnair.ae/uploads/2025/10/95/b2/95b29706052b1a6e55c3b43bd2931861.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.15245365	55.28797209	Off-plan property: Rabdan Square by Rabdan Real Estate Developments	8147c5dd-d275-4d04-84d4-4fce9ce87e0e	462400.00	1	3	1	3	66.52	218.04	\N	\N	\N	\N	\N	2025-11-02 21:43:05.922762	2025-11-02 21:43:05.922762
3331ba0a-b613-4207-ab93-df265d07848f	off-plan	Celia Homes	https://files.alnair.ae/uploads/2025/10/24/32/2432c2c16196b71fab453a3daa1c0fc9.jpg,https://files.alnair.ae/uploads/2025/10/67/9b/679bb5498de7a3871e16015516dabb5f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09681101	55.37886143	Off-plan property: Celia Homes by Abou Eid Real Estate Development	342af2c3-688b-4e08-a4ad-30a2e1ab23f8	182240.00	0	2	1	2	41.16	116.59	\N	\N	\N	\N	\N	2025-11-02 21:43:05.924873	2025-11-02 21:43:05.924873
86a5542c-d31e-4aeb-9ff4-7e1caf86c144	off-plan	Maravelle Residences	https://files.alnair.ae/uploads/2025/10/a9/dc/a9dc9fbe7908458447a3129ca67223bc.jpg,https://files.alnair.ae/uploads/2025/10/77/cb/77cbbf18531991fabb3e1c6a407edbc6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07519158	55.31565535	Off-plan property: Maravelle Residences by Majid Al Futtaim	4e3d71dd-2644-44ab-b07f-17f13ee73227	1411680.00	2	4	2	4	209.03	472.88	\N	\N	\N	\N	\N	2025-11-02 21:43:05.92731	2025-11-02 21:43:05.92731
03711215-caac-483e-9146-5a206c686739	off-plan	Portside Square	https://files.alnair.ae/uploads/2025/10/8b/71/8b71ca91b6cfa1573ca9fc14c85cf6a9.jpg,https://files.alnair.ae/uploads/2025/10/cc/a2/cca2c89763b886547ffde042b3e67f8a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.25896685	55.28199147	Off-plan property: Portside Square by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	323136.00	0	3	1	3	36.79	160.13	\N	\N	\N	\N	\N	2025-11-02 21:43:05.931538	2025-11-02 21:43:05.931538
472b78fd-980a-4376-80a1-7d3771c252e0	off-plan	Le Blanc	https://files.alnair.ae/uploads/2025/10/7f/00/7f0020fa4942d9c643386781342c21af.jpg,https://files.alnair.ae/uploads/2025/10/fc/78/fc78b9beec58d8ad31f12c37d2a37b0a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08696448	55.38021966	Off-plan property: Le Blanc by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	197200.00	0	3	1	3	37.16	167.23	\N	\N	\N	\N	\N	2025-11-02 21:43:05.935055	2025-11-02 21:43:05.935055
9e1edb1d-db4c-442f-acb5-80f5b506f1b4	off-plan	MetroPoint	https://files.alnair.ae/uploads/2025/10/59/53/595340ad3f4312b0e6f7b37d2ea0c0fa.jpg,https://files.alnair.ae/uploads/2025/10/99/b1/99b120efbfb549547fa90ed5e101e336.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.96994920	55.08874109	Off-plan property: MetroPoint by Forum Real Estate Development	d6473fdf-38b7-4cf9-be95-c2b2a32f8a3d	143412.00	0	2	1	2	31.22	85.47	\N	\N	\N	\N	\N	2025-11-02 21:43:05.938396	2025-11-02 21:43:05.938396
d344bebc-28f8-4bd8-97eb-6d0d3d7ec2c3	off-plan	Empire Gardens	https://files.alnair.ae/uploads/2025/10/14/cb/14cb1ee401500bb2ed22cbc238133fe7.jpg,https://files.alnair.ae/uploads/2025/10/83/0e/830ea91ad3e42d1373ef802b50e3dc96.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09789373	55.37409782	Off-plan property: Empire Gardens by Empire Developments	a45adfa1-9f07-48ed-a4d3-ba8f0d2021cd	176799.73	0	3	1	3	40.88	209.03	\N	\N	\N	\N	\N	2025-11-02 21:43:05.940506	2025-11-02 21:43:05.940506
84a35f58-ee3b-414d-b9c2-3c0a02ad0dcd	off-plan	Binghatti Titania	https://files.alnair.ae/uploads/2025/10/13/fe/13fe25e532e86c27768cac8ce80ffb04.jpg,https://files.alnair.ae/uploads/2025/10/69/9f/699f7cd19dcb5147469b47288c703068.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08552587	55.31477929	Off-plan property: Binghatti Titania by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	421599.73	2	2	2	2	111.26	111.45	\N	\N	\N	\N	\N	2025-11-02 21:43:05.942723	2025-11-02 21:43:05.942723
5de1f33f-6164-4f99-b925-13f22c0d58f3	off-plan	Sunset Bay Grand	https://files.alnair.ae/uploads/2025/10/47/93/47937645f1a406e04593ade094ec3c46.jpg,https://files.alnair.ae/uploads/2025/10/f7/77/f77703788e473ffbd02eae38a5aa7f93.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.28846844	55.30255124	Off-plan property: Sunset Bay Grand by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	544000.00	1	3	1	3	78.50	238.30	\N	\N	\N	\N	\N	2025-11-02 21:43:05.944428	2025-11-02 21:43:05.944428
03eb5a09-ef8b-45b2-976c-fa6aa7917b1e	off-plan	Cascada 2 at WAADA	https://files.alnair.ae/uploads/2025/10/b3/4b/b34b05170aac9855e0a94098961aa2bd.png,https://files.alnair.ae/uploads/2025/10/e0/e1/e0e1d39b471052b5bfddbc84014ae4a1.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.82592386	55.11996384	Off-plan property: Cascada 2 at WAADA by BT Properties	b8070f8b-8568-4d29-af7a-6f55156d0233	360128.00	2	3	2	3	106.22	262.25	\N	\N	\N	\N	\N	2025-11-02 21:43:05.947359	2025-11-02 21:43:05.947359
24e4ee33-4ee4-452a-b841-0f11831e969a	off-plan	Binghatti Hillcrest	https://files.alnair.ae/uploads/2025/10/a3/06/a30600b7aca10c0ec706557e37b35249.jpg,https://files.alnair.ae/uploads/2025/10/ed/90/ed90f15c3cc1f7c219919389e85d0b5f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06660039	55.23397051	Off-plan property: Binghatti Hillcrest by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	219503.73	0	2	1	2	31.00	961.07	\N	\N	\N	\N	\N	2025-11-02 21:43:05.949173	2025-11-02 21:43:05.949173
9eb2ec9b-54e6-4263-b2a0-ddc51742e7ff	off-plan	Eywa 2	https://files.alnair.ae/uploads/2025/10/3c/c0/3cc02e9f52f9064503ad4e63a3e20a33.jpg,https://files.alnair.ae/uploads/2025/10/83/f9/83f9be52316575c6439e0ea5906d191f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18300773	55.27384758	Off-plan property: Eywa 2 by Rvl Real Estate	336d541b-8383-44f1-8e00-15f663df4b51	2257600.00	2	3	2	3	355.35	390.94	\N	\N	\N	\N	\N	2025-11-02 21:43:05.952556	2025-11-02 21:43:05.952556
8d67039d-5166-423d-9791-c5f62b83eee4	off-plan	Wadi Hills	https://files.alnair.ae/uploads/2025/10/40/ef/40ef393271b24e3aedb54d98381990a1.png,https://files.alnair.ae/uploads/2025/10/06/38/06387a0ec3f8965ed8f9f0cbbe154935.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09460911	55.37959367	Off-plan property: Wadi Hills by HRE Development	081fa9d3-a0f7-4d05-ab75-aa99feb00da8	179248.00	0	3	1	3	34.28	133.41	\N	\N	\N	\N	\N	2025-11-02 21:43:05.954598	2025-11-02 21:43:05.954598
8d05aed2-adf9-437f-b060-6df2e0230a7d	off-plan	Celesto 2 Tower	https://files.alnair.ae/uploads/2025/10/63/de/63dea441a8c046c5fa008929928da3cb.jpg,https://files.alnair.ae/uploads/2025/10/64/6b/646bff57d8555f66bbbd7c451a36e8ed.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09827083	55.37307640	Off-plan property: Celesto 2 Tower by Tarrad Development	6577dd65-71ee-4552-9286-4f98df3cc883	149600.00	0	2	1	2	29.73	86.40	\N	\N	\N	\N	\N	2025-11-02 21:43:05.9566	2025-11-02 21:43:05.9566
029eb7fe-f1da-44e6-b3a7-78c4c07e4e34	off-plan	Wellness Estate	https://files.alnair.ae/uploads/2025/10/af/9d/af9d657f2f138e068c68fe735ad7c82b.jpg,https://files.alnair.ae/uploads/2025/9/78/c8/78c8927a1a0086c0b2fba841104a7b26.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08502496	55.31318474	Off-plan property: Wellness Estate by Vincitore	3636d588-69e3-4d16-b9a8-725d1bdf8629	217600.00	0	0	1	2	0.00	0.00	\N	\N	\N	\N	\N	2025-11-02 21:43:05.958826	2025-11-02 21:43:05.958826
6579efdf-d702-485e-8137-ad057f7a7826	off-plan	Al Haseen Residence 5	https://files.alnair.ae/uploads/2025/10/52/24/522408803e201640ac969351cb42b6fa.png,https://files.alnair.ae/uploads/2025/10/7a/0e/7a0e81f89fe132c5c368f59cf5d8717a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.87235384	55.03769913	Off-plan property: Al Haseen Residence 5 by Dugasta Properties Development	d4b3354c-36e1-4395-ad29-70911062e48d	161461.38	0	3	1	3	34.23	168.92	\N	\N	\N	\N	\N	2025-11-02 21:43:05.960146	2025-11-02 21:43:05.960146
4c52294b-5d04-4fb7-8a3b-3321b2108891	off-plan	Casagrand Hermina	https://files.alnair.ae/uploads/2025/10/e6/71/e671f69ca9879e050c8ac99d9d4dca77.jpg,https://files.alnair.ae/uploads/2025/9/88/47/884774c81b7cb2542abf18946491681b.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29560053	55.32050634	Off-plan property: Casagrand Hermina by Casagrand	99645cf2-c7a2-460f-877e-77360827f5de	489600.00	1	3	1	3	77.11	138.43	\N	\N	\N	\N	\N	2025-11-02 21:43:05.96339	2025-11-02 21:43:05.96339
343299d1-e3ee-4253-a764-960828af9e45	off-plan	Crown Palace	https://files.alnair.ae/uploads/2025/10/cc/ef/ccefe91238e11aea8733b041d1e31a7a.jpg,https://files.alnair.ae/uploads/2025/9/a4/b0/a4b06e0252eee9c3312e62225d9c6fef.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94136623	55.21189475	Off-plan property: Crown Palace by Amirah Developments	3611fe79-1291-46e6-b063-1609fa3131d8	171360.00	0	2	1	2	34.46	83.33	\N	\N	\N	\N	\N	2025-11-02 21:43:05.965497	2025-11-02 21:43:05.965497
587d7a49-5aea-4a64-a0d5-4b6ad937ef03	off-plan	SOL Luxe	https://files.alnair.ae/uploads/2025/10/8b/38/8b385c1a2c51398410c4a0ca7f9b0a57.jpg,https://files.alnair.ae/uploads/2025/9/f1/3f/f13fb26017f1497f6cc3f5610694e723.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21081602	55.27385600	Off-plan property: SOL Luxe by SOL Properties	da59d484-2f29-4f4b-849b-6f69819597ac	516800.00	1	3	1	3	72.74	159.61	\N	\N	\N	\N	\N	2025-11-02 21:43:05.968533	2025-11-02 21:43:05.968533
9ebdd3f7-6dca-4e56-8be5-2c34f4e6b7b5	off-plan	Villa dell’Arte	https://files.alnair.ae/uploads/2025/10/d4/45/d445560ff1c2514d4ef902d57f1881c6.png,https://files.alnair.ae/uploads/2025/10/83/4f/834f7325559458a7f57c906ac545d5a4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.28844363	55.29726541	Off-plan property: Villa dell’Arte by Mr. Eight	378511a2-e46d-48ad-88a8-72584c46191c	530400.00	1	4	1	4	63.27	327.02	\N	\N	\N	\N	\N	2025-11-02 21:43:05.970293	2025-11-02 21:43:05.970293
4f8daeca-470e-4019-9580-42ebfdf30042	off-plan	New Project by Empire	https://files.alnair.ae/uploads/2025/9/38/ac/38ac5373b81d0c7ae2559342d8d01a0e.png,https://files.alnair.ae/uploads/2025/9/39/2e/392e530b2659af1770ad6a27a4831d72.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04770036	55.20645610	Off-plan property: New Project by Empire by Empire Developments	a45adfa1-9f07-48ed-a4d3-ba8f0d2021cd	300499.34	1	1	1	2	62.71	66.70	\N	\N	\N	\N	\N	2025-11-02 21:43:05.972122	2025-11-02 21:43:05.972122
33a97210-2825-40aa-bf99-2cadccf42552	off-plan	Mi Casa	https://files.alnair.ae/uploads/2025/9/bc/c5/bcc5668bff831be1a34a9b80ab22473b.jpg,https://files.alnair.ae/uploads/2025/9/3c/72/3c72eef67e818b59e0e2c2f432f97024.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06934397	55.20936634	Off-plan property: Mi Casa by London Gate	4b47b8ee-6457-403f-81cf-12bbbf751d23	204000.00	0	2	1	2	40.23	94.67	\N	\N	\N	\N	\N	2025-11-02 21:43:05.975053	2025-11-02 21:43:05.975053
bdaddba8-dc15-4c0c-994f-69f75c7d6a7b	off-plan	Villa del Brunello	https://files.alnair.ae/uploads/2025/8/b0/62/b062ae56896f2aa2295e632cd74759ae.png,https://files.alnair.ae/uploads/2025/8/3c/ef/3cef62e65529250eec64cb81328a3617.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29968861	55.29662825	Off-plan property: Villa del Brunello by Mr. Eight	378511a2-e46d-48ad-88a8-72584c46191c	1400800.00	2	4	2	4	99.13	538.09	\N	\N	\N	\N	\N	2025-11-02 21:43:05.977059	2025-11-02 21:43:05.977059
ebadec3a-46e6-4e94-aa07-9c27f160996c	off-plan	Greenwood Royal - Regent's Park	https://files.alnair.ae/uploads/2025/10/1d/34/1d3439b28c47d625cd9f464dd41f7394.jpg,https://files.alnair.ae/uploads/2025/8/5f/e1/5fe16ca5fee1fdd7bb6446c41063efa5.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06489198	55.41863833	Off-plan property: Greenwood Royal - Regent's Park by Leos Development	8f713edb-84d7-465d-8744-965901f5d7e7	982056.00	1	3	1	3	93.91	187.83	\N	\N	\N	\N	\N	2025-11-02 21:43:05.979576	2025-11-02 21:43:05.979576
262162a1-1f0f-4177-857b-d524bd6cbd74	off-plan	Urban Horizon	https://files.alnair.ae/uploads/2025/8/2e/e8/2ee8c52dd892f933586a9f08a1c89aea.png,https://files.alnair.ae/uploads/2025/8/d9/e7/d9e72147267e7e417b494b5fe96649d8.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05776138	55.22601759	Off-plan property: Urban Horizon by Arete Developments	c8156430-944d-4829-9d5e-964b1bf8c792	174442.58	0	2	1	2	32.70	108.60	\N	\N	\N	\N	\N	2025-11-02 21:43:05.982113	2025-11-02 21:43:05.982113
20789f13-f5ed-415a-8a1c-75df4bcfd5a1	off-plan	ELAR1S Axis	https://files.alnair.ae/uploads/2025/8/c7/83/c783e1b821973c7e1748333ffb6e3034.jpg,https://files.alnair.ae/uploads/2025/8/74/e8/74e854661242383b948cafe661d32013.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03492546	55.17613806	Off-plan property: ELAR1S Axis by Object One	9d128f32-1c6c-474d-b911-61803444decc	220521.01	0	1	1	2	39.25	69.51	\N	\N	\N	\N	\N	2025-11-02 21:43:05.985471	2025-11-02 21:43:05.985471
eccbf668-81cd-4e32-8f8b-ff27a61805b1	off-plan	Verdan1a 3	https://files.alnair.ae/uploads/2025/8/db/a2/dba27e091af64b67790a5f297f314e57.jpg,https://files.alnair.ae/uploads/2025/8/f4/d4/f4d420813bb0277829b2c55e193f55f5.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09620680	55.37453972	Off-plan property: Verdan1a 3 by Object One	9d128f32-1c6c-474d-b911-61803444decc	304378.34	1	1	1	2	67.20	89.16	\N	\N	\N	\N	\N	2025-11-02 21:43:05.98762	2025-11-02 21:43:05.98762
aa744734-dc0f-4d46-b01f-04154b08a4af	off-plan	Nexara Tower	https://files.alnair.ae/uploads/2025/9/5e/84/5e845a21ce6d2d4bbaacb4df3fe9db59.png,https://files.alnair.ae/uploads/2025/9/c7/23/c723eff6257a6539360189731b9e96cd.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05861954	55.21172709	Off-plan property: Nexara Tower by 7th Key	74c7e714-1039-4845-b648-5c575084c119	299200.00	1	3	1	3	60.85	174.56	\N	\N	\N	\N	\N	2025-11-02 21:43:05.991289	2025-11-02 21:43:05.991289
c49b0988-2105-47cf-b527-e953297e2572	off-plan	The Elysian Residence	https://files.alnair.ae/uploads/2025/9/8a/34/8a341ba52f06677d02e6e7207b37f012.jpg,https://files.alnair.ae/uploads/2025/9/5a/00/5a00e482aec7cf2f02b5a85f39190cb3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22729347	55.28136950	Off-plan property: The Elysian Residence by New MFOUR Real Estate Development	75028747-cbc2-42d0-b3ab-d598d854c10d	285600.00	0	3	1	3	33.63	292.18	\N	\N	\N	\N	\N	2025-11-02 21:43:05.995541	2025-11-02 21:43:05.995541
26dc8f2b-0193-4bfd-8fa4-1236debabfd7	off-plan	Aquora	https://files.alnair.ae/uploads/2025/10/c3/a5/c3a556f8520b8cca20be4b115bb84c32.png,https://files.alnair.ae/uploads/2025/10/4d/a6/4da657b1f3cb5123d4020c2594e2b7d6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29713342	55.32199207	Off-plan property: Aquora by Casa Vista Development	a8f3e258-b760-40e9-84d9-58ee3dbdad07	518220.38	1	1	1	2	70.88	70.88	\N	\N	\N	\N	\N	2025-11-02 21:43:05.998778	2025-11-02 21:43:05.998778
8a52ef88-3691-45ea-8e57-41c1b039c121	off-plan	Evergr1n House 4	https://files.alnair.ae/uploads/2025/7/66/e1/66e10dc6e45e758d3723581a265352d1.jpg,https://files.alnair.ae/uploads/2025/7/7e/90/7e902778f38c73eff21a1cf1fb1813d4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22431730	55.27916908	Off-plan property: Evergr1n House 4 by Object One	9d128f32-1c6c-474d-b911-61803444decc	341324.91	0	1	1	2	42.92	75.90	\N	\N	\N	\N	\N	2025-11-02 21:43:06.00168	2025-11-02 21:43:06.00168
15ec770a-ac63-44a9-8931-3235c6183983	off-plan	Altura 1 at WAADA	https://files.alnair.ae/uploads/2025/5/75/0d/750dfae926b07545330e705161e74d0f.png,https://files.alnair.ae/uploads/2025/5/43/27/4327954df7f25a0ba6ae33e3c1f6cee5.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.82140941	55.11914620	Off-plan property: Altura 1 at WAADA by BT Properties	b8070f8b-8568-4d29-af7a-6f55156d0233	245344.00	1	2	1	2	68.75	110.55	\N	\N	\N	\N	\N	2025-11-02 21:43:06.003927	2025-11-02 21:43:06.003927
48b80748-b311-40d9-89d3-a3514d6a4e51	off-plan	Verdan1a 4	https://files.alnair.ae/uploads/2025/5/89/16/8916ff1a2576b8e7d71ccef9b91467ef.jpg,https://files.alnair.ae/uploads/2025/5/ce/b8/ceb85ef05e5c871b8a5a7b49b260a57c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09453050	55.37295650	Off-plan property: Verdan1a 4 by Object One	9d128f32-1c6c-474d-b911-61803444decc	274511.65	0	2	1	2	56.11	133.55	\N	\N	\N	\N	\N	2025-11-02 21:43:06.005781	2025-11-02 21:43:06.005781
97a6c0e2-6e2c-456c-a2f6-10eece1992c4	off-plan	1WOOD Residence 2	https://files.alnair.ae/uploads/2025/5/02/e8/02e89be51ca846fefc8689050d95cd52.jpg,https://files.alnair.ae/uploads/2025/5/a9/79/a97930e7b9d486b1c6db7377e9ee123d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06261173	55.20878591	Off-plan property: 1WOOD Residence 2 by Object One	9d128f32-1c6c-474d-b911-61803444decc	214367.82	0	2	1	2	39.62	187.48	\N	\N	\N	\N	\N	2025-11-02 21:43:06.007513	2025-11-02 21:43:06.007513
8002ca39-4d7d-44b7-8637-531abff7f1f9	off-plan	S1lva Park Living	https://files.alnair.ae/uploads/2025/4/d9/dc/d9dc002847321b57cd19a1de14113d3c.jpg,https://files.alnair.ae/uploads/2025/4/12/a3/12a33e55ea5825ea5d3e5cee3c9a5e6d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03912962	55.18029199	Off-plan property: S1lva Park Living by Object One	9d128f32-1c6c-474d-b911-61803444decc	219370.99	0	2	1	2	41.98	164.62	\N	\N	\N	\N	\N	2025-11-02 21:43:06.009473	2025-11-02 21:43:06.009473
9029212d-31a1-402f-bfa3-ef5f00c9f256	off-plan	Taiyo Residences	https://files.alnair.ae/uploads/2025/10/61/4f/614fbc61f5227cb10c29c91be459f808.png,https://files.alnair.ae/uploads/2025/4/bb/92/bb92ed765edb14988e91bfb23b7f69a0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02102925	55.10611027	Off-plan property: Taiyo Residences by LMD	d0237faa-190d-4fdc-a15f-b0a451b0dbaa	189040.00	0	3	1	3	36.88	145.58	\N	\N	\N	\N	\N	2025-11-02 21:43:06.011918	2025-11-02 21:43:06.011918
12fff49f-e540-414c-8940-d067e145ec30	off-plan	IR1DIAN PARK 2	https://files.alnair.ae/uploads/2025/4/51/21/5121d5ecc2128d87000eb0bd8809b203.jpg,https://files.alnair.ae/uploads/2025/4/a4/54/a4549dddeb1e21cbf6dd4458fef0736e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04992181	55.21250189	Off-plan property: IR1DIAN PARK 2 by Object One	9d128f32-1c6c-474d-b911-61803444decc	225088.16	0	2	1	2	41.76	154.08	\N	\N	\N	\N	\N	2025-11-02 21:43:06.013897	2025-11-02 21:43:06.013897
50fcdf40-54f4-4c52-89ed-914835c7be72	off-plan	IR1DIAN PARK	https://files.alnair.ae/uploads/2025/2/45/f0/45f0539d3d85cc585807aac632de83ea.jpg,https://files.alnair.ae/uploads/2025/2/f2/39/f2393604184749fb1dc8c941b1e36da0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04958966	55.21281727	Off-plan property: IR1DIAN PARK by Object One	9d128f32-1c6c-474d-b911-61803444decc	235929.26	0	2	1	2	46.96	107.12	\N	\N	\N	\N	\N	2025-11-02 21:43:06.015654	2025-11-02 21:43:06.015654
443fd7a1-9eaa-48cc-bfae-0702b42089b4	off-plan	SquareX One	https://files.alnair.ae/uploads/2025/7/a5/29/a529fc8e19dc7b03a5b6a363307c4d0b.png,https://files.alnair.ae/uploads/2025/5/ba/2b/ba2b2b0464972765083a3b43ba0b4a9d.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05147144	55.21907132	Off-plan property: SquareX One by Tasmeer Indigo Properties	a90315f8-75de-4e44-bd69-d890cae817b0	199914.56	0	2	1	2	33.66	134.86	\N	\N	\N	\N	\N	2025-11-02 21:43:06.019839	2025-11-02 21:43:06.019839
c789013f-8087-4a69-b4b0-81076876ee7e	off-plan	Linden Residences	https://files.alnair.ae/uploads/2025/5/15/0b/150b3e9438dd0d3ff71a7942e7803796.jpg,https://files.alnair.ae/uploads/2025/7/df/f6/dff6f0018ee81b808028d9ca15eaaf80.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.15245400	55.39423800	Off-plan property: Linden Residences by Black Soil	437bbab3-070e-4838-b712-56a54b45167d	176800.00	0	2	1	2	43.29	185.81	\N	\N	\N	\N	\N	2025-11-02 21:43:06.021866	2025-11-02 21:43:06.021866
e31f0307-45df-4e21-879c-bada7ea43b8d	off-plan	Sea Mirror Residences	https://files.alnair.ae/uploads/2025/6/69/99/69998931cd1171b893326a86d4c8212e.jpg,https://files.alnair.ae/uploads/2025/6/5d/54/5d54521e3bfc3338e5920fe444112d58.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19628068	55.23696519	Off-plan property: Sea Mirror Residences by Lamar Development	349c8063-9c0f-43db-a3ae-d06dc7833bfc	5984000.00	4	4	4	4	0.00	0.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.023891	2025-11-02 21:43:06.023891
e0b1441c-f024-4f1e-83d9-5399d1137a4c	off-plan	Casa AHS	https://files.alnair.ae/uploads/2025/5/5c/2f/5c2f55e625ae58ef75136c9f3fd47661.jpg,https://files.alnair.ae/uploads/2024/12/e6/a5/e6a54a41f718478ae567d5114d863137.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18746891	55.24596602	Off-plan property: Casa AHS by AHS Properties	b634bdb5-0543-4401-bc7a-d5a9dbf181a7	7208000.00	3	3	3	3	473.34	2972.90	\N	\N	\N	\N	\N	2025-11-02 21:43:06.02626	2025-11-02 21:43:06.02626
f38489ff-f106-4cf5-ad3c-1aaa4e22989b	off-plan	TETR1S Tower	https://files.alnair.ae/uploads/2024/12/56/b5/56b59a7e81ab6a6c89bcc3dea419d7a9.jpg,https://files.alnair.ae/uploads/2024/12/8b/7f/8b7ffe96b5016ddf157683acfff1a999.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04967984	55.21571120	Off-plan property: TETR1S Tower by Object One	9d128f32-1c6c-474d-b911-61803444decc	219309.52	0	2	1	2	40.10	115.87	\N	\N	\N	\N	\N	2025-11-02 21:43:06.028206	2025-11-02 21:43:06.028206
eb12d379-fbf9-4f21-b1bd-89f158c4d6d5	off-plan	Park Five	https://files.alnair.ae/uploads/2024/11/f6/fc/f6fc4179009bc03f7ccb9cebf4f474b0.png,https://files.alnair.ae/uploads/2024/11/c2/a8/c2a88f3fb85acfc1e3a1264526ade139.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03488000	55.19850974	Off-plan property: Park Five by Deyaar	562c648e-bd2d-453f-83dc-6595824a64d8	196054.34	0	3	1	3	38.93	253.25	\N	\N	\N	\N	\N	2025-11-02 21:43:06.031674	2025-11-02 21:43:06.031674
e35922c7-3456-4885-8eb3-7fb3ead9d5c5	off-plan	Confident Preston	https://files.alnair.ae/uploads/2024/10/70/dd/70dda027a3673b48dfd66aa91363e064.jpg,https://files.alnair.ae/uploads/2024/10/d7/e5/d7e5312329d8de119e02098549b98d39.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10178183	55.36945223	Off-plan property: Confident Preston by Confident Group	0cf130e8-a1e3-4657-9dd6-06a6d9a6dd8a	212160.00	1	3	1	3	0.00	0.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.033774	2025-11-02 21:43:06.033774
4bb1158e-bc5f-45f0-9aec-5578814dc5f0	off-plan	Arisha Terraces	https://files.alnair.ae/uploads/2024/10/31/bd/31bdeee718e8fe65175a323c1d84e517.jpg,https://files.alnair.ae/uploads/2024/10/86/37/8637106b2ddd7eb79a6528e5c19f9809.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03513988	55.23534155	Off-plan property: Arisha Terraces by QUBE Development	26973590-be04-4f9c-a384-25536dc2ba8d	216512.00	0	2	1	2	41.34	129.60	\N	\N	\N	\N	\N	2025-11-02 21:43:06.036054	2025-11-02 21:43:06.036054
0315eb7d-50d9-43ec-b5f4-b7872701a8f1	off-plan	Bayview Boulevard	https://files.alnair.ae/uploads/2024/8/a0/07/a007197541d56cbe482089617be892b6.jpg,https://files.alnair.ae/uploads/2024/8/f1/fe/f1fe7b874a3309aebcd99184873218b0.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29072141	55.30893356	Off-plan property: Bayview Boulevard by AB Developers	823c1424-3caa-4a77-97e7-553cd5f04f2d	489600.00	1	2	1	2	88.26	139.35	\N	\N	\N	\N	\N	2025-11-02 21:43:06.040318	2025-11-02 21:43:06.040318
0e426e75-d331-4f05-823c-4ce52ad2c7fa	off-plan	Tivano 1	https://files.alnair.ae/uploads/2025/8/54/64/5464bb952dc30394f0fd4aec32eeb57f.jpg,https://files.alnair.ae/uploads/2024/12/3c/b1/3cb1bf7ce0396769217bafdb9c7f5d2d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29195033	55.30557811	Off-plan property: Tivano 1 by AYS Property Development	3323282f-72a8-48b7-a6c2-8d6380bb0973	584800.00	1	3	1	3	83.71	282.15	\N	\N	\N	\N	\N	2025-11-02 21:43:06.04252	2025-11-02 21:43:06.04252
a9224060-86f1-4094-b653-d74ebc181695	off-plan	Ramada Encore	https://files.alnair.ae/uploads/2025/10/11/b1/11b15276348020afb5e6d6d74fc0d290.jpg,https://files.alnair.ae/uploads/2025/10/36/62/3662632fc993b2fa22ef66651f0a9fc4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10398444	55.16690455	Off-plan property: Ramada Encore by Palladium Development	bb633fa5-9394-484e-a17b-feaaf78ce422	266560.00	0	0	1	2	18.00	18.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.044726	2025-11-02 21:43:06.044726
d5d0d405-d709-4dc7-8a63-27cbb25a7fbc	off-plan	Yacht Royal	https://files.alnair.ae/uploads/2025/10/00/22/00226946f723a1fea7bac5cbe7853493.jpg,https://files.alnair.ae/uploads/2025/10/6a/c5/6ac5a519a90e03a447ee05a7e75dd90a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10106313	55.16657685	Off-plan property: Yacht Royal by Palladium Development	bb633fa5-9394-484e-a17b-feaaf78ce422	353600.00	0	0	1	2	30.00	30.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.046411	2025-11-02 21:43:06.046411
5409c711-0405-4c93-a0fe-4ebca8be9b0b	off-plan	Palm Central Private Residences	https://files.alnair.ae/uploads/2025/10/a3/ee/a3ee26677fd451645e675dda0b41f15f.jpg,https://files.alnair.ae/uploads/2025/10/25/7d/257d0b12f2061e326c3d85aff66063cd.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00587175	54.98639122	Off-plan property: Palm Central Private Residences by Nakheel	d190bf02-5336-42e6-bba1-91ee1ab4b2d5	680000.00	1	5	1	5	0.00	0.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.049418	2025-11-02 21:43:06.049418
2cdd5249-577e-4d3f-a7c5-630dd04a7ce9	off-plan	Mia Tower	https://files.alnair.ae/uploads/2025/10/74/84/74845a7c9b4f7c6c19545c7a3c89b2cb.jpg,https://files.alnair.ae/uploads/2025/10/5e/2b/5e2b316d2c7d73a1ba245a347a28791e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17859620	55.32321741	Off-plan property: Mia Tower by Stamn Development	0edd8c13-a7a3-4042-98f2-7b74e0791c14	375360.00	1	1	1	2	56.67	56.67	\N	\N	\N	\N	\N	2025-11-02 21:43:06.050616	2025-11-02 21:43:06.050616
9afe6ac7-d53b-4eff-9b70-d1a22ec421ea	off-plan	Vista Verde	https://files.alnair.ae/uploads/2025/10/84/a0/84a0c3ff70e59bfb78029851df2e291f.jpg,https://files.alnair.ae/uploads/2025/10/eb/e1/ebe1a788ee2c1978a7596891af5b6976.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02511950	55.19009100	Off-plan property: Vista Verde by Fakhruddin Properties	7aa8d80f-f1da-438b-a8ac-a57d0b201cd8	217600.00	0	2	1	2	36.39	78.84	\N	\N	\N	\N	\N	2025-11-02 21:43:06.053601	2025-11-02 21:43:06.053601
65ce7c30-fb95-425f-8fa7-c3dd89f41966	off-plan	Stax	https://files.alnair.ae/uploads/2025/10/3b/56/3b569383be868d267372479ae6214919.jpg,https://files.alnair.ae/uploads/2025/10/3a/e1/3ae17fe782431844fb3a7310c23df9a9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05796837	55.20515554	Off-plan property: Stax by Pasha 1	268cb9db-0ed0-43b6-bc57-a1ec58075e50	181766.99	0	3	1	3	37.19	300.26	\N	\N	\N	\N	\N	2025-11-02 21:43:06.055627	2025-11-02 21:43:06.055627
5f19befe-2583-40ad-bae7-952dc2331da8	off-plan	Veranda Collection 1	https://files.alnair.ae/uploads/2025/10/29/36/2936bd90254444490418976364c48bb9.jpg,https://files.alnair.ae/uploads/2025/10/66/4d/664dd13dc61f32d6c0daa2742f2623c8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04879568	55.21308482	Off-plan property: Veranda Collection 1 by Credo Investments	fe699655-b30d-4690-b8f7-bb62ac05dadf	1183200.00	1	3	1	3	47.18	94.36	\N	\N	\N	\N	\N	2025-11-02 21:43:06.05894	2025-11-02 21:43:06.05894
03b8c5dc-bf8c-41b4-be46-963e0ae84654	off-plan	SkyParks	https://files.alnair.ae/uploads/2025/10/4b/19/4b19cf68056004ac9a92b99e85e442c4.png,https://files.alnair.ae/uploads/2025/10/0e/42/0e423e442de951c675698c260caaef2e.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18741814	55.25757797	Off-plan property: SkyParks by Sobha	5f637246-907f-4e44-9b90-7c3065602155	791386.18	1	3	1	3	63.60	211.05	\N	\N	\N	\N	\N	2025-11-02 21:43:06.060209	2025-11-02 21:43:06.060209
67714512-1b0e-4403-b28c-ae8abc3f54dd	off-plan	Golden Woods Albab Views	https://files.alnair.ae/uploads/2025/10/24/36/2436c5367d084063d0c8267e9df86cd6.png,https://files.alnair.ae/uploads/2025/10/11/9b/119bbf444c377b8fde441b4fcbe8863c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94503950	55.22441217	Off-plan property: Golden Woods Albab Views by Golden Woods	deaaebdd-4cef-4c79-bb86-7df0a24cd413	135264.24	0	2	1	2	30.84	102.47	\N	\N	\N	\N	\N	2025-11-02 21:43:06.062235	2025-11-02 21:43:06.062235
d93a35a0-630e-4354-beb0-3bc50c3c0c2e	off-plan	Azizi Leily	https://files.alnair.ae/uploads/2025/10/35/d8/35d8516d87188676a78c4a5e5f777078.jpg,https://files.alnair.ae/uploads/2025/10/b5/f0/b5f0e2b0bcba3d0e431703df53adb196.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21374963	55.32870420	Off-plan property: Azizi Leily by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	225216.00	0	2	1	2	30.66	444.04	\N	\N	\N	\N	\N	2025-11-02 21:43:06.065277	2025-11-02 21:43:06.065277
0a1f3220-11ee-4e1a-b45d-ebd37ca3be95	off-plan	Altura 2 at WAADA	https://files.alnair.ae/uploads/2025/10/4b/3d/4b3d5002205899f28d427b1341b0663a.png,https://files.alnair.ae/uploads/2025/10/45/e5/45e54cd92a193a5884409d4ae2d4e14c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.82236223	55.11942642	Off-plan property: Altura 2 at WAADA by BT Properties	b8070f8b-8568-4d29-af7a-6f55156d0233	244528.00	1	2	1	2	69.21	119.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.067091	2025-11-02 21:43:06.067091
628efb4b-c902-4527-b499-7022e2cad693	off-plan	Nourelle	https://files.alnair.ae/uploads/2025/10/42/9b/429b6b9aa0493af51ff39588d05d10e1.jpg,https://files.alnair.ae/uploads/2025/10/37/78/37784a80fe22e9e903fe816b95819f37.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12947334	55.19472335	Off-plan property: Nourelle by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	1048016.00	1	3	1	3	78.50	203.46	\N	\N	\N	\N	\N	2025-11-02 21:43:06.069516	2025-11-02 21:43:06.069516
242ab05b-f224-4e1b-92c3-9b473b9949b9	off-plan	Symbolic Altus	https://files.alnair.ae/uploads/2025/10/7d/7c/7d7c321af82ae5fbcbebbd18c8628a62.jpg,https://files.alnair.ae/uploads/2025/10/8d/4c/8d4c2c97f92bfab4ac41709ce93e5417.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10154172	55.36902802	Off-plan property: Symbolic Altus by Symbolic Developments	0aed7712-3f82-4975-8d86-7bcf4076abfe	271728.00	1	2	1	2	73.89	122.96	\N	\N	\N	\N	\N	2025-11-02 21:43:06.071761	2025-11-02 21:43:06.071761
b96845f7-c8b9-4212-9282-56244f40b840	off-plan	SkyGate Tower	https://files.alnair.ae/uploads/2025/10/3c/c8/3cc8341891a3f61a1a183036062b7148.jpg,https://files.alnair.ae/uploads/2025/10/3b/4e/3b4e57bccf453f56a7c978dc7e149da2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04550951	55.19589550	Off-plan property: SkyGate Tower by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	199445.09	0	2	1	2	33.23	113.05	\N	\N	\N	\N	\N	2025-11-02 21:43:06.073581	2025-11-02 21:43:06.073581
34207eb0-5305-4e03-9450-bee8f406852f	off-plan	Lyvia By Palace	https://files.alnair.ae/uploads/2025/10/f5/b5/f5b5462080a1fe3092a926aecb931dac.jpg,https://files.alnair.ae/uploads/2025/10/c5/19/c519bbb15b5102c53117c15b124118c8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20516428	55.35878251	Off-plan property: Lyvia By Palace by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	549137.54	1	3	1	3	70.23	170.48	\N	\N	\N	\N	\N	2025-11-02 21:43:06.075148	2025-11-02 21:43:06.075148
f177b0fc-11aa-44f3-b480-f6d48ca51760	off-plan	Lumena Alta	https://files.alnair.ae/uploads/2025/10/1b/fa/1bfa2be9e498876219c989214594ce98.jpg,https://files.alnair.ae/uploads/2025/10/2f/6c/2f6ca7d60ba005f32b581f9c7889f7b6.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18932467	55.25925349	Off-plan property: Lumena Alta by Omniyat	6e10dff0-abd2-49b5-9c98-71ec8f1b446f	6908800.00	1	3	1	3	415.18	1436.84	\N	\N	\N	\N	\N	2025-11-02 21:43:06.077409	2025-11-02 21:43:06.077409
87607df8-bad5-4103-a85f-2029c9ccc776	off-plan	New Project by Peace Homes	https://files.alnair.ae/uploads/2025/10/4e/6a/4e6a2786569bda16a1ccdf4b64096e4b.jpg,https://files.alnair.ae/uploads/2025/10/9c/48/9c488a64e6bfa2df438db513ec1c7d5c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09329389	55.37903845	Off-plan property: New Project by Peace Homes by Peace Homes Development	b8fb9b75-948a-4296-82c3-953c9d1bc61e	204000.00	0	2	1	2	42.27	139.35	\N	\N	\N	\N	\N	2025-11-02 21:43:06.080326	2025-11-02 21:43:06.080326
73638cc2-ee0c-4de0-9e16-8eeefa8e41d4	off-plan	Azizi Noura	https://files.alnair.ae/uploads/2025/9/89/6d/896d624c2fcdc752e258e20bc7b0719b.jpg,https://files.alnair.ae/uploads/2025/9/7f/78/7f78cdf11c174040ec94809a316e49f1.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.97184814	55.08972818	Off-plan property: Azizi Noura by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	159392.00	0	2	1	2	31.49	106.28	\N	\N	\N	\N	\N	2025-11-02 21:43:06.082123	2025-11-02 21:43:06.082123
dd2f75a0-9d44-4ab5-8c4e-ee900f5c368c	off-plan	Aurea	https://files.alnair.ae/uploads/2025/10/60/1e/601e84eb9c77fa49be0c30ddf6ce64aa.jpg,https://files.alnair.ae/uploads/2025/10/7c/62/7c6253712a6f599b1a3b044fb4dc00d7.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.27332673	55.28614810	Off-plan property: Aurea by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	628561.54	1	3	1	3	74.23	209.12	\N	\N	\N	\N	\N	2025-11-02 21:43:06.083779	2025-11-02 21:43:06.083779
f8ccb233-11e7-41d5-9a40-d23eaed9208a	off-plan	Helvetia Verde	https://files.alnair.ae/uploads/2025/10/bf/58/bf58ef77ea2ec4371b0b7485cd50e148.jpg,https://files.alnair.ae/uploads/2025/10/d8/dc/d8dc2c0351e104c78534faa6804b44d3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17888152	55.32253724	Off-plan property: Helvetia Verde by DHG Real Estate Group	d91870ea-e002-4706-b7d4-0251346ea15a	452851.44	1	3	1	3	79.32	286.91	\N	\N	\N	\N	\N	2025-11-02 21:43:06.086849	2025-11-02 21:43:06.086849
f9636ac9-b9fe-4f30-b318-bb6b1ee7c5e4	off-plan	The Tranquil	https://files.alnair.ae/uploads/2025/9/96/48/96486840c9262ca56fc87f630522fef5.jpg,https://files.alnair.ae/uploads/2025/9/54/1d/541d620cfdc1f9fa6d1e250cb8602d84.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06071534	55.13295949	Off-plan property: The Tranquil by Sobha	5f637246-907f-4e44-9b90-7c3065602155	504194.43	1	2	1	2	59.90	81.01	\N	\N	\N	\N	\N	2025-11-02 21:43:06.08856	2025-11-02 21:43:06.08856
a83b58de-7ed1-4505-b66e-fdd1f13f5110	off-plan	Samana Hills South 3	https://files.alnair.ae/uploads/2025/9/a3/20/a320238f15dffe388b9275fcf7bed2bb.jpg,https://files.alnair.ae/uploads/2025/9/c8/d9/c8d9f57baff20a291b64d9f182527263.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.87197151	55.03610864	Off-plan property: Samana Hills South 3 by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	241808.00	1	2	1	2	53.00	95.03	\N	\N	\N	\N	\N	2025-11-02 21:43:06.090566	2025-11-02 21:43:06.090566
b355bf25-c689-471a-9c3f-06db8644c1b4	off-plan	ELAR1S Sky	https://files.alnair.ae/uploads/2025/10/d1/d9/d1d9428404dcf3aa739ad9964df31c92.jpg,https://files.alnair.ae/uploads/2025/9/fa/1f/fa1f209375f282db9b00c22edc5fd338.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04124970	55.18610585	Off-plan property: ELAR1S Sky by Object One	9d128f32-1c6c-474d-b911-61803444decc	205451.94	0	2	1	2	35.84	151.97	\N	\N	\N	\N	\N	2025-11-02 21:43:06.092488	2025-11-02 21:43:06.092488
a7eada4d-eff0-4dcb-afec-25b4bc060d02	off-plan	Soulever Towers	https://files.alnair.ae/uploads/2025/10/a7/ee/a7ee53ebe1e23775415f9a11d8a5c8c9.jpg,https://files.alnair.ae/uploads/2025/10/82/61/826125acfe74f2862716d5a2f8bb532b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.27615281	55.26521713	Off-plan property: Soulever Towers by Beyond	7b5842d5-1b0f-4c98-900e-f6d8112df185	802128.00	1	4	1	4	78.56	284.24	\N	\N	\N	\N	\N	2025-11-02 21:43:06.09773	2025-11-02 21:43:06.09773
033737b7-f557-42d8-9fb1-e26856d8cb3e	off-plan	ELLE Residences	https://files.alnair.ae/uploads/2025/9/e8/a8/e8a89ca3fb1fd65aff38ba96cc555dde.jpg,https://files.alnair.ae/uploads/2025/9/0b/d8/0bd85c1df57ff5ad52c55c656e22ee74.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29338659	55.29183151	Off-plan property: ELLE Residences by Anax Developments	854e1059-f59d-4ff6-8bf9-368829493fbb	753107.34	2	4	2	4	90.58	331.01	\N	\N	\N	\N	\N	2025-11-02 21:43:06.100369	2025-11-02 21:43:06.100369
054ec1c2-7bf4-4684-9b65-05f44b2ea88c	off-plan	Fiori	https://files.alnair.ae/uploads/2025/9/91/5f/915fcfa03ff9aa04d1f14ffda262f5e5.jpg,https://files.alnair.ae/uploads/2025/9/fa/f4/faf42399994b243f00ec3f703f5e42d8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00248888	55.28997913	Off-plan property: Fiori by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	293729.54	1	3	1	3	58.90	133.04	\N	\N	\N	\N	\N	2025-11-02 21:43:06.102532	2025-11-02 21:43:06.102532
10724ff5-fcfb-4612-a0f4-fff1c131fc91	off-plan	Seraph by Wadan	https://files.alnair.ae/uploads/2025/9/35/c6/35c6139cd32c01625773bcfb8444276f.jpg,https://files.alnair.ae/uploads/2025/9/28/3a/283a421c1dcda26b8a3b9b93b8bbd276.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09048030	55.38435861	Off-plan property: Seraph by Wadan by Wadan Developments	b5311f1a-0732-4d83-aa70-ef1778a1ea71	283972.08	1	2	1	2	64.85	130.62	\N	\N	\N	\N	\N	2025-11-02 21:43:06.104553	2025-11-02 21:43:06.104553
733ec47f-1ad1-4610-80d1-c6131540d13b	off-plan	Palace Beach Residence	https://files.alnair.ae/uploads/2025/9/4b/ad/4bad4f0d3d1a6b9dbd2d586ed0dc5205.jpg,https://files.alnair.ae/uploads/2025/9/06/8a/068a8cec86e66d27532bca3c45e8268d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10074044	55.14327764	Off-plan property: Palace Beach Residence by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	775200.00	1	2	1	2	68.56	114.64	\N	\N	\N	\N	\N	2025-11-02 21:43:06.106188	2025-11-02 21:43:06.106188
37d3fa99-ae63-4e08-ba66-dd93d264c920	off-plan	Azizi Lina	https://files.alnair.ae/uploads/2025/9/e0/ed/e0ed0d87e71a8289c736a5e11cf02733.jpg,https://files.alnair.ae/uploads/2025/9/85/04/8504d425125eb710d0f39a631361f24d.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.97082087	55.08925929	Off-plan property: Azizi Lina by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	160752.00	0	2	1	2	29.82	126.35	\N	\N	\N	\N	\N	2025-11-02 21:43:06.107997	2025-11-02 21:43:06.107997
b6b7bf29-465c-4b3a-bc7c-02f476f7cc84	off-plan	Elevia Residences	https://files.alnair.ae/uploads/2025/9/d1/30/d1306351c57916abf7f653bd9d268c5f.png,https://files.alnair.ae/uploads/2025/9/a8/5e/a85ec47a8eb5570bfff603df78608a0a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14394864	55.39451875	Off-plan property: Elevia Residences by Valores Property Development	a0e1ea1f-6442-4058-9b2f-0d2c038b516f	149600.00	0	2	1	2	36.23	126.81	\N	\N	\N	\N	\N	2025-11-02 21:43:06.110309	2025-11-02 21:43:06.110309
65c9351e-9494-427b-8b94-5bbe5aad39e2	off-plan	Ramada Residences	https://files.alnair.ae/uploads/2025/9/45/d6/45d6e388c572d9267822259d41cb608b.jpg,https://files.alnair.ae/uploads/2025/9/a9/fd/a9fd843338b6cd5548e978e134c04205.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21097550	55.31809668	Off-plan property: Ramada Residences by BnW Developments	10858bd2-9e62-4c95-977d-0de1ed4c3d9c	503605.28	1	2	1	2	71.07	352.83	\N	\N	\N	\N	\N	2025-11-02 21:43:06.112263	2025-11-02 21:43:06.112263
b64c6a2b-60ef-49ff-abed-69fa31621f2d	off-plan	Avida Residences	https://files.alnair.ae/uploads/2025/9/b6/58/b65836ea2c88e7c3bfa662155948334c.png,https://files.alnair.ae/uploads/2025/9/cc/a6/cca6f56d1013b9ae84b025d2d54c024c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29934969	55.31423628	Off-plan property: Avida Residences by Iquna Properties	6a6bd530-ed34-4c83-8524-d06836cf429e	544000.00	1	3	1	3	75.34	188.59	\N	\N	\N	\N	\N	2025-11-02 21:43:06.116188	2025-11-02 21:43:06.116188
1337ed0c-f00b-49ae-8a66-cffd8aa5e55c	off-plan	Rise By Athlon 1	https://files.alnair.ae/uploads/2025/9/90/e5/90e577411d99b2c0c8c41c78e91bb7f8.jpg,https://files.alnair.ae/uploads/2025/9/2a/c2/2ac203c7434665c44054683240f83fdd.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05598808	55.31300783	Off-plan property: Rise By Athlon 1 by Aldar	cd0e36ac-7988-43f3-9aa0-b33902187156	512506.48	1	3	1	3	92.96	192.12	\N	\N	\N	\N	\N	2025-11-02 21:43:06.118157	2025-11-02 21:43:06.118157
6bfc1f36-2b0b-46e3-8348-b97acbfb776e	off-plan	Émerge Residences	https://files.alnair.ae/uploads/2025/9/52/ab/52ab015a727f64f8f66e356b186f4d4f.jpg,https://files.alnair.ae/uploads/2025/9/20/66/20666767ab0135965dcf4e7fba6a99d4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14861824	55.28848981	Off-plan property: Émerge Residences by Elysian Development	ba852eb1-4aa8-42a9-af72-47201dd387bc	432480.00	1	3	1	3	63.55	331.85	\N	\N	\N	\N	\N	2025-11-02 21:43:06.121201	2025-11-02 21:43:06.121201
11c5df2a-1fba-4f5e-9b44-8d54539195ef	off-plan	BREEZ by Danube	https://files.alnair.ae/uploads/2025/9/54/7f/547fb33f3c8d62da593485a468d6f42e.jpg,https://files.alnair.ae/uploads/2025/9/55/7f/557f70dbbaa50e5b2b6a2120e74bc990.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.26820311	55.27047359	Off-plan property: BREEZ by Danube by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	361216.00	0	4	1	4	34.19	321.44	\N	\N	\N	\N	\N	2025-11-02 21:43:06.123867	2025-11-02 21:43:06.123867
7c25a05b-ed11-493a-84f1-3a47d2d1ea82	off-plan	Damac District	https://files.alnair.ae/uploads/2025/9/91/b7/91b79a26fcf083715ae919ba588e19e1.png,https://files.alnair.ae/uploads/2025/9/8e/5a/8e5a75d619a9fd07c172fb866ea5589f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01585725	55.24850208	Off-plan property: Damac District by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	340000.00	1	2	1	2	63.89	105.45	\N	\N	\N	\N	\N	2025-11-02 21:43:06.126654	2025-11-02 21:43:06.126654
2eee1c45-8a78-4841-83f7-4fa2e5e08a8f	off-plan	Azizi Tower 1	https://files.alnair.ae/uploads/2025/9/a9/bf/a9bf00ee1063e895921c27e6a1768c04.jpg,https://files.alnair.ae/uploads/2025/9/1b/4e/1b4ee14eb4ff12505f9ef0564c0ff389.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21704804	55.32911316	Off-plan property: Azizi Tower 1 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	558688.00	1	3	1	3	51.47	173.54	\N	\N	\N	\N	\N	2025-11-02 21:43:06.128601	2025-11-02 21:43:06.128601
7122ae11-ea0e-4d10-9898-97ba2f4a5d3f	off-plan	Imperial Garden	https://files.alnair.ae/uploads/2025/9/48/0f/480f66dd2a5969e758439fdc19eec9d8.jpg,https://files.alnair.ae/uploads/2025/9/24/9f/249f7db0b1c3a6aed2159d416c2847f1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06288901	55.23116693	Off-plan property: Imperial Garden by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	243440.00	0	2	1	2	39.42	116.71	\N	\N	\N	\N	\N	2025-11-02 21:43:06.130126	2025-11-02 21:43:06.130126
66aea192-979f-433b-bd85-44139765212e	off-plan	Veda by AUM Development	https://files.alnair.ae/uploads/2025/8/67/01/67019e80de8e88cbe7afe055a1a25561.jpg,https://files.alnair.ae/uploads/2025/8/c9/eb/c9eb1da0f8208ef89089f718dc7d4094.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06528663	55.21422207	Off-plan property: Veda by AUM Development by AUM Development	940f3091-35c4-4af6-b1e5-eb9804af0d8c	293094.96	1	2	1	2	63.27	213.12	\N	\N	\N	\N	\N	2025-11-02 21:43:06.133091	2025-11-02 21:43:06.133091
dde0c888-0397-42e8-8196-26dd464bcbba	off-plan	Livia Residences	https://files.alnair.ae/uploads/2025/8/d1/47/d147c89822901b40caf90fc86ada9ea4.png,https://files.alnair.ae/uploads/2025/8/24/a4/24a47567fe2b307850849a2a529176eb.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94902164	55.22775511	Off-plan property: Livia Residences by Barco Developers	915b0a0a-177f-48b2-abfc-6c79d4ea741a	267526.96	1	3	1	3	76.27	122.54	\N	\N	\N	\N	\N	2025-11-02 21:43:06.135999	2025-11-02 21:43:06.135999
bb4089be-afb8-4612-aed4-3f0e50527eed	off-plan	Chapter 01	https://files.alnair.ae/uploads/2025/8/c1/ae/c1ae8466da353f8b151dd1cfe6029554.jpg,https://files.alnair.ae/uploads/2025/8/d8/eb/d8eb1d91f19fa5d422d74f4b3c345500.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14458043	55.40144678	Off-plan property: Chapter 01 by Newbury Developments	99ffeec2-1bf9-478b-b6a5-29f1a06aaeba	159120.00	0	1	1	2	42.96	93.47	\N	\N	\N	\N	\N	2025-11-02 21:43:06.137886	2025-11-02 21:43:06.137886
2bf93ce0-2ff1-4d98-82d0-9d43c46cff74	off-plan	Windsor House 2	https://files.alnair.ae/uploads/2025/8/f9/de/f9de600b122e00f1a1873e67264e81b0.jpg,https://files.alnair.ae/uploads/2025/8/c4/ac/c4acc71d76458563e02f545e1a8aa418.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94769384	55.20973228	Off-plan property: Windsor House 2 by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	470241.22	2	3	2	3	104.73	138.65	\N	\N	\N	\N	\N	2025-11-02 21:43:06.139388	2025-11-02 21:43:06.139388
4c00918f-5814-4b8e-b269-82412ac6a4a2	off-plan	Riverton House	https://files.alnair.ae/uploads/2025/8/10/bf/10bf2efd4d9d786b7f61d1aeee814d1f.jpg,https://files.alnair.ae/uploads/2025/8/8c/31/8c31cd5c03eb7d711dd7d2f520a43a2e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18260422	55.32673669	Off-plan property: Riverton House by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	590737.22	1	2	1	2	71.34	127.06	\N	\N	\N	\N	\N	2025-11-02 21:43:06.141016	2025-11-02 21:43:06.141016
378708db-a764-4a78-ad1a-28ce111e86a8	off-plan	Azizi Wares	https://files.alnair.ae/uploads/2025/8/3a/72/3a72f3c31d43f595ced97a7b3f7fcd68.jpg,https://files.alnair.ae/uploads/2025/8/fb/55/fb55d2529cfc75ee9f46d832ed0d90f2.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.95472400	55.07804094	Off-plan property: Azizi Wares by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	161568.00	0	2	1	2	30.38	100.80	\N	\N	\N	\N	\N	2025-11-02 21:43:06.143307	2025-11-02 21:43:06.143307
b575383c-0bab-4cb1-828c-84bcca273cd0	off-plan	Sunset Bay 5	https://files.alnair.ae/uploads/2025/9/10/85/1085075c28a49546f42d0e3f0e34a09e.jpg,https://files.alnair.ae/uploads/2025/9/ea/07/ea073e4a365c0469b868ab6322c288db.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29696351	55.31546608	Off-plan property: Sunset Bay 5 by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	804163.38	2	2	2	2	139.56	139.56	\N	\N	\N	\N	\N	2025-11-02 21:43:06.14497	2025-11-02 21:43:06.14497
c0b3eae3-78fa-417a-a897-2fbb007b3196	off-plan	Wynwood Horizon	https://files.alnair.ae/uploads/2025/10/f4/8d/f48d058fdce3a7cb430038a58bcc7885.jpg,https://files.alnair.ae/uploads/2025/8/9a/53/9a53305478d2d0b2ca6c3ea8dfa49d3a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18036021	55.32112901	Off-plan property: Wynwood Horizon by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	516856.85	1	2	1	2	68.19	142.23	\N	\N	\N	\N	\N	2025-11-02 21:43:06.146568	2025-11-02 21:43:06.146568
979ddc95-b3c4-4479-94cf-c0ac1d1492ba	off-plan	Samana Hills South 2	https://files.alnair.ae/uploads/2025/8/91/d4/91d4322809a5ce939fbfa05ce7d9f531.jpg,https://files.alnair.ae/uploads/2025/8/72/29/7229367e6f5c66dc8ae3713967f40752.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.87116370	55.03588200	Off-plan property: Samana Hills South 2 by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	233104.00	0	1	1	2	46.65	73.56	\N	\N	\N	\N	\N	2025-11-02 21:43:06.148275	2025-11-02 21:43:06.148275
604c6c36-1d25-4451-8108-0955c1f6eaec	off-plan	Keturah Ardh	https://files.alnair.ae/uploads/2025/8/2c/e7/2ce709f92bbca846fcd75d352c28d62f.jpg,https://files.alnair.ae/uploads/2025/9/80/ab/80abcbcfcb9cc4e0f5432c8e293fbc6c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12573293	55.43575316	Off-plan property: Keturah Ardh by MAG Property Development	d5dfad6f-2582-4be3-89ae-c5625e33a996	1782960.00	1	3	1	3	878.01	1756.02	\N	\N	\N	\N	\N	2025-11-02 21:43:06.151495	2025-11-02 21:43:06.151495
4f2a2c68-cef7-424d-9c4a-50a2a3f190a5	off-plan	Sera 2	https://files.alnair.ae/uploads/2025/8/97/d0/97d07f5a5abf8bb3236bda087bb585f9.jpg,https://files.alnair.ae/uploads/2025/8/0b/4a/0b4a90425ce0cbdf494f32503bc00995.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.27530270	55.28966993	Off-plan property: Sera 2 by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	575521.54	1	3	1	3	70.42	237.37	\N	\N	\N	\N	\N	2025-11-02 21:43:06.152332	2025-11-02 21:43:06.152332
d9ea8560-8540-460d-a4c1-4ef6b575d7d3	off-plan	Azizi David	https://files.alnair.ae/uploads/2025/8/bd/98/bd982da49158442fef31b6ef6d12d72b.jpg,https://files.alnair.ae/uploads/2025/8/42/ec/42ec9588ce3a8882aa3024e05c10bbc3.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21361315	55.32956108	Off-plan property: Azizi David by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	224128.00	0	2	1	2	30.29	451.73	\N	\N	\N	\N	\N	2025-11-02 21:43:06.153981	2025-11-02 21:43:06.153981
aa7e8dde-e11d-45b4-9b19-d3e001da39cf	off-plan	Pearl House IV	https://files.alnair.ae/uploads/2025/8/85/9a/859a085f2d35b40a51536b239f08502a.jpg,https://files.alnair.ae/uploads/2025/8/d1/ab/d1ab59f3cc4933ca1883f552aabba8af.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06069942	55.20344816	Off-plan property: Pearl House IV by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	236435.73	0	1	1	2	43.48	79.25	\N	\N	\N	\N	\N	2025-11-02 21:43:06.155794	2025-11-02 21:43:06.155794
46b6520e-dec0-40a0-8f36-8d4a42047c07	off-plan	Belle Vie	https://files.alnair.ae/uploads/2025/8/b4/5a/b45aef23b6a934fabb6ba4ffdbeef716.jpg,https://files.alnair.ae/uploads/2025/9/d3/fc/d3fc6bede9ccc94a5838ddecb12007d8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11794214	55.39315090	Off-plan property: Belle Vie by Zimaya Properties	d40a0781-0f89-4ee7-8edb-0d371bceadae	639200.00	3	4	3	4	167.04	228.08	\N	\N	\N	\N	\N	2025-11-02 21:43:06.158663	2025-11-02 21:43:06.158663
39e2c254-9e64-4538-bc5e-b3ebb3d9d84a	off-plan	Beverly Park	https://files.alnair.ae/uploads/2025/9/26/37/263789e655466852188ae7b4eb64607f.jpg,https://files.alnair.ae/uploads/2025/8/ba/8d/ba8da56824ebcbe6e19ca800c6abb6fd.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08662529	55.38331309	Off-plan property: Beverly Park by HMB Homes	5e76bc8e-626d-4bac-a67f-215db9f997ff	170000.00	0	2	1	2	33.72	108.62	\N	\N	\N	\N	\N	2025-11-02 21:43:06.160845	2025-11-02 21:43:06.160845
5dfa52ea-8e7b-4c2d-8b63-e2e8364ff561	off-plan	Nad Al Sheba Gardens Phase 8	https://files.alnair.ae/uploads/2025/8/8d/b7/8db73b600262589fef34ff2b7cbbb8e4.jpg,https://files.alnair.ae/uploads/2025/8/2b/8a/2b8a9d1cf20eb27e53d36b032c371776.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13541346	55.29970835	Off-plan property: Nad Al Sheba Gardens Phase 8 by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	5116320.00	1	3	1	3	27.24	54.49	\N	\N	\N	\N	\N	2025-11-02 21:43:06.162397	2025-11-02 21:43:06.162397
dfc213c6-6e4d-4305-a77e-f13bf0985058	off-plan	Ashwood Estates	https://files.alnair.ae/uploads/2025/9/ca/90/ca90b826e05a70a1e72ec844a947a40a.jpg,https://files.alnair.ae/uploads/2025/9/04/b4/04b40f78ae10ecccb97ee67b81dcef6e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02200527	55.17611336	Off-plan property: Ashwood Estates by Wasl	e0b7a2e8-0ba5-44cc-8ae0-f2450afb524a	5761776.00	1	3	1	3	1240.95	2481.90	\N	\N	\N	\N	\N	2025-11-02 21:43:06.164561	2025-11-02 21:43:06.164561
9cbb3993-3108-4fce-86a6-b0854fde16f4	off-plan	Nuvana by Wadan	https://files.alnair.ae/uploads/2025/8/20/f1/20f114c07ac0a6ccdf40d413aebf7c6e.jpg,https://files.alnair.ae/uploads/2025/8/0d/54/0d546eab297e494e087b8644f0e400b4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29907324	55.31585634	Off-plan property: Nuvana by Wadan by Wadan Developments	b5311f1a-0732-4d83-aa70-ef1778a1ea71	768515.33	2	2	2	2	137.82	148.26	\N	\N	\N	\N	\N	2025-11-02 21:43:06.165364	2025-11-02 21:43:06.165364
cf03bb11-3f02-4eea-b520-38f53fa24234	off-plan	The Haven 3	https://files.alnair.ae/uploads/2025/8/0b/01/0b01edce1fe5c593ebf36d7d21ff2672.jpg,https://files.alnair.ae/uploads/2025/8/ce/df/cedf916168e3bc8edd058aaa819e402b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09141550	55.32007411	Off-plan property: The Haven 3 by Meraki Developers	33c35d4c-3611-42e4-9043-c83f202fedeb	429000.85	2	2	2	2	125.87	262.13	\N	\N	\N	\N	\N	2025-11-02 21:43:06.167212	2025-11-02 21:43:06.167212
c5cd02d4-6511-46b2-96cc-b85e390e1084	off-plan	V-Suites by Anax	https://files.alnair.ae/uploads/2025/8/57/84/5784f61f1575c3946e32f9fe4883741e.jpg,https://files.alnair.ae/uploads/2025/8/9a/e3/9ae3473bb53ae4d91205fd98b1c9d408.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18074055	55.27454430	Off-plan property: V-Suites by Anax by Anax Developments	854e1059-f59d-4ff6-8bf9-368829493fbb	452547.34	0	3	1	3	44.31	262.92	\N	\N	\N	\N	\N	2025-11-02 21:43:06.168813	2025-11-02 21:43:06.168813
78d55485-7910-4c70-a567-070f61d252f7	off-plan	Avant Garde Residences 2	https://files.alnair.ae/uploads/2025/8/b7/61/b761855e8368df68eba3d2dbf312fcd4.jpg,https://files.alnair.ae/uploads/2025/8/a9/79/a97900e1518beb674ff4f6a044b3e3bb.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05655164	55.21061987	Off-plan property: Avant Garde Residences 2 by Skyline Builders	859f7e44-eab3-46ce-9366-53c19ef3cffb	199177.44	0	2	1	2	41.25	135.82	\N	\N	\N	\N	\N	2025-11-02 21:43:06.171905	2025-11-02 21:43:06.171905
5de2a696-43b5-4dd6-ba50-9e616446dc26	off-plan	The Serene	https://files.alnair.ae/uploads/2025/8/03/1a/031a79a858f4d429ecdc6f4a02923847.jpg,https://files.alnair.ae/uploads/2025/8/d9/5a/d95ababef40f0a1c33ad7d114a8ce077.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06070778	55.13297024	Off-plan property: The Serene by Sobha	5f637246-907f-4e44-9b90-7c3065602155	494549.04	1	2	1	2	59.90	79.21	\N	\N	\N	\N	\N	2025-11-02 21:43:06.173429	2025-11-02 21:43:06.173429
1b26e061-59f6-4ab7-a510-d66f1f0646b7	off-plan	Saddlewood Park	https://files.alnair.ae/uploads/2025/9/78/4c/784c37d1b89ff4c5b5d65c4a3568edd3.jpg,https://files.alnair.ae/uploads/2025/9/82/ee/82ee3be3468e10df81c44048345f05b9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.16453843	55.30468255	Off-plan property: Saddlewood Park by MAK Developers	d512be0a-9cdd-4edc-9e4c-b5dc93232758	469200.00	1	2	1	2	71.66	237.70	\N	\N	\N	\N	\N	2025-11-02 21:43:06.177427	2025-11-02 21:43:06.177427
8c7a2a9c-7783-4542-b713-87a54c1bd372	off-plan	Azizi Abraham	https://files.alnair.ae/uploads/2025/8/e8/47/e84726d48133e8789cb00c0101a38e80.png,https://files.alnair.ae/uploads/2025/8/6e/d1/6ed1ee34120280b484a8e62565840fc3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.96876802	55.08777668	Off-plan property: Azizi Abraham by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	177072.00	0	3	1	3	32.42	373.56	\N	\N	\N	\N	\N	2025-11-02 21:43:06.179056	2025-11-02 21:43:06.179056
dbd3ba7f-c8a7-4d34-97f5-7a94768a22c6	off-plan	Silena Residences	https://files.alnair.ae/uploads/2025/9/47/5d/475d6048283b1261a0b833add5a26d7d.png,https://files.alnair.ae/uploads/2025/9/0f/f4/0ff4ed73a8265a0826f665835daac2ed.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.30907699	55.31373069	Off-plan property: Silena Residences by Avenew Development	a84f875a-d9e5-456e-a713-29a09b730d2a	1088000.00	2	3	2	3	118.45	338.17	\N	\N	\N	\N	\N	2025-11-02 21:43:06.181972	2025-11-02 21:43:06.181972
6cb6258f-ec26-4308-9505-cdfe48f1b5bf	off-plan	Arka Enclave Residences	https://files.alnair.ae/uploads/2025/9/88/f3/88f3056ea3c48296aad793b3932233d3.png,https://files.alnair.ae/uploads/2025/9/b4/fc/b4fcb5c02002a8e94220197ffb76a057.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.28955491	55.30470304	Off-plan property: Arka Enclave Residences by Atmosphere Living	7ee243f4-7ce8-47ec-98d5-22959269d404	476000.00	1	3	1	3	75.99	200.58	\N	\N	\N	\N	\N	2025-11-02 21:43:06.183943	2025-11-02 21:43:06.183943
876f4c08-9ab1-4694-850d-b2bf96748d5b	off-plan	Riviera 64	https://files.alnair.ae/uploads/2025/10/70/df/70df1bc43f67556e2212c9e5dc2fd332.jpg,https://files.alnair.ae/uploads/2025/10/5e/39/5e39915c030aa0cd09bdd869a278f8d7.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17348392	55.31545288	Off-plan property: Riviera 64 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	1081200.00	1	3	1	3	56.30	267.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.185668	2025-11-02 21:43:06.185668
8bb9bca0-6c68-4096-951c-037b3bb4f833	off-plan	Riviera 62	https://files.alnair.ae/uploads/2025/10/ed/55/ed5569a5a7fed6c4fb89e27338296c5d.jpg,https://files.alnair.ae/uploads/2025/10/8a/08/8a0823ead977b27e3fb15056d1c7dcbd.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17393153	55.31524547	Off-plan property: Riviera 62 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	1044480.00	1	3	1	3	54.26	159.98	\N	\N	\N	\N	\N	2025-11-02 21:43:06.187227	2025-11-02 21:43:06.187227
c55bc3f5-eed1-4f8b-9e1e-d210d710895a	off-plan	Oasis Residences	https://files.alnair.ae/uploads/2025/8/84/d1/84d1ad43210cc1d335fb9bf8a44dbb3c.jpg,https://files.alnair.ae/uploads/2025/8/c0/6d/c06dbb9f36216f47c81720d61c67b7be.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.95137778	55.22439100	Off-plan property: Oasis Residences by HZ Development	01a96495-fe84-4b5f-8d33-66eb5b31dcad	255721.89	1	3	1	3	62.70	185.11	\N	\N	\N	\N	\N	2025-11-02 21:43:06.18907	2025-11-02 21:43:06.18907
3560891c-eef7-45d4-9c78-3e7ce450ed5b	off-plan	Sukoon By Nuri	https://files.alnair.ae/uploads/2025/10/6c/cc/6cccc8db7f83dc5e38ebc2c001e84cf8.jpg,https://files.alnair.ae/uploads/2025/10/b9/0d/b90d228fa4df7d40cd71ffc79566b515.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14956271	55.28957136	Off-plan property: Sukoon By Nuri by Nuri Living	4cf53671-daf4-4685-be03-9329745ae0a3	407456.00	1	5	1	5	62.99	460.80	\N	\N	\N	\N	\N	2025-11-02 21:43:06.191165	2025-11-02 21:43:06.191165
e89b292c-bf84-464b-969b-feae90b47723	off-plan	Olbia	https://files.alnair.ae/uploads/2025/8/18/d3/18d340aed454a066d0e8086d474f38a5.jpg,https://files.alnair.ae/uploads/2025/8/15/60/1560a132ac06c620bdb99b426f15c3f1.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00204543	55.28933442	Off-plan property: Olbia by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	281761.54	1	3	1	3	58.90	130.16	\N	\N	\N	\N	\N	2025-11-02 21:43:06.192936	2025-11-02 21:43:06.192936
295d0df1-f115-4328-ae16-4f62d8296c46	off-plan	Riviera 66	https://files.alnair.ae/uploads/2025/10/2a/51/2a51c25bfb97d78376a5628d54934527.jpg,https://files.alnair.ae/uploads/2025/10/6b/7c/6b7cccda94acc067387689fc447b7d1c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17295760	55.31573047	Off-plan property: Riviera 66 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	1146480.00	1	3	1	3	59.45	170.29	\N	\N	\N	\N	\N	2025-11-02 21:43:06.194666	2025-11-02 21:43:06.194666
57671b7d-9a36-4f25-b38a-1fffd15e0cbd	off-plan	Riviera 58	https://files.alnair.ae/uploads/2025/10/52/4a/524a4265819e3828313650462d9e7471.jpg,https://files.alnair.ae/uploads/2025/10/48/7b/487b096193d9c23e7060da96a109aa0b.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17493839	55.31509673	Off-plan property: Riviera 58 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	943840.00	1	3	1	3	48.31	165.83	\N	\N	\N	\N	\N	2025-11-02 21:43:06.196189	2025-11-02 21:43:06.196189
56a13144-49ce-4386-a34f-309de6212414	off-plan	Riviera 56	https://files.alnair.ae/uploads/2025/10/2d/a6/2da640a348cfb576df0573da47d590d2.jpg,https://files.alnair.ae/uploads/2025/10/d9/8c/d98c0f0828abcb7bd0139dec48c94200.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17530282	55.31630641	Off-plan property: Riviera 56 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	1527008.00	1	3	1	3	80.18	185.99	\N	\N	\N	\N	\N	2025-11-02 21:43:06.197761	2025-11-02 21:43:06.197761
dddc67e7-0bb2-41f7-a2bd-d291ddb59c31	off-plan	Passo	https://files.alnair.ae/uploads/2025/7/50/93/5093f8527e90df6622081ab51bc5af9e.png,https://files.alnair.ae/uploads/2025/8/bc/e2/bce276fc8b2c1ed91dd07946c45ee058.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11526936	55.10985138	Off-plan property: Passo by Beyond	7b5842d5-1b0f-4c98-900e-f6d8112df185	1135056.00	1	3	1	3	80.07	1085.85	\N	\N	\N	\N	\N	2025-11-02 21:43:06.199385	2025-11-02 21:43:06.199385
b7b9c407-15b8-4483-96a7-8a11fc39cc40	off-plan	Montiva by Vida	https://files.alnair.ae/uploads/2025/8/47/82/4782cf961576364b86e030cdbb7afc57.jpg,https://files.alnair.ae/uploads/2025/8/0f/87/0f876bcb57571cfefd3b7912fa8abd1d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20360444	55.35941323	Off-plan property: Montiva by Vida by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	528737.54	1	3	1	3	70.14	170.48	\N	\N	\N	\N	\N	2025-11-02 21:43:06.202095	2025-11-02 21:43:06.202095
07b844c5-94e0-44e6-a269-e16328520a93	off-plan	Windsor House	https://files.alnair.ae/uploads/2025/7/bc/a5/bca5925deb9f32c769e4654b714ca91d.jpg,https://files.alnair.ae/uploads/2025/7/96/ed/96edb16bce4a628eddff316162003ab4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94902797	55.20749780	Off-plan property: Windsor House by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	654929.22	3	3	3	3	138.33	139.97	\N	\N	\N	\N	\N	2025-11-02 21:43:06.203865	2025-11-02 21:43:06.203865
27f334dc-35e5-4fbd-b27e-0be939a62b56	off-plan	Blue Marina Residence	https://files.alnair.ae/uploads/2025/8/51/2d/512dae82f79e1472d06dcd8867c4cced.png,https://files.alnair.ae/uploads/2025/7/f6/a9/f6a944f350049c01bf2d7e08f4c1c672.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29098795	55.29349878	Off-plan property: Blue Marina Residence by Shakirov Developments	e7cf121d-3ef4-4943-a36a-a5dc0d8f00ec	489600.00	1	4	1	4	62.40	331.14	\N	\N	\N	\N	\N	2025-11-02 21:43:06.20663	2025-11-02 21:43:06.20663
d28a93d1-6c40-4ca0-99e0-90995a523077	off-plan	Marquis One	https://files.alnair.ae/uploads/2025/8/29/3f/293f75d7533cad3a84e872d5d331033d.png,https://files.alnair.ae/uploads/2025/7/7a/eb/7aebe93632af8f0043bbd5f02d901068.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05728499	55.24001420	Off-plan property: Marquis One by Marquis	ff247dca-88f3-41ab-96c8-84b760a6c768	212137.15	0	1	1	2	40.12	90.09	\N	\N	\N	\N	\N	2025-11-02 21:43:06.209625	2025-11-02 21:43:06.209625
f1578de6-343d-4330-b897-a75328f11f81	off-plan	Reef 997	https://files.alnair.ae/uploads/2025/9/ef/cc/efccca361f6ce9f03b396f02814e34e1.jpg,https://files.alnair.ae/uploads/2025/9/27/9e/279e52cddc9502b85e945f6d555ea51a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.28987217	55.30246238	Off-plan property: Reef 997 by Reef Luxury Developments	e8a79f19-2efe-4d72-9a9e-0e4ebc39a9ca	555335.06	1	3	1	3	72.55	236.90	\N	\N	\N	\N	\N	2025-11-02 21:43:06.211706	2025-11-02 21:43:06.211706
9419ad88-b04e-4371-904f-043dc4cd042d	off-plan	Bliss Tower	https://files.alnair.ae/uploads/2025/7/56/53/5653596146e11bd53215fd4c5f3835d3.jpg,https://files.alnair.ae/uploads/2025/7/37/59/375968130da507c9641aae74822646dd.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09726827	55.37074319	Off-plan property: Bliss Tower by Grid Properties	213e3c41-196f-436f-ba93-1c5a0d689912	311930.42	1	2	1	2	74.02	153.82	\N	\N	\N	\N	\N	2025-11-02 21:43:06.214477	2025-11-02 21:43:06.214477
6bcdfd81-e307-4ba5-bd50-97aef27813f3	off-plan	Terra Golf Collection Phase 2	https://files.alnair.ae/uploads/2025/7/ac/f9/acf9e0d099178bf8a119c62e7ca685a7.jpg,https://files.alnair.ae/uploads/2025/7/4e/a9/4ea9c83777d07b3b8285ec5de3248a5a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02270150	55.20616150	Off-plan property: Terra Golf Collection Phase 2 by Taraf	a5fa31f8-5b72-4718-a5d1-2c22a14d0782	2828800.00	1	3	1	3	17.49	34.98	\N	\N	\N	\N	\N	2025-11-02 21:43:06.21854	2025-11-02 21:43:06.21854
5233b178-75cc-48e9-962d-708ed1d04217	off-plan	Baystar by Vida	https://files.alnair.ae/uploads/2025/7/c2/10/c210e29d487923eb3331947d8ef5d288.jpg,https://files.alnair.ae/uploads/2025/7/29/84/2984c8f3c417590463afa43de683c6d3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.27027103	55.28792371	Off-plan property: Baystar by Vida by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	573889.54	1	4	1	4	67.63	274.06	\N	\N	\N	\N	\N	2025-11-02 21:43:06.219657	2025-11-02 21:43:06.219657
2b4f8dd3-74d0-49d8-8ce3-b75677a593d5	off-plan	Vedaire Residences	https://files.alnair.ae/uploads/2025/7/92/b3/92b31ee949767b1bfebd71c1ae284dcd.jpg,https://files.alnair.ae/uploads/2025/7/36/bf/36bfc60d32ad0bb485e6845195c2c09b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.15202851	55.29096273	Off-plan property: Vedaire Residences by Elton Real Estate Development	87cc7df8-ee5d-4f2a-9a75-21616d1ec6a3	399840.00	1	2	1	2	58.90	154.41	\N	\N	\N	\N	\N	2025-11-02 21:43:06.222933	2025-11-02 21:43:06.222933
272a1def-2c8f-4aa5-a5ca-8a9bcffb4150	off-plan	Binghatti Flare	https://files.alnair.ae/uploads/2025/7/d4/80/d480f05a6080b13b0154540829a9aadd.jpg,https://files.alnair.ae/uploads/2025/7/7e/72/7e72bbe9bdee9fdab61877649ad8b73a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03758741	55.17635263	Off-plan property: Binghatti Flare by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	588063.73	2	3	2	3	68.82	411.37	\N	\N	\N	\N	\N	2025-11-02 21:43:06.224556	2025-11-02 21:43:06.224556
f825d217-b74c-4ff1-bb5d-a80ba8fbe553	off-plan	Nad Al Sheba Gardens Phase 10	https://files.alnair.ae/uploads/2025/7/ee/95/ee958e82b902461190684b8125d9d1b3.jpg,https://files.alnair.ae/uploads/2025/7/16/19/161962089083c61c3941bf3b6dd53d41.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13684390	55.29437744	Off-plan property: Nad Al Sheba Gardens Phase 10 by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	5012688.00	1	3	1	3	51.51	103.02	\N	\N	\N	\N	\N	2025-11-02 21:43:06.226193	2025-11-02 21:43:06.226193
e7cbd673-d4d2-46f7-afea-0662bb62d5ed	off-plan	Ashley Hills	https://files.alnair.ae/uploads/2025/7/01/80/0180e641f09bac3bd08aee9b0d18af35.jpg,https://files.alnair.ae/uploads/2025/7/0a/bb/0abb89c1e5c7b70b04b2496ae4f45cf9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06660730	55.23511650	Off-plan property: Ashley Hills by TownX	95773061-50af-429b-ab24-d3b738a4e758	224338.80	0	3	1	3	44.89	135.17	\N	\N	\N	\N	\N	2025-11-02 21:43:06.22755	2025-11-02 21:43:06.22755
630b75f3-0b33-40b4-9fad-75e60040b47a	off-plan	Maak Residence	https://files.alnair.ae/uploads/2025/7/a1/f0/a1f0a3f7b20abd931b9b48ca8befd5e9.png,https://files.alnair.ae/uploads/2025/7/10/e4/10e486a74f5564d7b61a9be6a835cc95.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94827042	55.22867382	Off-plan property: Maak Residence by Maakdream Properties	8e755238-bd3c-4c95-a877-c4b679ad0b94	155325.60	0	2	1	2	38.74	114.55	\N	\N	\N	\N	\N	2025-11-02 21:43:06.230539	2025-11-02 21:43:06.230539
ce5c0b6b-2f45-4dca-abd9-17a1f9e32d64	off-plan	Aizel Tower	https://files.alnair.ae/uploads/2025/7/d1/c3/d1c3be610c63c0b0895230dddeb0b281.jpg,https://files.alnair.ae/uploads/2025/7/bd/6b/bd6b2c7a4a89be1577ed993efb748859.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14625348	55.39996693	Off-plan property: Aizel Tower by Maakdream Properties	8e755238-bd3c-4c95-a877-c4b679ad0b94	147981.60	0	1	1	2	37.44	92.07	\N	\N	\N	\N	\N	2025-11-02 21:43:06.232131	2025-11-02 21:43:06.232131
6a0e6928-d64e-4434-ad23-ede32d5e0a25	off-plan	Riverside Views - Marine 2	https://files.alnair.ae/uploads/2025/7/61/9b/619b18b5ff227164e53547e39abb43eb.jpg,https://files.alnair.ae/uploads/2025/7/76/8a/768a9af9dd71f8cbf6b5a2c5c77d5737.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.97635183	55.22904396	Off-plan property: Riverside Views - Marine 2 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	377264.00	1	2	1	2	83.13	137.77	\N	\N	\N	\N	\N	2025-11-02 21:43:06.233835	2025-11-02 21:43:06.233835
1a8d3fd2-2e21-427e-aea9-0baaa9995c16	off-plan	California Residences	https://files.alnair.ae/uploads/2025/7/63/5f/635f3f128d9777d4933eb630fb03ea51.jpg,https://files.alnair.ae/uploads/2025/7/77/53/7753bb704fd77433157e582d9d247cfa.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07753936	55.32512203	Off-plan property: California Residences by Infracorp	32ac4703-74ea-4f3d-ade8-96cf54c65bb6	437274.00	2	2	2	2	99.56	126.72	\N	\N	\N	\N	\N	2025-11-02 21:43:06.235875	2025-11-02 21:43:06.235875
61539fd9-115b-43e8-9bf9-f439b206547f	off-plan	Rivo	https://files.alnair.ae/uploads/2025/7/cb/d5/cbd55c5b9d88e8886b7f57a040e14dcb.png,https://files.alnair.ae/uploads/2025/7/82/27/8227d2b64dad1eea128f5e454cf2a33c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09449434	55.38152821	Off-plan property: Rivo by Grovy Real Estate Development	11570d4f-1857-4fbe-ad1e-b96b23517513	182240.00	0	4	1	4	38.62	244.29	\N	\N	\N	\N	\N	2025-11-02 21:43:06.237851	2025-11-02 21:43:06.237851
1bcdbcec-0f8a-4bdf-a21c-f6b002ce2794	off-plan	Azizi Milan Heights	https://files.alnair.ae/uploads/2025/7/46/b1/46b1e4eee40bc8b520c0ece2d6450fb2.jpg,https://files.alnair.ae/uploads/2025/7/fa/76/fa764679ca2e479c83fd1a161329f457.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08666866	55.33228723	Off-plan property: Azizi Milan Heights by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	157488.00	0	2	1	2	31.49	106.84	\N	\N	\N	\N	\N	2025-11-02 21:43:06.239703	2025-11-02 21:43:06.239703
e0bc0e5d-4ff3-4e92-9b40-21654d755c30	off-plan	Saray Prime Residences	https://files.alnair.ae/uploads/2025/7/80/44/8044f1c794a4902154c27e14c28a112a.jpg,https://files.alnair.ae/uploads/2025/7/42/7c/427c22a75b36f61fae3152bb4ef7613d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08735885	55.38116275	Off-plan property: Saray Prime Residences by Unique Saray	b4a3fbad-46eb-4799-8e96-8f9c8e68c554	167280.00	0	2	1	2	38.65	119.38	\N	\N	\N	\N	\N	2025-11-02 21:43:06.242079	2025-11-02 21:43:06.242079
60ea40a8-7827-4b67-bb6b-66ae5d1d0215	off-plan	Rosehill	https://files.alnair.ae/uploads/2025/7/1e/19/1e198d155ccd8dfc0525a7b48919c5b6.jpg,https://files.alnair.ae/uploads/2025/7/dd/3f/dd3fe8b63f9d78c90c7a80ff44996735.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13003687	55.26283040	Off-plan property: Rosehill by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	453665.54	1	3	1	3	69.21	162.02	\N	\N	\N	\N	\N	2025-11-02 21:43:06.243807	2025-11-02 21:43:06.243807
064975d6-e930-41e8-9c54-068f5e97ede8	off-plan	Arib Collection	https://files.alnair.ae/uploads/2025/7/c5/f4/c5f45bda5494475d59ce1e75ec3c4db9.jpg,https://files.alnair.ae/uploads/2025/7/c4/cb/c4cb07c9802f3d4c4ea0c440b43f22a2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09534875	55.37798434	Off-plan property: Arib Collection by ARIB Developments	2fdc703a-9a4e-4dc7-9ff4-61f71970b5e9	202368.00	0	2	1	2	42.63	126.53	\N	\N	\N	\N	\N	2025-11-02 21:43:06.245921	2025-11-02 21:43:06.245921
f97cc525-4fb1-4899-ae69-77fd9bc1346c	off-plan	Binghatti Moonlight	https://files.alnair.ae/uploads/2025/7/70/3d/703d7c4f64f63f9ae1133ad87141e095.png,https://files.alnair.ae/uploads/2025/7/80/e0/80e00bce3c42b2a75b82f0702dea3117.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22525591	55.34146027	Off-plan property: Binghatti Moonlight by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	443631.73	1	2	1	2	75.81	110.17	\N	\N	\N	\N	\N	2025-11-02 21:43:06.247431	2025-11-02 21:43:06.247431
40b14732-ece7-403c-9198-f9a3f331eae3	off-plan	Bay Grove Residences Phase 4	https://files.alnair.ae/uploads/2025/7/3d/a7/3da72938423a8ed5365502085ccbd766.jpg,https://files.alnair.ae/uploads/2025/7/ec/7f/ec7f799044799e6a02a0bc39bc4fe632.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.30249116	55.32254777	Off-plan property: Bay Grove Residences Phase 4 by Nakheel	d190bf02-5336-42e6-bba1-91ee1ab4b2d5	3048576.00	4	4	4	4	292.55	294.97	\N	\N	\N	\N	\N	2025-11-02 21:43:06.249038	2025-11-02 21:43:06.249038
9c08cc4d-3ef9-4da8-be9a-33d31c974152	off-plan	Avenew 888	https://files.alnair.ae/uploads/2025/7/e7/c4/e7c4ad5efcb6b9cd3d5279174e38ca53.png,https://files.alnair.ae/uploads/2025/7/75/f9/75f9d50693beca5841714648389ad481.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94755665	55.23021877	Off-plan property: Avenew 888 by Avenew Development	a84f875a-d9e5-456e-a713-29a09b730d2a	476000.00	2	2	2	2	89.74	89.74	\N	\N	\N	\N	\N	2025-11-02 21:43:06.250675	2025-11-02 21:43:06.250675
cf6fc1b2-06f1-4978-b04e-47f75f11adff	off-plan	Ocean Bay	https://files.alnair.ae/uploads/2025/7/f6/cb/f6cb4a2fbd696e92157ccc216dfb7bcf.jpg,https://files.alnair.ae/uploads/2025/7/d4/a0/d4a01b7651959c896f7eb743fdeacc33.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29757085	55.32039598	Off-plan property: Ocean Bay by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	567936.00	1	4	1	4	77.02	285.66	\N	\N	\N	\N	\N	2025-11-02 21:43:06.252265	2025-11-02 21:43:06.252265
ed39e78b-d873-4801-9c45-9e1d27fe20c6	off-plan	Beach Walk Grand 2	https://files.alnair.ae/uploads/2025/7/12/b9/12b9506ec7856bc468bc9181de7f184d.jpg,https://files.alnair.ae/uploads/2025/7/e2/bb/e2bbad155c09376e13be626f65b42c65.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29873950	55.29638700	Off-plan property: Beach Walk Grand 2 by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	2026808.54	3	4	3	4	340.67	403.83	\N	\N	\N	\N	\N	2025-11-02 21:43:06.253926	2025-11-02 21:43:06.253926
9d2f0b2a-c5bb-4e4b-a654-b144f22ccee7	off-plan	Zenith By AMBER	https://files.alnair.ae/uploads/2025/7/df/c8/dfc85a32c5fc94a795c11c326aa12407.jpg,https://files.alnair.ae/uploads/2025/7/15/4e/154e225266d9fd1eb042f3256ffa8c5d.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14546511	55.40288789	Off-plan property: Zenith By AMBER by AMBER Developments	a73a2a07-60b2-4148-971d-e663a13fc0ad	225243.20	1	2	1	2	76.18	159.35	\N	\N	\N	\N	\N	2025-11-02 21:43:06.256648	2025-11-02 21:43:06.256648
364c6b97-4f19-45fc-8114-8f19a909ab80	off-plan	HAYAT	https://files.alnair.ae/uploads/2025/6/49/39/49399b23321907273dea97d5ba9309db.jpg,https://files.alnair.ae/uploads/2025/6/f7/d1/f7d19d032b4ac013a0548efc43fddab4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.87533004	55.10038376	Off-plan property: HAYAT by Dubai South	e0931680-f521-469b-8c27-42de9933fb4c	1204960.00	1	3	1	3	2342.91	4685.82	\N	\N	\N	\N	\N	2025-11-02 21:43:06.259929	2025-11-02 21:43:06.259929
e3e740d1-d6a3-4ae3-822f-32d3a7a2d4e9	off-plan	Hygge Hotel	https://files.alnair.ae/uploads/2025/7/2e/8e/2e8e79df6e511a631038480be342511c.jpg,https://files.alnair.ae/uploads/2025/6/c0/39/c039e005698f4292e51cf63c5a0d4fae.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.23077325	55.16140996	Off-plan property: Hygge Hotel by The Heart of Europe	de44570c-141e-4809-a5a9-9dbc9556999c	637143.68	1	3	1	3	75.85	121.86	\N	\N	\N	\N	\N	2025-11-02 21:43:06.26208	2025-11-02 21:43:06.26208
4f160e23-c807-4496-891a-a64d671658cf	off-plan	City Walk Crestlane 1	https://files.alnair.ae/uploads/2025/6/46/de/46de8367de4ea7aa148813ce9ec583fd.jpg,https://files.alnair.ae/uploads/2025/6/09/30/093051b7b7ec325339a5abfb5be42bc3.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20485099	55.25618108	Off-plan property: City Walk Crestlane 1 by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	4535328.00	4	4	4	4	408.22	408.22	\N	\N	\N	\N	\N	2025-11-02 21:43:06.26359	2025-11-02 21:43:06.26359
8dbf701e-3224-4b59-be69-a6d3e4889490	off-plan	Sikander	https://files.alnair.ae/uploads/2025/6/e2/31/e2318ea6efef1026c121e414befeb335.jpg,https://files.alnair.ae/uploads/2025/6/98/ae/98ae3a7b28b08db2ec1c3231f8bb6ebb.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01839599	55.12194321	Off-plan property: Sikander by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	156400.00	0	2	1	2	30.10	102.94	\N	\N	\N	\N	\N	2025-11-02 21:43:06.265316	2025-11-02 21:43:06.265316
7227cd34-f4b0-4d2f-9382-6fc07ed9b1b1	off-plan	Camden	https://files.alnair.ae/uploads/2025/6/ea/57/ea57fc42bba9845e0378cc0c17c6c413.jpg,https://files.alnair.ae/uploads/2025/6/3d/78/3d789e18f30ce47c57c59b29dddf428a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00765670	55.28816253	Off-plan property: Camden by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	318481.54	1	2	1	2	61.50	92.16	\N	\N	\N	\N	\N	2025-11-02 21:43:06.266946	2025-11-02 21:43:06.266946
3b0ef420-af03-4039-a289-00b55308dd19	off-plan	Talea	https://files.alnair.ae/uploads/2025/7/6e/55/6e55fe3f3b3657132bcd48f75ba6b6e3.png,https://files.alnair.ae/uploads/2025/7/1f/44/1f44c968283bd8e9be9aaec6ab9c4049.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.27729010	55.26387850	Off-plan property: Talea by Beyond	7b5842d5-1b0f-4c98-900e-f6d8112df185	1095616.00	2	3	2	3	122.24	166.84	\N	\N	\N	\N	\N	2025-11-02 21:43:06.268502	2025-11-02 21:43:06.268502
3dc73248-0229-4684-ab5f-e97ce804e2cb	off-plan	Alta V1ew	https://files.alnair.ae/uploads/2025/6/a2/5d/a25df993d53ceadf56b1d237da9a77af.jpg,https://files.alnair.ae/uploads/2025/6/25/71/25714a80cb8c80cfb8444f951702aa9a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06309641	55.20078761	Off-plan property: Alta V1ew by Object One	9d128f32-1c6c-474d-b911-61803444decc	313681.82	1	2	1	2	66.85	197.11	\N	\N	\N	\N	\N	2025-11-02 21:43:06.270064	2025-11-02 21:43:06.270064
a3e189cf-aaaf-4628-92bc-1e19511d3738	off-plan	Velos Residences	https://files.alnair.ae/uploads/2025/6/23/eb/23eb181fad957621b815fe1d2c6c8818.jpg,https://files.alnair.ae/uploads/2025/7/d0/ab/d0ab47afa924c9246fd7aef515c00174.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05117579	55.24819627	Off-plan property: Velos Residences by City View Development	011a56d6-22b9-4e65-a12d-dbbd170458b5	233587.34	0	2	1	2	33.57	97.89	\N	\N	\N	\N	\N	2025-11-02 21:43:06.271834	2025-11-02 21:43:06.271834
85ebf052-aa03-44da-9b8d-b0e0ae2ab9c3	off-plan	The Willows Residences	https://files.alnair.ae/uploads/2025/6/ef/aa/efaa6c61911cf5e27c195af439e64714.jpg,https://files.alnair.ae/uploads/2025/6/c0/7a/c07acd4aca39e551de63040656d3b463.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13471679	55.35106805	Off-plan property: The Willows Residences by SCC Vertex Development	e1cda1ae-5c7b-4a98-8194-83279c7a1d5d	353716.42	1	2	1	2	65.03	130.53	\N	\N	\N	\N	\N	2025-11-02 21:43:06.274692	2025-11-02 21:43:06.274692
615e09c6-7401-44ac-b648-3f1d8ecda129	off-plan	Azizi Amir	https://files.alnair.ae/uploads/2025/6/f3/2e/f32ed6053e962de4f3bc1dc19b44d060.jpg,https://files.alnair.ae/uploads/2025/10/52/a8/52a8d145c1d09a0d70dc8a424755e169.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03437997	55.14468639	Off-plan property: Azizi Amir by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	365568.00	1	3	1	3	78.22	199.09	\N	\N	\N	\N	\N	2025-11-02 21:43:06.276501	2025-11-02 21:43:06.276501
893e4c74-bcf3-4cb9-bcc4-c8d4aac3fe86	off-plan	Azizi Milan 30	https://files.alnair.ae/uploads/2025/6/50/0f/500f9e46acbbecbbadffbc377689b358.jpg,https://files.alnair.ae/uploads/2025/6/d7/c2/d7c2c96cbc612f3f25f7e2b660210eca.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08991308	55.32867927	Off-plan property: Azizi Milan 30 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	161024.00	0	2	1	2	32.05	114.46	\N	\N	\N	\N	\N	2025-11-02 21:43:06.278054	2025-11-02 21:43:06.278054
e5a27666-a62d-4c44-b561-6082d21226dd	off-plan	Norah Residence	https://files.alnair.ae/uploads/2025/6/c6/3e/c63e8964b36b324bff9339a2d900996b.jpg,https://files.alnair.ae/uploads/2025/6/c3/17/c3174df904b5085d2bd0b369248be254.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04927742	55.20589918	Off-plan property: Norah Residence by Al Tareq Star Real Estate Development	37ec3b05-f9ee-4770-bc0e-2aeaf2df57df	284614.27	1	3	1	3	62.59	193.66	\N	\N	\N	\N	\N	2025-11-02 21:43:06.279947	2025-11-02 21:43:06.279947
4111900b-c4ea-46c7-94b5-367ccfd77198	off-plan	Tomorrow Commercial Tower	https://files.alnair.ae/uploads/2025/6/94/56/9456cbe901300465652cc06440dea75c.jpg,https://files.alnair.ae/uploads/2025/6/f7/4d/f74d000bd40d8035bf58e8d6d1b0eb07.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.16162415	55.40629774	Off-plan property: Tomorrow Commercial Tower by Tomorrow World Properties	e939ccf8-e520-4b87-82b1-fa43b179ccc6	434112.00	1	3	1	3	97.26	208.77	\N	\N	\N	\N	\N	2025-11-02 21:43:06.283008	2025-11-02 21:43:06.283008
6a21733d-8e99-4806-9573-158e18929f6b	off-plan	Residences Du Port Autograph Collection	https://files.alnair.ae/uploads/2025/6/d5/0a/d50a71fc5a47d2b2514eaad316b39ad2.jpg,https://files.alnair.ae/uploads/2025/6/b2/2b/b22b7b4509959e5f1bb431830a43656f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07464316	55.13730101	Off-plan property: Residences Du Port Autograph Collection by FIM Partners	edcece73-1333-439c-b5ed-30f2cf1443af	1554092.94	3	5	3	5	154.50	514.78	\N	\N	\N	\N	\N	2025-11-02 21:43:06.285778	2025-11-02 21:43:06.285778
63184687-85dd-4b76-bbb6-cd0aa74cd863	off-plan	Reem by Vision	https://files.alnair.ae/uploads/2025/6/2c/eb/2cebdec1d4522a0df25daaf9ff39d12c.jpg,https://files.alnair.ae/uploads/2025/6/3e/32/3e320b2da340927b17ff4ecf3806f3ad.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11185342	55.36733061	Off-plan property: Reem by Vision by Vision developments	e155b5fb-b446-446a-b47d-90bc8f6d55d6	510272.00	2	3	2	3	166.04	426.61	\N	\N	\N	\N	\N	2025-11-02 21:43:06.287486	2025-11-02 21:43:06.287486
0522a81c-96eb-4d9b-af15-06bf2213f6b9	off-plan	Berkeley Square	https://files.alnair.ae/uploads/2025/6/c8/f2/c8f2c0399fe69100bd3e0743471c4273.jpg,https://files.alnair.ae/uploads/2025/6/21/c1/21c1fd456ffa40ed4b2303f041cea3cf.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04875029	55.20954968	Off-plan property: Berkeley Square by Prestige One	9ac691dd-fc8e-4f5a-8a06-e72173cbc5ab	204000.00	0	3	1	3	43.06	258.27	\N	\N	\N	\N	\N	2025-11-02 21:43:06.289574	2025-11-02 21:43:06.289574
af1223bd-2a45-4d51-a004-3d1b639b49c7	off-plan	Azizi Milan 28	https://files.alnair.ae/uploads/2025/6/5e/20/5e2045b26209e7e93eb356d1c5673333.jpg,https://files.alnair.ae/uploads/2025/6/40/e1/40e19f8abd96cbc2a9cd2cef4b136252.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08992877	55.32983597	Off-plan property: Azizi Milan 28 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	160480.00	0	2	1	2	32.05	114.46	\N	\N	\N	\N	\N	2025-11-02 21:43:06.291278	2025-11-02 21:43:06.291278
71286476-2808-4696-8ab6-988ef80d1eff	off-plan	Silva	https://files.alnair.ae/uploads/2025/6/ac/1c/ac1ceb61f43cb0b0948f937d69d76c67.jpg,https://files.alnair.ae/uploads/2025/6/df/7e/df7eb25ea58e07de7043a8e34ab052cd.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20389140	55.35823308	Off-plan property: Silva by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	492561.54	1	3	1	3	69.12	170.38	\N	\N	\N	\N	\N	2025-11-02 21:43:06.293075	2025-11-02 21:43:06.293075
520cff99-fb86-4d13-8699-272f3d663a96	off-plan	Sierra	https://files.alnair.ae/uploads/2025/8/6d/23/6d23d3ee585485cf81823368b3fa6ebe.jpg,https://files.alnair.ae/uploads/2025/8/54/65/54652815b9d84a5000fab170b4b84108.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04559442	55.22715300	Off-plan property: Sierra by Iman Developers	6ad5348a-4fe7-4ee9-b98b-aa545a89e019	249142.75	0	4	1	4	38.65	374.57	\N	\N	\N	\N	\N	2025-11-02 21:43:06.295132	2025-11-02 21:43:06.295132
10a7ad5c-3f34-4887-99bb-1960621e7f61	off-plan	Aspirz By Danube	https://files.alnair.ae/uploads/2025/6/5b/74/5b74aac550fafc4f221605565f19ac57.jpg,https://files.alnair.ae/uploads/2025/6/87/4a/874ad796357f4edd96d6dff90906f3d9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04322857	55.20526618	Off-plan property: Aspirz By Danube by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	220048.00	0	3	1	3	30.47	123.28	\N	\N	\N	\N	\N	2025-11-02 21:43:06.296816	2025-11-02 21:43:06.296816
ebf53a13-445c-4b9e-bdb6-f553b440e760	off-plan	Azizi Milan 53	https://files.alnair.ae/uploads/2025/6/ca/ff/cafff9383af21693a46715cd2bdf525a.jpg,https://files.alnair.ae/uploads/2025/6/7b/12/7b1299967a61ae7f3bd09067d787f819.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08575323	55.32899435	Off-plan property: Azizi Milan 53 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	163200.00	0	3	1	3	30.57	127.46	\N	\N	\N	\N	\N	2025-11-02 21:43:06.298566	2025-11-02 21:43:06.298566
de6fc1ad-39c9-4e10-a12a-32c6df79134f	off-plan	Avana Residences	https://files.alnair.ae/uploads/2025/6/9f/ba/9fbacc374b8c57ef1b86aec2dc50a65e.jpg,https://files.alnair.ae/uploads/2025/6/94/f7/94f725481dc07e688ba078b29eea6191.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06750465	55.20538554	Off-plan property: Avana Residences by DECA Development	eb6b2103-6b04-4464-86b2-7a5e0d082452	203024.61	0	2	1	2	36.70	123.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.301466	2025-11-02 21:43:06.301466
0c611500-1d53-41e9-bb53-2deb4b2bf516	off-plan	Binghatti Twilight	https://files.alnair.ae/uploads/2025/6/d5/3e/d53e2b8ed301bca3f15e795d081425a2.jpg,https://files.alnair.ae/uploads/2025/6/5f/ce/5fce62dad2b5aafa1d299be1c3d35ac1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22478395	55.34076400	Off-plan property: Binghatti Twilight by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	489328.00	2	2	2	2	81.42	119.51	\N	\N	\N	\N	\N	2025-11-02 21:43:06.303045	2025-11-02 21:43:06.303045
7fd397be-e269-43b1-b598-b695195b8bd9	off-plan	Symbolic Zen Residences	https://files.alnair.ae/uploads/2025/6/5a/29/5a2940c94087444d65d4d9265f79c24b.jpg,https://files.alnair.ae/uploads/2025/6/c5/38/c53869caf46bbecd00361cd3c1c54da9.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03121344	55.13889281	Off-plan property: Symbolic Zen Residences by Symbolic Developments	0aed7712-3f82-4975-8d86-7bcf4076abfe	536248.00	2	3	2	3	111.01	166.88	\N	\N	\N	\N	\N	2025-11-02 21:43:06.304526	2025-11-02 21:43:06.304526
d44b0960-aa24-453a-8932-2ac0b78e29e1	off-plan	Binghatti Skyblade	https://files.alnair.ae/uploads/2025/9/40/96/4096f72a6da142b0cddb3403994cc7e5.jpg,https://files.alnair.ae/uploads/2025/9/35/be/35bed9cf20d0e5c65da17a93d15f11c6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18949600	55.27248502	Off-plan property: Binghatti Skyblade by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	455599.73	0	3	1	3	35.08	204.14	\N	\N	\N	\N	\N	2025-11-02 21:43:06.306077	2025-11-02 21:43:06.306077
c8065ed5-1fd2-475b-a0ab-936864e985d2	off-plan	Do Hotels & Residences Dubai Islands	https://files.alnair.ae/uploads/2025/6/66/47/664754ee252c8c98ee9d3f8a54af7f22.png,https://files.alnair.ae/uploads/2025/6/1f/36/1f36a57b7fccdc4a62b1539b69b7790f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.28440003	55.29385551	Off-plan property: Do Hotels & Residences Dubai Islands by One Development	043afefa-17ab-488c-93ff-b781995b857d	604928.00	1	3	1	3	77.96	191.59	\N	\N	\N	\N	\N	2025-11-02 21:43:06.308843	2025-11-02 21:43:06.308843
9db890e7-430f-472d-a382-2690e8cf0025	off-plan	The Eden	https://files.alnair.ae/uploads/2025/6/72/ce/72ce6e40ede9f6e96dd7488b1953c145.jpg,https://files.alnair.ae/uploads/2025/6/13/82/13820b1fa20f000b942b660b8ec7691b.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06070268	55.13304148	Off-plan property: The Eden by Sobha	5f637246-907f-4e44-9b90-7c3065602155	490498.69	1	2	1	2	58.68	111.67	\N	\N	\N	\N	\N	2025-11-02 21:43:06.31074	2025-11-02 21:43:06.31074
a16807e4-6c5c-4b77-8dba-09728d2f9e31	off-plan	South Square	https://files.alnair.ae/uploads/2025/6/27/5f/275fb38bbcbaeb4c061abe4430ee25b1.jpg,https://files.alnair.ae/uploads/2025/6/14/33/1433f163e47d2d1df80f8b67ec5ab0fd.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.91541191	55.10750624	Off-plan property: South Square by Dubai South	e0931680-f521-469b-8c27-42de9933fb4c	539079.25	2	3	2	3	114.27	216.37	\N	\N	\N	\N	\N	2025-11-02 21:43:06.312263	2025-11-02 21:43:06.312263
79675d23-fd13-4cd3-bf78-b61b140294e1	off-plan	Riviera 68	https://files.alnair.ae/uploads/2025/6/5d/da/5dda971cb242cad7096ee717671255a1.png,https://files.alnair.ae/uploads/2025/6/5c/e5/5ce5014d92438390e0036eec222ac27f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17262841	55.31589776	Off-plan property: Riviera 68 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	680544.00	1	3	1	3	58.16	259.66	\N	\N	\N	\N	\N	2025-11-02 21:43:06.313748	2025-11-02 21:43:06.313748
22005eda-eee3-44d0-befe-2f349a337cfa	off-plan	Riviera 50	https://files.alnair.ae/uploads/2025/6/d8/4d/d84dbda94a0a123d47a5f29b22aaa4f7.png,https://files.alnair.ae/uploads/2025/6/d5/46/d5462af64b84d4f2ea994b96735dfb57.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17350970	55.31333362	Off-plan property: Riviera 50 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	461856.00	0	2	1	2	41.62	302.12	\N	\N	\N	\N	\N	2025-11-02 21:43:06.315269	2025-11-02 21:43:06.315269
f15cd46f-2014-41ea-b9c4-d7c213d57196	off-plan	Raiha at WAADA	https://files.alnair.ae/uploads/2025/6/d8/a6/d8a660acd263593b3501912b46a0a42c.png,https://files.alnair.ae/uploads/2025/6/65/d2/65d2b683baf8d63ef1e8711a6bb12c14.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.83303187	55.11598065	Off-plan property: Raiha at WAADA by BT Properties	b8070f8b-8568-4d29-af7a-6f55156d0233	1161712.00	1	3	1	3	91.74	183.47	\N	\N	\N	\N	\N	2025-11-02 21:43:06.317989	2025-11-02 21:43:06.317989
24faf8ff-9299-496b-91ee-c6f6aade37c2	off-plan	Samana Hills South	https://files.alnair.ae/uploads/2025/6/73/1f/731f088bbee46dec64699f99244875ad.jpg,https://files.alnair.ae/uploads/2025/6/ad/14/ad14ab6fca498ac0c105f3269efe249c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.87494568	55.05038202	Off-plan property: Samana Hills South by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	273826.48	1	1	1	2	61.22	62.52	\N	\N	\N	\N	\N	2025-11-02 21:43:06.318847	2025-11-02 21:43:06.318847
73505510-137f-4877-a2ea-ecd30b8a0af5	off-plan	Akala Residences	https://files.alnair.ae/uploads/2025/6/71/73/7173c94cd00b357e8a048abe16624ec0.png,https://files.alnair.ae/uploads/2025/6/ec/11/ec116a869701df71b54d686acfcea770.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20638390	55.27697302	Off-plan property: Akala Residences by ARADA	7d6bd1e9-574b-4682-b1b0-f6ef56f1dcae	1047200.00	1	5	1	5	96.24	1359.02	\N	\N	\N	\N	\N	2025-11-02 21:43:06.32064	2025-11-02 21:43:06.32064
5666f026-4208-4400-be64-8f72fb4f72c8	off-plan	Tomorrow 166	https://files.alnair.ae/uploads/2025/5/fb/3f/fb3fdfd3a290a6139e786dfb076aa632.jpg,https://files.alnair.ae/uploads/2025/5/99/51/9951af802698ce4c94a21d03fe4bd967.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.28764964	55.29997900	Off-plan property: Tomorrow 166 by Tomorrow World Properties	e939ccf8-e520-4b87-82b1-fa43b179ccc6	580720.00	1	2	1	2	80.92	274.44	\N	\N	\N	\N	\N	2025-11-02 21:43:06.322216	2025-11-02 21:43:06.322216
355fe569-f61d-4990-b853-749f77b7c121	off-plan	Rayhan at WAADA	https://files.alnair.ae/uploads/2025/5/e4/47/e447487447fcf6acafc805128f68b1b6.png,https://files.alnair.ae/uploads/2025/5/aa/1c/aa1ca310198cf16f25f0f67e92f7fb2d.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.82831466	55.11557629	Off-plan property: Rayhan at WAADA by BT Properties	b8070f8b-8568-4d29-af7a-6f55156d0233	815456.00	1	3	1	3	291.22	582.45	\N	\N	\N	\N	\N	2025-11-02 21:43:06.32366	2025-11-02 21:43:06.32366
081e9880-0dfb-4b91-aff1-f017ceb5c4c1	off-plan	Cove Edition 6	https://files.alnair.ae/uploads/2025/5/0f/49/0f4903d0392bb7c866539c3af1ad7367.jpg,https://files.alnair.ae/uploads/2025/5/69/58/69582a490f16977b2ce2afb5c24d11c8.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09620085	55.37737700	Off-plan property: Cove Edition 6 by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	191672.14	0	0	1	2	38.46	38.46	\N	\N	\N	\N	\N	2025-11-02 21:43:06.324432	2025-11-02 21:43:06.324432
717b7d12-9773-4301-bee3-19dac0034731	off-plan	Cascada 1 at WAADA	https://files.alnair.ae/uploads/2025/5/40/c2/40c21bcd860061840e0266f8f3036e7d.png,https://files.alnair.ae/uploads/2025/5/f7/b2/f7b2ddaeca5e1e39c057567dfc3636de.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.82541271	55.11957239	Off-plan property: Cascada 1 at WAADA by BT Properties	b8070f8b-8568-4d29-af7a-6f55156d0233	360128.00	2	3	2	3	106.22	262.25	\N	\N	\N	\N	\N	2025-11-02 21:43:06.326011	2025-11-02 21:43:06.326011
91b8ccd2-7e05-4dce-814c-ca99267b2369	off-plan	DWTN Residences	https://files.alnair.ae/uploads/2025/6/87/a6/87a6024e209e9cca3fb66f31bd08cdcf.jpg,https://files.alnair.ae/uploads/2025/6/17/36/17367562aa50aff2b425b3f23694578c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19202848	55.26355259	Off-plan property: DWTN Residences by Deyaar	562c648e-bd2d-453f-83dc-6595824a64d8	584948.24	1	4	1	4	72.28	491.09	\N	\N	\N	\N	\N	2025-11-02 21:43:06.327773	2025-11-02 21:43:06.327773
fd3e3c38-b96c-4e05-a886-187abba393e3	off-plan	Manam Prime	https://files.alnair.ae/uploads/2025/5/89/05/89058fb5c1f7b1e1b0a10c9ee479b99f.jpg,https://files.alnair.ae/uploads/2025/5/52/b7/52b70b112657f4af5c0c8cab4d9cd4ce.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.95039064	55.22631409	Off-plan property: Manam Prime by Manam RED	2bef585a-c3c2-460f-abf2-64c54d018053	362457.68	2	2	2	2	104.52	104.52	\N	\N	\N	\N	\N	2025-11-02 21:43:06.330212	2025-11-02 21:43:06.330212
442eaf93-eeb8-4e34-a82e-0f885331d0ff	off-plan	Manam Pearl	https://files.alnair.ae/uploads/2025/5/8c/73/8c73f7fc9aace806d610e7163bac7346.jpg,https://files.alnair.ae/uploads/2025/6/83/ad/83ad84120cbb4d0f20f655794e9b4594.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02022495	55.13897256	Off-plan property: Manam Pearl by Manam RED	2bef585a-c3c2-460f-abf2-64c54d018053	313083.15	1	3	1	3	76.00	296.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.331762	2025-11-02 21:43:06.331762
a6809811-1b44-4cde-b9eb-b0f66d0b374e	off-plan	Chelsea Residences 2	https://files.alnair.ae/uploads/2025/5/d9/7b/d97bd69c4ec631f2e5a58b0935dd46fe.jpg,https://files.alnair.ae/uploads/2025/5/03/fb/03fb21a48ac96a4f4edb0f201a1b61b2.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.27856121	55.26053309	Off-plan property: Chelsea Residences 2 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	806752.00	1	3	1	3	85.57	190.02	\N	\N	\N	\N	\N	2025-11-02 21:43:06.333301	2025-11-02 21:43:06.333301
834b35e6-44bb-4572-8587-b3f0103a4beb	off-plan	Rimal 4	https://files.alnair.ae/uploads/2025/5/be/30/be3074d8c7094fe888345278904359ac.png,https://files.alnair.ae/uploads/2025/5/29/cc/29cc0fa8404082f3944c67cd90c04831.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07634161	55.13358200	Off-plan property: Rimal 4 by Dubai Properties	d62dd549-3ac4-4f60-bbc6-b2eb7dedf5b8	489600.00	1	1	1	2	98.81	98.81	\N	\N	\N	\N	\N	2025-11-02 21:43:06.336169	2025-11-02 21:43:06.336169
e9382800-032e-43e4-90a2-bc39c24bbc02	off-plan	Rimal 1	https://files.alnair.ae/uploads/2025/5/1d/d1/1dd1d566b97572d450f03323eb5f25de.jpg,https://files.alnair.ae/uploads/2025/5/29/76/29767cf31a38c1aa50f3b85d49970b8e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07665389	55.13489708	Off-plan property: Rimal 1 by Dubai Properties	d62dd549-3ac4-4f60-bbc6-b2eb7dedf5b8	462400.00	1	1	1	2	102.66	102.66	\N	\N	\N	\N	\N	2025-11-02 21:43:06.337921	2025-11-02 21:43:06.337921
b77de1b1-69b3-42b4-af6f-8206639720c8	off-plan	Amwaj 4	https://files.alnair.ae/uploads/2025/5/32/c0/32c03e5c4a91fb09ce9f743da5476e8b.jpg,https://files.alnair.ae/uploads/2025/5/99/cd/99cdbb4562fa346f2e203662dcf71498.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07319161	55.13141960	Off-plan property: Amwaj 4 by AMWAJ Development	ceb370e3-0562-4a9d-974c-ba77713c7b5c	761600.00	3	3	3	3	170.77	170.77	\N	\N	\N	\N	\N	2025-11-02 21:43:06.339832	2025-11-02 21:43:06.339832
ebd880df-f669-43b0-b25d-5ab5fb8f6fdc	off-plan	Naseem Townhouses	https://files.alnair.ae/uploads/2025/5/7d/9d/7d9d9a1a2277bbb8dfa157695e01e587.jpg,https://files.alnair.ae/uploads/2025/5/c9/24/c924e9a391db09df12182ad24e5932c3.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01504335	55.28342405	Off-plan property: Naseem Townhouses by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	1047200.00	1	3	1	3	2.28	4.55	\N	\N	\N	\N	\N	2025-11-02 21:43:06.341417	2025-11-02 21:43:06.341417
57939172-0965-4331-b16a-7347be35c0bb	off-plan	Treppan Serenique Residences	https://files.alnair.ae/uploads/2025/9/64/46/64468fa354ac785a0fa5808d44a0298a.jpg,https://files.alnair.ae/uploads/2025/5/c4/2a/c42a01963de4c9569b97fec5e3a45c4e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.30129327	55.30073807	Off-plan property: Treppan Serenique Residences by Fakhruddin Properties	7aa8d80f-f1da-438b-a8ac-a57d0b201cd8	776016.00	2	3	2	3	91.11	172.41	\N	\N	\N	\N	\N	2025-11-02 21:43:06.342385	2025-11-02 21:43:06.342385
5969d8cb-8639-4cf0-a85e-39ee50a93046	off-plan	Eltiera Heights	https://files.alnair.ae/uploads/2025/5/f4/42/f4420dd3ae07d733f7615989b7fce771.jpg,https://files.alnair.ae/uploads/2025/5/36/cc/36cc48e22ec15ba1670e5b6525ccb1d4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06512611	55.14507909	Off-plan property: Eltiera Heights by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	584753.22	1	3	1	3	76.34	181.12	\N	\N	\N	\N	\N	2025-11-02 21:43:06.344038	2025-11-02 21:43:06.344038
65b3d08d-e034-4fb8-9229-5f1c3cc8b8e9	off-plan	Auresta	https://files.alnair.ae/uploads/2025/5/c9/4f/c94fe949cbcde11078ba234ce009b571.jpg,https://files.alnair.ae/uploads/2025/5/36/dc/36dc5a952b2eb989a9b18090bf6ca219.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06800118	55.21680236	Off-plan property: Auresta by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	197267.46	0	3	1	3	30.50	191.69	\N	\N	\N	\N	\N	2025-11-02 21:43:06.34556	2025-11-02 21:43:06.34556
acf9b767-2781-4deb-b5f1-aa3a9cfbda40	off-plan	Burj Capital	https://files.alnair.ae/uploads/2025/5/c7/10/c7105577ab956dd4f3c046f3766fb79e.jpg,https://files.alnair.ae/uploads/2025/5/7e/83/7e83ff8ae9c5590f5b562ba1a855e6f7.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17959415	55.26697710	Off-plan property: Burj Capital by Centurion Development	dee72273-e224-48e8-b4f8-9acc72306a94	930240.00	1	3	1	3	70.09	221.08	\N	\N	\N	\N	\N	2025-11-02 21:43:06.348521	2025-11-02 21:43:06.348521
983ad764-e57c-4ba6-8ab7-a422b768c237	off-plan	Lazord by Lapis	https://files.alnair.ae/uploads/2025/5/4f/4f/4f4f633daa82ff64b070bb871f7181e5.jpg,https://files.alnair.ae/uploads/2025/5/ba/b0/bab01765b85957748452444f0c7afc68.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09459691	55.32134011	Off-plan property: Lazord by Lapis by Lapis Properties	3e7baa61-256f-4abd-9603-57f6cf367106	220021.07	0	2	1	2	35.58	110.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.350487	2025-11-02 21:43:06.350487
ba84439c-9064-4de5-8343-88ff41ebb52a	off-plan	The LX Offices Tower	https://files.alnair.ae/uploads/2025/5/f6/d2/f6d2b5a00e36f6be7aa08b7387482a53.jpg,https://files.alnair.ae/uploads/2025/6/74/85/74858a0164c8c6eefdf91fabdac8d351.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06412158	55.24388731	Off-plan property: The LX Offices Tower by Mulk Properties	2ce0c346-938b-4984-b686-5fbf92f65fbc	715360.00	1	3	1	3	112.45	1430.32	\N	\N	\N	\N	\N	2025-11-02 21:43:06.352655	2025-11-02 21:43:06.352655
b3e0ab96-c2bf-4cc7-9685-4ec563b037df	off-plan	Azizi Milan 9	https://files.alnair.ae/uploads/2025/5/36/30/3630720f794f7de2926718c7d4bc87b9.jpg,https://files.alnair.ae/uploads/2025/5/7c/da/7cda9cfcba854c0cf872808d33ca79e4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09286748	55.32771359	Off-plan property: Azizi Milan 9 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	160480.00	0	3	1	3	29.91	278.90	\N	\N	\N	\N	\N	2025-11-02 21:43:06.354302	2025-11-02 21:43:06.354302
a8fda279-1196-4fd9-a07a-979ad3736da1	off-plan	Pinewood Estate Homes	https://files.alnair.ae/uploads/2025/5/89/72/8972339ad2f7c2d8f8860718f7aab195.jpg,https://files.alnair.ae/uploads/2025/5/37/1b/371b68a530c43bf138c27e51fce34c93.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02389621	55.17660145	Off-plan property: Pinewood Estate Homes by Wasl	e0b7a2e8-0ba5-44cc-8ae0-f2450afb524a	1658323.34	1	3	1	3	1140.19	2280.38	\N	\N	\N	\N	\N	2025-11-02 21:43:06.355993	2025-11-02 21:43:06.355993
f0eeebf0-cf70-42cf-831c-ae1fe4b7d893	off-plan	AG Aum	https://files.alnair.ae/uploads/2024/10/3f/9b/3f9b3dc2a681b52ec3f80ecfe882e421.jpg,https://files.alnair.ae/uploads/2024/10/12/73/12733495f9d8db9bbc5401b0cf6c733b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09159161	55.37541211	Off-plan property: AG Aum by Ag Properties	0f7c019a-0553-415e-9c8f-d37bdb0fb1d6	265118.13	1	1	1	2	82.32	82.32	\N	\N	\N	\N	\N	2025-11-02 21:43:06.690824	2025-11-02 21:43:06.690824
1ebe7eea-4f43-4ab9-b65f-5b7fef604695	off-plan	Jumeirah Residences Emirates Towers	https://files.alnair.ae/uploads/2025/5/33/16/3316b335f12064e47855ffd2dfcf4b0e.jpg,https://files.alnair.ae/uploads/2025/5/9d/e3/9de3f376fe846b1aa288a4afd1648de5.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21721448	55.28535090	Off-plan property: Jumeirah Residences Emirates Towers by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	2909040.00	3	4	3	4	178.93	322.56	\N	\N	\N	\N	\N	2025-11-02 21:43:06.356804	2025-11-02 21:43:06.356804
39d0d8d1-d1b5-4a76-8a1d-131b3bf3c73a	off-plan	Wynwood by Imtiaz	https://files.alnair.ae/uploads/2025/5/2b/b7/2bb703b44f8a14a844b36fdd7078a805.jpg,https://files.alnair.ae/uploads/2025/5/ed/6e/ed6ee2953d8ac52d2412bfddc4aed740.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.28576123	55.29808134	Off-plan property: Wynwood by Imtiaz by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	688232.08	1	4	1	4	82.99	366.76	\N	\N	\N	\N	\N	2025-11-02 21:43:06.358387	2025-11-02 21:43:06.358387
312c2512-9817-42e5-8f5d-7a23b064f899	off-plan	The Orchard Place Solena	https://files.alnair.ae/uploads/2025/6/35/69/35699f8de02e27f52c6adfd573892def.jpg,https://files.alnair.ae/uploads/2025/6/05/6b/056b3b2544371a3c56817be13497f0f0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05518748	55.21075934	Off-plan property: The Orchard Place Solena by Peak Summit Real Estate Development	919708eb-abe9-4e30-b104-990f07b7a9c2	289136.00	1	2	1	2	65.78	124.12	\N	\N	\N	\N	\N	2025-11-02 21:43:06.361468	2025-11-02 21:43:06.361468
35f6fce4-6882-4416-b57e-e3c992a31a4b	off-plan	Capital One JVC	https://files.alnair.ae/uploads/2025/5/fb/4e/fb4ecb9cf3f3c5f59de4d158774075d5.png,https://files.alnair.ae/uploads/2025/5/56/37/56372377eee357a4f3b1318db92a8ed0.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06344614	55.21870983	Off-plan property: Capital One JVC by Centurion Development	dee72273-e224-48e8-b4f8-9acc72306a94	489297.54	1	3	1	3	80.08	233.27	\N	\N	\N	\N	\N	2025-11-02 21:43:06.363058	2025-11-02 21:43:06.363058
15a63d21-44c6-4550-9716-9d41c4522671	off-plan	Trevino	https://files.alnair.ae/uploads/2025/9/46/ae/46ae5b36bda1878df31b2374c00d3ce1.jpg,https://files.alnair.ae/uploads/2025/9/af/ec/afec8f1f8eb46cde74df66d5a6edac03.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06058033	55.19816836	Off-plan property: Trevino by Avelon Developments	9caa94ea-ce2e-4bf5-bf95-b8f6f61a8e75	215968.00	0	2	1	2	35.58	144.84	\N	\N	\N	\N	\N	2025-11-02 21:43:06.364922	2025-11-02 21:43:06.364922
e3a54d5a-b249-46f3-8f75-1412245bd9f8	off-plan	Bling Avenue 1	https://files.alnair.ae/uploads/2025/5/31/e7/31e71043a1797940b3e6979c5342f931.jpg,https://files.alnair.ae/uploads/2025/5/5b/62/5b621ec414669781b6c27da636e3838f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.95062934	55.22592321	Off-plan property: Bling Avenue 1 by Bling Development	1c770976-459d-4f31-9dba-3fa8161b0fd8	245616.00	1	2	1	2	59.97	121.38	\N	\N	\N	\N	\N	2025-11-02 21:43:06.366847	2025-11-02 21:43:06.366847
7552a51d-bbb8-462a-9b3f-6e14d9bc00bf	off-plan	Octa Isle by Missoni	https://files.alnair.ae/uploads/2025/6/05/e7/05e7490ea9615b8d025d76abea7a2d07.jpg,https://files.alnair.ae/uploads/2025/6/3b/90/3b90269d8489be25c111c9bdb1a49de7.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29621287	55.31194665	Off-plan property: Octa Isle by Missoni by OCTA Development	1d615bb7-3aee-46d9-a084-bd77590328f0	677793.54	2	3	2	3	94.82	219.28	\N	\N	\N	\N	\N	2025-11-02 21:43:06.368782	2025-11-02 21:43:06.368782
84a9633a-c363-467b-a298-a61a8f83ada8	off-plan	Gate Eleven Residences	https://files.alnair.ae/uploads/2025/5/9d/bf/9dbfeb03f0e1dac8cf572541ef796ae1.jpg,https://files.alnair.ae/uploads/2025/5/cd/b5/cdb5bd01d5b93af5b6102744c05cbee9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13264489	55.35300225	Off-plan property: Gate Eleven Residences by AMWAJ Development	ceb370e3-0562-4a9d-974c-ba77713c7b5c	418774.46	1	2	1	2	71.35	156.99	\N	\N	\N	\N	\N	2025-11-02 21:43:06.370495	2025-11-02 21:43:06.370495
cef3d5cf-8c02-41c3-88aa-280ba6c9daa2	off-plan	Alton	https://files.alnair.ae/uploads/2025/5/1f/f7/1ff703891c5e11b4be418dae82a35dfd.jpg,https://files.alnair.ae/uploads/2025/5/b7/0d/b70dde3d99ba98f29e4d317c844e807e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00417964	55.28784603	Off-plan property: Alton by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	459105.54	2	2	2	2	95.04	99.69	\N	\N	\N	\N	\N	2025-11-02 21:43:06.372083	2025-11-02 21:43:06.372083
378b456b-47bb-433c-a939-5324f4083810	off-plan	Double Tree by Hilton	https://files.alnair.ae/uploads/2025/5/f0/68/f068b2b900c626d6bf7df148f78b101b.jpg,https://files.alnair.ae/uploads/2025/5/9e/3b/9e3bd4d43283ba0bad79d7ac08f3117c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22071032	55.27133911	Off-plan property: Double Tree by Hilton by West F5 Development	f6337bc9-ff93-46d6-b8a7-875c52b5bf7c	483854.27	1	2	1	2	68.26	606.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.374922	2025-11-02 21:43:06.374922
f66ffb4c-1d18-4ae2-89ba-eb7f37e4168f	off-plan	ME DO RE Business	https://files.alnair.ae/uploads/2025/5/80/0e/800e8be67d71333056b7deca756b2727.jpg,https://files.alnair.ae/uploads/2025/5/03/0d/030dcc9a7197bc481c8014b7a3986339.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06934275	55.14422715	Off-plan property: ME DO RE Business by Me Do Re	5ef5c942-6e90-430d-b8ba-eb466d332c4d	1402160.00	1	3	1	3	136.74	198.03	\N	\N	\N	\N	\N	2025-11-02 21:43:06.377226	2025-11-02 21:43:06.377226
e02c0c20-49b7-4571-a61d-6ed2a3a62873	off-plan	Arya Residences	https://files.alnair.ae/uploads/2025/5/de/9e/de9e4067181858b13cca9432d38cff4b.jpg,https://files.alnair.ae/uploads/2025/5/a4/5d/a45d4f5c17c88c1b8a03c0bbec97b885.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.28966768	55.30714788	Off-plan property: Arya Residences by Citi Developers	62e4c532-429d-485b-bb6e-2342d13e665b	721542.29	1	3	1	3	86.93	156.49	\N	\N	\N	\N	\N	2025-11-02 21:43:06.379018	2025-11-02 21:43:06.379018
874951db-0daa-43be-813c-6c72d0f7a9a8	off-plan	Waldorf Astoria Residences Business Bay	https://files.alnair.ae/uploads/2025/5/db/8d/db8d96693913ce33fd531e2f0d31067e.jpg,https://files.alnair.ae/uploads/2025/5/bf/f5/bff56586bf46e965d4b857f0015865ac.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18747517	55.27294502	Off-plan property: Waldorf Astoria Residences Business Bay by Nabni	918debfb-40e2-4fb6-b357-ce145abb1fbf	4080000.00	2	4	2	4	203.09	396.79	\N	\N	\N	\N	\N	2025-11-02 21:43:06.38182	2025-11-02 21:43:06.38182
d4f11e1d-c7df-4b4d-8759-ac32c45eb6e7	off-plan	Arlington Park	https://files.alnair.ae/uploads/2025/5/a9/e8/a9e859eeb5980a400f73a8671ead2b78.jpg,https://files.alnair.ae/uploads/2025/5/2d/55/2d5516fd408da876b4cc08dfd2f04e9c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08879752	55.38149133	Off-plan property: Arlington Park by Majid Developments	d455a56f-fc60-458a-864a-efe2ca9f6df1	220262.88	0	1	1	2	40.23	84.54	\N	\N	\N	\N	\N	2025-11-02 21:43:06.383721	2025-11-02 21:43:06.383721
c36e76ad-a89c-4924-b9d2-452c7f901eb6	off-plan	Provenza Residences	https://files.alnair.ae/uploads/2025/5/a4/3e/a43e8d3fe80f473c33f40d00c3462af2.jpg,https://files.alnair.ae/uploads/2025/5/68/a0/68a098c4e20362f02033868d2f54f1d5.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05136646	55.20630678	Off-plan property: Provenza Residences by IKR Development	160f8678-e67b-4617-bd1b-69f252f451da	285600.00	1	2	1	2	74.13	152.46	\N	\N	\N	\N	\N	2025-11-02 21:43:06.385581	2025-11-02 21:43:06.385581
4a9b21c6-21bb-4410-b069-317e69bebdd6	off-plan	Urban Park Residences	https://files.alnair.ae/uploads/2025/5/c2/63/c263d0a7e1915be1f9df4538ccb2b2f7.jpg,https://files.alnair.ae/uploads/2025/5/c6/de/c6dec122b56d0140c6259c45c1f9feba.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03287429	55.22399940	Off-plan property: Urban Park Residences by Urban Venture	fa973820-d554-4ddd-941e-d6edb580e70c	200425.10	0	2	1	2	38.83	109.07	\N	\N	\N	\N	\N	2025-11-02 21:43:06.388311	2025-11-02 21:43:06.388311
5ee220b7-c7d5-4526-8e20-edf049331220	off-plan	Marquis Vista	https://files.alnair.ae/uploads/2025/5/b0/dc/b0dcf908c013c69e437f18dceb517dfd.jpg,https://files.alnair.ae/uploads/2025/5/03/19/0319e984812611bdd6afb1f11f85564d.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09709306	55.37488773	Off-plan property: Marquis Vista by Marquis	ff247dca-88f3-41ab-96c8-84b760a6c768	209957.62	0	1	1	2	41.78	81.38	\N	\N	\N	\N	\N	2025-11-02 21:43:06.390608	2025-11-02 21:43:06.390608
20fa6af8-a548-4d98-b473-a5a58efce541	off-plan	The Horizon	https://files.alnair.ae/uploads/2025/5/cb/61/cb61b62ed60b836cbae94d4ab02a9a5b.jpg,https://files.alnair.ae/uploads/2025/5/ed/6c/ed6cb2fe9009fc0b0d05901948e178d0.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06066044	55.13317374	Off-plan property: The Horizon by Sobha	5f637246-907f-4e44-9b90-7c3065602155	519882.58	1	2	1	2	64.56	144.37	\N	\N	\N	\N	\N	2025-11-02 21:43:06.392931	2025-11-02 21:43:06.392931
9bca98d6-dde4-46eb-ba08-6ec0db6065f6	off-plan	The Artist Hotel	https://files.alnair.ae/uploads/2025/5/cb/fc/cbfcdd70589440c8bfc02afd7757de4c.png,https://files.alnair.ae/uploads/2025/5/d9/ba/d9ba8c46e32f09d74e23d053c7a8dcfc.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.23043483	55.16069055	Off-plan property: The Artist Hotel by The Heart of Europe	de44570c-141e-4809-a5a9-9dbc9556999c	979275.89	1	3	1	3	128.30	128.30	\N	\N	\N	\N	\N	2025-11-02 21:43:06.394535	2025-11-02 21:43:06.394535
c9273af1-31c2-4416-a417-68aae9f355d2	off-plan	Ayamore Residences	https://files.alnair.ae/uploads/2025/5/af/ed/afed3429228177f28a2abeac7d057b3e.png,https://files.alnair.ae/uploads/2025/5/6e/c2/6ec28e4ca116c1bcd2d0a2bec3f80fb1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.30098325	55.31561436	Off-plan property: Ayamore Residences by AYAT Development	35f5e2f9-6f3f-4b6b-bd91-465e583df72b	625600.00	1	3	1	3	119.66	312.53	\N	\N	\N	\N	\N	2025-11-02 21:43:06.39651	2025-11-02 21:43:06.39651
5865a7f3-94ee-4ba9-b19b-f6c0008db7ff	off-plan	Voxa	https://files.alnair.ae/uploads/2025/5/b1/78/b178198ff26b586c1bd1d37d6b6a2d46.jpg,https://files.alnair.ae/uploads/2025/5/71/33/71335e1d79fd48f5da4404ddf39706a9.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04622489	55.19587509	Off-plan property: Voxa by Pantheon	a8c243a7-ac10-4ed9-a660-d05ee9b7ca60	221652.80	0	2	1	2	30.17	91.84	\N	\N	\N	\N	\N	2025-11-02 21:43:06.399986	2025-11-02 21:43:06.399986
eb9abee6-12c1-4c3b-92f9-ca251a983dd7	off-plan	Riviera 55	https://files.alnair.ae/uploads/2025/10/19/e6/19e64283889a78433cc0af343267cab0.jpg,https://files.alnair.ae/uploads/2025/6/b0/0e/b00e4618d144171bd0939901ef19346a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17572839	55.31713427	Off-plan property: Riviera 55 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	335920.00	0	0	1	2	38.74	133.32	\N	\N	\N	\N	\N	2025-11-02 21:43:06.402288	2025-11-02 21:43:06.402288
c38f6789-51dc-4fd6-887d-45d2b9e7ddb5	off-plan	Riviera 49	https://files.alnair.ae/uploads/2025/10/fe/c2/fec23d0d7f55d365e52b7f108bfea957.png,https://files.alnair.ae/uploads/2025/6/ba/04/ba04782de387d110a8717f81a57de1de.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17231169	55.31369112	Off-plan property: Riviera 49 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	448528.00	0	3	1	3	41.62	349.41	\N	\N	\N	\N	\N	2025-11-02 21:43:06.4044	2025-11-02 21:43:06.4044
3e6aa29f-d637-42db-a505-f305e1667d28	off-plan	Altan	https://files.alnair.ae/uploads/2025/5/83/bb/83bb866179d5f8eacff4c07fb1e56843.jpg,https://files.alnair.ae/uploads/2025/5/d0/4e/d04e3c04b1d1da1cc7b5bc3014dab54c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20502124	55.35590976	Off-plan property: Altan by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	495281.54	1	3	1	3	70.33	387.03	\N	\N	\N	\N	\N	2025-11-02 21:43:06.40625	2025-11-02 21:43:06.40625
86af8bf1-ee5e-4159-bb03-4a9f55e35f91	off-plan	Floarea Oasis	https://files.alnair.ae/uploads/2025/7/60/2a/602a61d2c7f20ee6abc31d089fd9632b.jpg,https://files.alnair.ae/uploads/2025/7/89/61/8961be1c3bb622efbe8097b84179f179.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09831593	55.37470442	Off-plan property: Floarea Oasis by Mashriq Elite Real Estate Development	087f0279-b93a-4dc1-aab3-0735b577e84e	171360.00	0	2	1	2	37.99	114.93	\N	\N	\N	\N	\N	2025-11-02 21:43:06.408916	2025-11-02 21:43:06.408916
4e1d5428-5047-4e34-adfd-0691d305a1f2	off-plan	Isolana Residences	https://files.alnair.ae/uploads/2025/4/53/39/53398853ea4eb4c8ba6738a5458d8da6.jpg,https://files.alnair.ae/uploads/2025/4/ff/2a/ff2a819e971fe7adbf0742e4dcb2e313.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29106471	55.30514747	Off-plan property: Isolana Residences by Hayaat Developments	85da470d-ea6e-4b00-ad63-d22a52b5dced	565209.20	1	3	1	3	77.22	291.52	\N	\N	\N	\N	\N	2025-11-02 21:43:06.411142	2025-11-02 21:43:06.411142
ce70f430-4bea-4a1d-a67f-34a9a07dd2a2	off-plan	Esplora	https://files.alnair.ae/uploads/2025/4/85/92/8592b23b1beb918f57053f54ce73ecc9.jpg,https://files.alnair.ae/uploads/2025/4/62/fe/62fee2ea9f0e476978751c2e488be0e3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05339062	55.20020485	Off-plan property: Esplora by BnW Developments	10858bd2-9e62-4c95-977d-0de1ed4c3d9c	224185.66	0	2	1	2	44.23	214.70	\N	\N	\N	\N	\N	2025-11-02 21:43:06.413154	2025-11-02 21:43:06.413154
6fd1d7dd-0ec8-4e10-a44b-a791fe959662	off-plan	Cresswell Views	https://files.alnair.ae/uploads/2025/4/98/3a/983a7e8375eef5bc030c60db04094386.jpg,https://files.alnair.ae/uploads/2025/4/1e/c9/1ec919d9c6019e65fa95f468323ad4d0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.93313391	55.22077203	Off-plan property: Cresswell Views by Arady Properties	070d7165-6484-4529-a35b-b8243677e229	417248.00	2	3	2	3	121.94	199.94	\N	\N	\N	\N	\N	2025-11-02 21:43:06.416315	2025-11-02 21:43:06.416315
5079931d-06b5-47a8-bed2-41101ba331eb	off-plan	Tulip Oasis X Residences	https://files.alnair.ae/uploads/2025/4/3b/3b/3b3b640a3f5495e5811b5ab56de6a58e.png,https://files.alnair.ae/uploads/2025/4/19/97/1997ae4dca014f01892bbb497c3dcbee.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08591958	55.31174823	Off-plan property: Tulip Oasis X Residences by Madar Developments	56ee7ade-96e8-483c-b2e4-7734335eacf9	333611.26	1	2	1	2	89.37	182.38	\N	\N	\N	\N	\N	2025-11-02 21:43:06.419104	2025-11-02 21:43:06.419104
07452643-f416-401c-8c20-ece7cf2fe551	off-plan	Azizi Milan 20	https://files.alnair.ae/uploads/2025/4/ff/c0/ffc07b6a267efc69455591d8b7c726d0.jpg,https://files.alnair.ae/uploads/2025/4/a8/34/a8349f6bc29c48ea2a7c9ff428071414.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09186610	55.33172831	Off-plan property: Azizi Milan 20 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	159936.00	0	3	1	3	31.49	214.05	\N	\N	\N	\N	\N	2025-11-02 21:43:06.420766	2025-11-02 21:43:06.420766
129f5180-1df0-4483-8079-0edd5805809d	off-plan	Azizi Milan 51	https://files.alnair.ae/uploads/2025/5/63/99/6399721f16a6bbdb2f4a1acfe932bc8d.jpg,https://files.alnair.ae/uploads/2025/5/b1/ea/b1ea5116383a09aa8df72b369765c3f7.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08579975	55.32806707	Off-plan property: Azizi Milan 51 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	159392.00	0	3	1	3	30.84	148.09	\N	\N	\N	\N	\N	2025-11-02 21:43:06.422328	2025-11-02 21:43:06.422328
7b6adca3-97e4-4674-a8ab-3fc157bd04ee	off-plan	Forest City 2	https://files.alnair.ae/uploads/2025/4/c9/ee/c9eec11f0db490851e4d3fb510fb88ab.jpg,https://files.alnair.ae/uploads/2025/4/f5/a4/f5a49ff099a4f443835407d9107207d5.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08703578	55.37917659	Off-plan property: Forest City 2 by HZ Development	01a96495-fe84-4b5f-8d33-66eb5b31dcad	185473.54	0	3	1	3	60.64	164.03	\N	\N	\N	\N	\N	2025-11-02 21:43:06.42399	2025-11-02 21:43:06.42399
301ffbb8-f5a1-4bf7-bd96-3c4bd2946efa	off-plan	Reef 998	https://files.alnair.ae/uploads/2025/6/30/21/3021956c940ee0072a51563b2dff56ee.png,https://files.alnair.ae/uploads/2025/6/1e/b2/1eb2214029d23bc453206284b4b91c69.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10007773	55.37496146	Off-plan property: Reef 998 by Reef Luxury Developments	e8a79f19-2efe-4d72-9a9e-0e4ebc39a9ca	213700.61	0	3	1	3	44.27	129.78	\N	\N	\N	\N	\N	2025-11-02 21:43:06.425922	2025-11-02 21:43:06.425922
387db737-4326-409d-96c6-7fae8e21cd9a	off-plan	Nautis Residences by STAMN	https://files.alnair.ae/uploads/2025/4/93/d6/93d67ccb595f8c3112bcc3c3153051f8.jpg,https://files.alnair.ae/uploads/2025/7/d2/23/d22355db1b09e59d49138cae06a7a18d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29262999	55.30267050	Off-plan property: Nautis Residences by STAMN by Stamn Development	0edd8c13-a7a3-4042-98f2-7b74e0791c14	654432.00	2	3	2	3	101.82	241.83	\N	\N	\N	\N	\N	2025-11-02 21:43:06.427592	2025-11-02 21:43:06.427592
c584afa7-04c1-45ea-9dd1-da41149d4fd0	off-plan	Trump International Hotel & Tower Dubai	https://files.alnair.ae/uploads/2025/4/16/36/1636377d63b41217e6446da876955ee4.jpg,https://files.alnair.ae/uploads/2025/4/9a/88/9a8801c5d85713793e4b00f3a33f2795.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20773261	55.27115260	Off-plan property: Trump International Hotel & Tower Dubai by DarGlobal	4b39b795-8d4c-4141-b0e7-2d6e9a8ba72f	774959.01	1	3	1	3	73.49	201.62	\N	\N	\N	\N	\N	2025-11-02 21:43:06.429392	2025-11-02 21:43:06.429392
7b12072a-f4a4-48dd-b40e-bc3d5ab09fba	off-plan	La Vue	https://files.alnair.ae/uploads/2025/9/f1/dc/f1dce8b4e57ab29c4fbf9930d65db4b9.jpg,https://files.alnair.ae/uploads/2025/9/3e/4a/3e4a11dab283876fb61631a7790526a6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13864439	55.31645648	Off-plan property: La Vue by MAAIA Developers	012910c3-b7c5-4260-8f83-919436c52ab7	483344.00	1	2	1	2	70.23	135.36	\N	\N	\N	\N	\N	2025-11-02 21:43:06.431243	2025-11-02 21:43:06.431243
12820bd1-d415-4ca0-b883-a1302ecd359e	off-plan	Beverly Grande	https://files.alnair.ae/uploads/2025/4/3b/7b/3b7b999081b9a59301a773e92d20f651.jpg,https://files.alnair.ae/uploads/2025/5/6a/e9/6ae992c08a6799dbc0d26dcb30b85fd0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04505230	55.23055673	Off-plan property: Beverly Grande by HMB Homes	5e76bc8e-626d-4bac-a67f-215db9f997ff	215016.00	0	3	1	3	40.69	194.53	\N	\N	\N	\N	\N	2025-11-02 21:43:06.432772	2025-11-02 21:43:06.432772
230b855e-5679-47a2-a5af-0e1f5c3274bc	off-plan	Binghatti Aquarise	https://files.alnair.ae/uploads/2025/4/f0/5e/f05e682c66f6487befdc91a1bc8f6eab.jpg,https://files.alnair.ae/uploads/2025/4/f6/b1/f6b15881310710cb57bba1948019167a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17648074	55.27322128	Off-plan property: Binghatti Aquarise by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	312527.73	0	2	1	2	43.47	1143.15	\N	\N	\N	\N	\N	2025-11-02 21:43:06.434384	2025-11-02 21:43:06.434384
28492275-50b8-4781-9723-151b3caf5d91	off-plan	Weybridge Gardens 5	https://files.alnair.ae/uploads/2025/5/32/22/32220795b2f8bd0bef7bfd0d6285defa.jpg,https://files.alnair.ae/uploads/2025/5/d2/3f/d23f9ca4b82d9e9acb6ba15c308abcac.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08631863	55.38463555	Off-plan property: Weybridge Gardens 5 by Leos Development	8f713edb-84d7-465d-8744-965901f5d7e7	208932.45	0	3	1	3	43.09	144.60	\N	\N	\N	\N	\N	2025-11-02 21:43:06.436078	2025-11-02 21:43:06.436078
35ceff68-98ec-45c3-bfa4-1977591be34d	off-plan	Sparklz	https://files.alnair.ae/uploads/2025/4/ac/a7/aca76068f559e16c4ca8a7852bb0e63e.jpg,https://files.alnair.ae/uploads/2025/4/a6/6c/a66c02068908688868e5a961e7ec6536.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02542703	55.15479513	Off-plan property: Sparklz by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	492592.00	2	3	2	3	99.61	187.49	\N	\N	\N	\N	\N	2025-11-02 21:43:06.437667	2025-11-02 21:43:06.437667
f5600c48-181b-4974-9622-1792bd15e2cc	off-plan	Vestoria Bay	https://files.alnair.ae/uploads/2025/9/79/4f/794f0208edef3443247d0c752e795193.jpg,https://files.alnair.ae/uploads/2025/9/8f/7c/8f7cae5abf0c1ff9f589bca69d51c5bc.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29102575	55.30299764	Off-plan property: Vestoria Bay by Ahmadyar Real Estate Development	e3027be7-b577-4695-abbe-4d676b3667ed	380800.00	1	3	1	3	0.00	0.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.440519	2025-11-02 21:43:06.440519
cf48cdf8-d77c-4c57-9e6f-4440ee337f81	off-plan	Floarea Skies	https://files.alnair.ae/uploads/2025/4/3f/b9/3fb958c83a33427e669f6a5fefa225fe.png,https://files.alnair.ae/uploads/2025/4/36/cc/36ccefd0bd938b23c1cc0608fa580550.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06026878	55.20401644	Off-plan property: Floarea Skies by Mashriq Elite Real Estate Development	087f0279-b93a-4dc1-aab3-0735b577e84e	211888.00	0	2	1	2	36.72	109.81	\N	\N	\N	\N	\N	2025-11-02 21:43:06.441286	2025-11-02 21:43:06.441286
df931795-3562-417f-a55c-3e857876a68f	off-plan	Wellington Villas	https://files.alnair.ae/uploads/2025/4/f7/50/f7508b9dc60caaf52ffac97ac1dfa9a6.png,https://files.alnair.ae/uploads/2025/4/16/43/1643cb693c03e7e0b6b0e63933590d46.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11285428	55.27216887	Off-plan property: Wellington Villas by Wellington Developments	6b943c81-024d-4f98-b4ea-30a841a22f9c	13056000.00	1	3	1	3	184.87	369.74	\N	\N	\N	\N	\N	2025-11-02 21:43:06.443052	2025-11-02 21:43:06.443052
44ccd0d7-0ed8-4604-aeec-28abbf8ff184	off-plan	Atélis	https://files.alnair.ae/uploads/2025/4/38/e4/38e483466c8c2e250ac0084949eaa865.png,https://files.alnair.ae/uploads/2025/4/f6/c9/f6c913e3a3d855834a739da6e85b4e58.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19013952	55.29975370	Off-plan property: Atélis by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	2292960.00	3	5	3	5	237.92	676.15	\N	\N	\N	\N	\N	2025-11-02 21:43:06.443843	2025-11-02 21:43:06.443843
de61dffa-3485-40c1-92bf-e1531ea9ec30	off-plan	Cove Grand	https://files.alnair.ae/uploads/2025/4/75/7c/757c21bccdb8f5c2ddca41283c90bcf0.jpg,https://files.alnair.ae/uploads/2025/4/70/5e/705e1ac286e62c373c96a9244d0d2500.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09441903	55.37569376	Off-plan property: Cove Grand by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	195709.71	0	0	1	2	37.78	46.45	\N	\N	\N	\N	\N	2025-11-02 21:43:06.445545	2025-11-02 21:43:06.445545
686327aa-68dc-4fe7-9105-59f330b2093b	off-plan	The Mural	https://files.alnair.ae/uploads/2025/4/1d/87/1d87cb657a81c75b8dc922a9df087264.png,https://files.alnair.ae/uploads/2025/4/10/0e/100eafe2cc5c0a14e476283bd5f26324.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.27981822	55.26589483	Off-plan property: The Mural by Beyond	7b5842d5-1b0f-4c98-900e-f6d8112df185	3036880.00	3	3	3	3	188.04	188.04	\N	\N	\N	\N	\N	2025-11-02 21:43:06.447001	2025-11-02 21:43:06.447001
b93cb50f-8797-4771-9d7b-ec4943e4c749	off-plan	Hadley Heights 2 - Olympic Edition	https://files.alnair.ae/uploads/2025/4/42/59/42598a8a7cf80c303a065219ee4a6c82.png,https://files.alnair.ae/uploads/2025/4/d3/e0/d3e00eab0037b7eb2c1777e289332e2b.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04070250	55.21775550	Off-plan property: Hadley Heights 2 - Olympic Edition by Leos Development	8f713edb-84d7-465d-8744-965901f5d7e7	209566.21	0	3	1	3	39.37	147.44	\N	\N	\N	\N	\N	2025-11-02 21:43:06.448632	2025-11-02 21:43:06.448632
5d853019-cb0d-4411-9f28-a13df5443602	off-plan	Skyvue Stellar	https://files.alnair.ae/uploads/2025/3/5f/6d/5f6d66dba5abe62fe0c52faf7aa1b21f.jpg,https://files.alnair.ae/uploads/2025/3/dc/9d/dc9d67dcb5c0f3e51a9ac1bd15830fce.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17525032	55.32392416	Off-plan property: Skyvue Stellar by Sobha	5f637246-907f-4e44-9b90-7c3065602155	632177.78	1	4	1	4	81.13	288.99	\N	\N	\N	\N	\N	2025-11-02 21:43:06.450236	2025-11-02 21:43:06.450236
48002e2d-0195-4c63-b2a2-80b2dee1b421	off-plan	Peace Lagoons 2	https://files.alnair.ae/uploads/2025/3/b0/f5/b0f5fd779f248f986d8a2b7121199d00.jpg,https://files.alnair.ae/uploads/2025/3/b6/6e/b66e85d4eefbbef570dbc38217483a1c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09815445	55.37997454	Off-plan property: Peace Lagoons 2 by Peace Homes Development	b8fb9b75-948a-4296-82c3-953c9d1bc61e	573257.95	2	2	2	2	124.65	137.38	\N	\N	\N	\N	\N	2025-11-02 21:43:06.451859	2025-11-02 21:43:06.451859
064f4a79-c021-4bf8-8b21-2fbe598589a3	off-plan	Albero at Green Gate	https://files.alnair.ae/uploads/2025/4/80/d3/80d3e0a789ca5eea439d4fc39b398b64.jpg,https://files.alnair.ae/uploads/2025/4/b4/80/b480d2679f51c3cb82d018616f146099.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20474215	55.35693973	Off-plan property: Albero at Green Gate by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	494193.54	1	3	1	3	70.33	387.03	\N	\N	\N	\N	\N	2025-11-02 21:43:06.453393	2025-11-02 21:43:06.453393
40c463aa-29d4-4237-9890-2cddd6300ed7	off-plan	Barari Heights	https://files.alnair.ae/uploads/2025/4/4e/c9/4ec92ae260da987ef05ffe9936dfa6f6.jpg,https://files.alnair.ae/uploads/2025/4/d2/f8/d2f83c65f786ba2f9e007ceedc490f9f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09462047	55.32499344	Off-plan property: Barari Heights by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	224128.00	0	0	1	2	35.56	115.54	\N	\N	\N	\N	\N	2025-11-02 21:43:06.455034	2025-11-02 21:43:06.455034
fdf62cbb-fc64-46fe-b2a9-fa60a5b36579	off-plan	High Best	https://files.alnair.ae/uploads/2025/3/cf/b1/cfb10ec69c51520640b7214e827f57e0.jpg,https://files.alnair.ae/uploads/2025/3/93/47/9347a1f09d7f6c4d60454181f0a672d6.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12697228	55.35674928	Off-plan property: High Best by True Future Real Estate Development	a13dd8ca-d6e1-4d9a-8f90-4d2b7102df1e	817573.52	1	3	1	3	94.67	109.81	\N	\N	\N	\N	\N	2025-11-02 21:43:06.456578	2025-11-02 21:43:06.456578
983fc43f-d73a-4978-b088-276926d5112a	off-plan	Azizi Milan 55	https://files.alnair.ae/uploads/2025/5/65/15/6515b8a61114c71dee5827c7fc3ac8b0.jpg,https://files.alnair.ae/uploads/2025/5/56/f3/56f3e753ae37bb50532625df116e4d04.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08489612	55.32941487	Off-plan property: Azizi Milan 55 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	159120.00	0	3	1	3	31.40	134.52	\N	\N	\N	\N	\N	2025-11-02 21:43:06.458062	2025-11-02 21:43:06.458062
cdd85e41-d12e-4084-8528-29f95b12914a	off-plan	Villa Del GAVI	https://files.alnair.ae/uploads/2025/4/f3/aa/f3aa073be1e48e3fb49affccbca99813.png,https://files.alnair.ae/uploads/2025/4/c1/ed/c1edda1aeddc82224856319269461d2a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29834328	55.29521150	Off-plan property: Villa Del GAVI by Mr. Eight	378511a2-e46d-48ad-88a8-72584c46191c	1077392.00	2	4	2	4	98.46	497.10	\N	\N	\N	\N	\N	2025-11-02 21:43:06.460162	2025-11-02 21:43:06.460162
0cc28e44-5e3d-4c28-998e-2ee651d1ae06	off-plan	Selora Residences	https://files.alnair.ae/uploads/2025/4/e9/a1/e9a1d1782119dc5b6611c2a15259c1dd.jpg,https://files.alnair.ae/uploads/2025/4/06/c6/06c62aca383badec7ece0572790fa654.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12826782	55.34866512	Off-plan property: Selora Residences by Swank Development	66b21269-e00c-43f6-9877-fe1e96f961fd	2624800.00	1	3	1	3	61.27	122.54	\N	\N	\N	\N	\N	2025-11-02 21:43:06.46301	2025-11-02 21:43:06.46301
900ee819-9c79-48de-9838-014f48a07662	off-plan	Zyra Vista	https://files.alnair.ae/uploads/2025/3/67/10/67101688d94f40af5fd8a81113fa14eb.jpg,https://files.alnair.ae/uploads/2025/3/ac/94/ac9473f3ebae8f6f4c5eed7ab6284399.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14650891	55.38843889	Off-plan property: Zyra Vista by Laraix	6a09ba6f-ee6e-4928-a2cb-193aef26db85	243145.97	1	2	1	2	69.79	133.98	\N	\N	\N	\N	\N	2025-11-02 21:43:06.46504	2025-11-02 21:43:06.46504
f6edb1f8-a90f-4b37-abd2-9435aac5708f	off-plan	V1stara House 2	https://files.alnair.ae/uploads/2025/3/f8/b1/f8b1bdb477e9254824e61b6c5e691bfa.jpg,https://files.alnair.ae/uploads/2025/3/70/42/70426d6e52cd4da402cf39a9ad904d67.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03085108	55.14027625	Off-plan property: V1stara House 2 by Object One	9d128f32-1c6c-474d-b911-61803444decc	578514.08	1	3	1	3	145.29	334.32	\N	\N	\N	\N	\N	2025-11-02 21:43:06.46678	2025-11-02 21:43:06.46678
a5c69114-1acc-4a2f-83f4-f6d37b8bac03	off-plan	Samana Barari Avenue	https://files.alnair.ae/uploads/2025/3/de/26/de266ddbde6e7529ec6ab76454ff2307.jpg,https://files.alnair.ae/uploads/2025/3/9b/ed/9bed66297ff75ef5f1d0c11f0fb55fbc.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09353714	55.31143606	Off-plan property: Samana Barari Avenue by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	601442.05	1	3	1	3	93.55	217.69	\N	\N	\N	\N	\N	2025-11-02 21:43:06.468441	2025-11-02 21:43:06.468441
8383095a-f731-4069-9bd5-f7ae5426adfc	off-plan	Wellington Grand Villas	https://files.alnair.ae/uploads/2025/3/f9/b1/f9b19fef720d30c55eac736076c9643d.png,https://files.alnair.ae/uploads/2025/5/e9/1f/e91fc6785bdfe0e60373d84dd6904003.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13073032	55.34171500	Off-plan property: Wellington Grand Villas by Wellington Developments	6b943c81-024d-4f98-b4ea-30a841a22f9c	5644000.00	1	3	1	3	653.36	1306.71	\N	\N	\N	\N	\N	2025-11-02 21:43:06.469959	2025-11-02 21:43:06.469959
abe94af8-4c12-41e1-b94b-01fc6ab53cae	off-plan	Woodland Crest	https://files.alnair.ae/uploads/2025/4/52/3d/523d0ecf3dd81fb9f1d945b5b5e61f48.png,https://files.alnair.ae/uploads/2025/6/b8/03/b8038df3eaed25186f8ae7d0e96b543f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.15257030	55.28977186	Off-plan property: Woodland Crest by AMIS Properties	930bd2d2-cfc4-4ae6-8d21-0a27559e4030	401304.99	1	2	1	2	64.38	95.69	\N	\N	\N	\N	\N	2025-11-02 21:43:06.470731	2025-11-02 21:43:06.470731
8aec2bc8-a6e9-4406-8868-30fc64f40ce2	off-plan	Golf Verge	https://files.alnair.ae/uploads/2025/3/5b/b0/5bb01dc0df55f8c2190d9fdf357145c6.jpg,https://files.alnair.ae/uploads/2025/3/20/5a/205af47740399543155a267facb9bbee.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.86236025	55.13583238	Off-plan property: Golf Verge by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	697105.54	2	3	2	3	121.52	165.09	\N	\N	\N	\N	\N	2025-11-02 21:43:06.472321	2025-11-02 21:43:06.472321
4e48f362-85d8-44d7-8496-4f1d19a55f4a	off-plan	Golf Meadow	https://files.alnair.ae/uploads/2025/3/97/f1/97f1042bf98d88ae4a41a160f53a9f3e.jpg,https://files.alnair.ae/uploads/2025/3/3b/15/3b15abb0f1142988e9da9978039169b4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.86155417	55.13536706	Off-plan property: Golf Meadow by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	744977.54	3	3	3	3	145.86	266.63	\N	\N	\N	\N	\N	2025-11-02 21:43:06.473867	2025-11-02 21:43:06.473867
1a796bf8-3707-4ff9-b04c-2cff72af66fa	off-plan	Rabdan Gates	https://files.alnair.ae/uploads/2025/6/83/2c/832c528719a28fcab4faa7fe5be299c2.png,https://files.alnair.ae/uploads/2025/5/22/af/22afd4a617984fe206792d8cad74da7b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08916914	55.31979126	Off-plan property: Rabdan Gates by Rabdan Real Estate Developments	8147c5dd-d275-4d04-84d4-4fce9ce87e0e	302464.00	1	3	1	3	65.78	253.16	\N	\N	\N	\N	\N	2025-11-02 21:43:06.475455	2025-11-02 21:43:06.475455
80c51df6-61f2-4c88-a34f-8002996ed35a	off-plan	Tulip Oasis 11	https://files.alnair.ae/uploads/2025/7/30/9b/309b0e8b5c2ae5e1d632fbda6f47d417.png,https://files.alnair.ae/uploads/2025/7/8d/ad/8dadd5bd96f73ed29654e2f3a5ee0189.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09167525	55.32052189	Off-plan property: Tulip Oasis 11 by Madar Developments	56ee7ade-96e8-483c-b2e4-7734335eacf9	295120.00	1	2	1	2	75.16	244.06	\N	\N	\N	\N	\N	2025-11-02 21:43:06.477157	2025-11-02 21:43:06.477157
381e73fe-847c-4777-a8a4-b4251c199884	off-plan	Verdan1a 2	https://files.alnair.ae/uploads/2025/3/73/68/73687c8a88515c8dc61d58e1bc94a60c.jpg,https://files.alnair.ae/uploads/2025/3/a5/cd/a5cdfac34b9215823f81d6570247a230.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08667746	55.38365118	Off-plan property: Verdan1a 2 by Object One	9d128f32-1c6c-474d-b911-61803444decc	309063.81	1	2	1	2	72.75	128.46	\N	\N	\N	\N	\N	2025-11-02 21:43:06.479162	2025-11-02 21:43:06.479162
6f20ad9a-dbfb-438b-9873-477fdfbc9c92	off-plan	DG Villas	https://files.alnair.ae/uploads/2025/3/c9/de/c9deab47ee7b8e15eedcfdb9e3cea6e4.jpg,https://files.alnair.ae/uploads/2025/3/cb/44/cb44ba0369c478c1f69b78055047f965.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01080010	55.20154059	Off-plan property: DG Villas by DarGlobal	4b39b795-8d4c-4141-b0e7-2d6e9a8ba72f	1858802.58	1	3	1	3	836.08	1672.16	\N	\N	\N	\N	\N	2025-11-02 21:43:06.481234	2025-11-02 21:43:06.481234
30973a95-f62a-4af6-af10-a13bc24cb2cb	off-plan	Distrikt	https://files.alnair.ae/uploads/2025/6/36/9c/369cd207a6525a64f273e79281591c7b.jpg,https://files.alnair.ae/uploads/2025/6/5b/cc/5bcc445af3fe97d7059a28ae8c4f2b98.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07513122	55.31860694	Off-plan property: Distrikt by Majid Al Futtaim	4e3d71dd-2644-44ab-b07f-17f13ee73227	761600.00	2	2	2	2	134.08	203.75	\N	\N	\N	\N	\N	2025-11-02 21:43:06.482049	2025-11-02 21:43:06.482049
61eca2c9-bac5-4e92-a0cb-3a712db54a58	off-plan	Al Waha Residences 2	https://files.alnair.ae/uploads/2025/5/c9/e5/c9e5b02d1fd38ef44ec38be58d92e688.jpg,https://files.alnair.ae/uploads/2025/5/bb/9d/bb9d82e5b8e84b43c390c8e8e8550ebe.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.96407451	55.15176281	Off-plan property: Al Waha Residences 2 by Expo City	f152c1f4-6ec3-4c04-8438-a8190b3b68de	1670080.00	2	2	2	2	223.70	224.87	\N	\N	\N	\N	\N	2025-11-02 21:43:06.484792	2025-11-02 21:43:06.484792
34e54881-e10c-4950-9d1b-e9d7a58e5938	off-plan	Olaia Residences	https://files.alnair.ae/uploads/2025/4/3f/ad/3fade815a4f0c45eb5858a53f031f5f2.jpg,https://files.alnair.ae/uploads/2025/4/cf/71/cf71e1b92e988f7d1c767121c655e44a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10982464	55.14345057	Off-plan property: Olaia Residences by Gulf House Real Estate Development	d4806be0-1e85-4fe0-8a32-d8a7e98fc72e	1020562.22	1	5	1	5	103.89	383.19	\N	\N	\N	\N	\N	2025-11-02 21:43:06.487569	2025-11-02 21:43:06.487569
ec4a035e-0ef6-4a8f-9a2b-f93f1fc48834	off-plan	VELOR	https://files.alnair.ae/uploads/2025/5/86/0e/860ef28329f6a9378f22c69f4db85706.jpg,https://files.alnair.ae/uploads/2025/5/c8/27/c8273c60d7300b6fc454957b6ecb883a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19144234	55.28402992	Off-plan property: VELOR by Ginco Properties	506e86f8-e9a6-4cf0-87d2-a7db97ac97b9	2244000.00	4	5	4	5	278.69	559.08	\N	\N	\N	\N	\N	2025-11-02 21:43:06.489433	2025-11-02 21:43:06.489433
ea1e050e-c6a3-4589-9119-1451acb8760d	off-plan	Capria West	https://files.alnair.ae/uploads/2025/3/ca/37/ca378cd84c478b1c184a7a4dfd36864f.jpg,https://files.alnair.ae/uploads/2025/3/6b/a3/6ba3b54117ca7509ed289295f6578bbc.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07466717	55.31337258	Off-plan property: Capria West by Majid Al Futtaim	4e3d71dd-2644-44ab-b07f-17f13ee73227	1049920.00	3	3	3	3	165.31	167.81	\N	\N	\N	\N	\N	2025-11-02 21:43:06.491039	2025-11-02 21:43:06.491039
507313ff-10ae-468d-8407-bdb7e089c344	off-plan	Samana Business Park	https://files.alnair.ae/uploads/2025/3/53/34/5334362d9386a329fa34c0d89d79f416.jpg,https://files.alnair.ae/uploads/2025/3/fe/22/fe2212b281d3429c6e6be4bdc4874227.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09501198	55.32013439	Off-plan property: Samana Business Park by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	620736.91	1	3	1	3	75.72	330.89	\N	\N	\N	\N	\N	2025-11-02 21:43:06.492895	2025-11-02 21:43:06.492895
3310faac-d50e-43d5-85b4-b8119c4c5ca5	off-plan	Skyvue Spectra	https://files.alnair.ae/uploads/2025/3/68/84/68841997d889956b766680d974126b72.jpg,https://files.alnair.ae/uploads/2025/3/93/96/939645e6b7ccfbeefdeddeed63714f1b.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17627197	55.32480016	Off-plan property: Skyvue Spectra by Sobha	5f637246-907f-4e44-9b90-7c3065602155	550269.33	1	3	1	3	70.26	159.04	\N	\N	\N	\N	\N	2025-11-02 21:43:06.494585	2025-11-02 21:43:06.494585
ce07b5f3-e1b8-44d8-b6e9-07d09081adec	off-plan	Chelsea Gardens	https://files.alnair.ae/uploads/2025/2/0a/0e/0a0e1e334eb51b3d97a4f0c87912aca9.jpg,https://files.alnair.ae/uploads/2025/2/d6/ba/d6ba54340d5fc1ed92d3de1597f31303.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22732302	55.27922876	Off-plan property: Chelsea Gardens by Alaia Developments	ea962861-233a-4782-8270-9dec56e616c5	326641.54	0	2	1	2	44.78	136.10	\N	\N	\N	\N	\N	2025-11-02 21:43:06.497486	2025-11-02 21:43:06.497486
1fdab001-bf5c-4708-bd10-80aa83f812ce	off-plan	SOL Levante	https://files.alnair.ae/uploads/2025/2/ff/34/ff341fab811e909b78a3d5818a82ce2f.jpg,https://files.alnair.ae/uploads/2025/2/d1/6c/d16c24eb54b7b302a535b2d8cb3af514.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03441931	55.17527908	Off-plan property: SOL Levante by SOL Properties	da59d484-2f29-4f4b-849b-6f69819597ac	222496.00	0	2	1	2	39.01	159.47	\N	\N	\N	\N	\N	2025-11-02 21:43:06.499132	2025-11-02 21:43:06.499132
6999da94-9a4b-4ed2-9453-df275074b9e6	off-plan	Lume Residences	https://files.alnair.ae/uploads/2025/3/88/14/881483d48bc5668ad7c5fa15b0d5365f.jpg,https://files.alnair.ae/uploads/2025/2/7e/94/7e9455c095d90126887647f26f6eade0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05446886	55.19874439	Off-plan property: Lume Residences by S&S Developments	4b4be146-17ea-4781-ac9d-a76499af62d8	189251.34	0	2	1	2	32.29	107.54	\N	\N	\N	\N	\N	2025-11-02 21:43:06.501509	2025-11-02 21:43:06.501509
e182f799-1dfc-4a88-96da-d8c55aa3b4a7	off-plan	Trussardi Residences 2	https://files.alnair.ae/uploads/2025/2/79/e1/79e16ceb559253e324c36fd5c5b297c0.jpg,https://files.alnair.ae/uploads/2025/2/55/29/55295fee87bf1389b252f57c7295292d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03686227	55.14469251	Off-plan property: Trussardi Residences 2 by Mira Developments	b99a2707-a8ba-4b3f-a4d2-ed2cf388a8a9	247356.80	0	2	1	2	37.00	184.99	\N	\N	\N	\N	\N	2025-11-02 21:43:06.503569	2025-11-02 21:43:06.503569
8a5eaaa1-ca01-4418-a250-de97afa18a62	off-plan	SOLA Residences	https://files.alnair.ae/uploads/2025/2/c3/e8/c3e8bf6f2bb6e52216e20f67816294b4.jpg,https://files.alnair.ae/uploads/2025/2/fc/28/fc28b5cd9edc269e6a009bb89005eb5d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02080929	55.10654479	Off-plan property: SOLA Residences by Wasl	e0b7a2e8-0ba5-44cc-8ae0-f2450afb524a	320144.00	1	3	1	3	66.87	169.35	\N	\N	\N	\N	\N	2025-11-02 21:43:06.505087	2025-11-02 21:43:06.505087
1f2577b1-0439-46d0-b04b-bc353bff0d94	off-plan	Zenith J1	https://files.alnair.ae/uploads/2025/6/35/a7/35a77a9b3f3763bd0e4aef5433278f97.jpg,https://files.alnair.ae/uploads/2025/9/06/ee/06ee7915f81504f64524690e28258f67.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06187536	55.20199656	Off-plan property: Zenith J1 by Zenith Ventures Real Estate Development	48841087-0b08-4dbe-837e-7e87737849d9	349801.25	1	3	1	3	62.88	221.14	\N	\N	\N	\N	\N	2025-11-02 21:43:06.506863	2025-11-02 21:43:06.506863
334d7f12-b882-4d28-a1be-bb765bf72a19	off-plan	Celesto Tower	https://files.alnair.ae/uploads/2025/5/a3/5d/a35de9c410ff1eb9904c164aef033efa.jpg,https://files.alnair.ae/uploads/2025/2/9e/fb/9efb969b69c7ce742c50700e7a9dab29.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09694249	55.37734918	Off-plan property: Celesto Tower by Tarrad Development	6577dd65-71ee-4552-9286-4f98df3cc883	176854.13	0	1	1	2	37.42	69.68	\N	\N	\N	\N	\N	2025-11-02 21:43:06.508906	2025-11-02 21:43:06.508906
8173765f-6e52-41ca-a79c-cabdc4e598c1	off-plan	Cove Boulevard	https://files.alnair.ae/uploads/2025/2/7c/c8/7cc8262a7a3ec8712d9ed254137e9f2f.jpg,https://files.alnair.ae/uploads/2025/2/70/71/7071d77899c74cacb56e7226fadd0dd0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10044776	55.37662205	Off-plan property: Cove Boulevard by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	507320.80	2	2	2	2	117.13	1276.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.510748	2025-11-02 21:43:06.510748
54e6c982-1f66-4a91-a92f-938af38c2da8	off-plan	Firoza	https://files.alnair.ae/uploads/2025/5/2c/97/2c97485fdbcf5c56ac0e16e8fb3da652.jpg,https://files.alnair.ae/uploads/2025/5/77/6b/776b39fbfef00bdcd2f298990ec55ec6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29081783	55.30321586	Off-plan property: Firoza by Ever Glory Developments	5b8b35fb-2293-44cf-bb20-a1dd6ecd4d5e	464305.63	1	3	1	3	75.25	307.14	\N	\N	\N	\N	\N	2025-11-02 21:43:06.512791	2025-11-02 21:43:06.512791
c74e71b9-bcd9-4f7c-9ff0-180592d3c63f	off-plan	Vida Residences Hillside	https://files.alnair.ae/uploads/2025/5/ea/44/ea44fd798df158f482ac951bcbda9ebb.jpg,https://files.alnair.ae/uploads/2025/5/82/45/82454eadc7178078691c99548d48b442.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11365040	55.25155954	Off-plan property: Vida Residences Hillside by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	502897.54	1	3	1	3	67.63	147.07	\N	\N	\N	\N	\N	2025-11-02 21:43:06.514507	2025-11-02 21:43:06.514507
73a78611-8a90-4b45-b776-a5f5c945dcfb	off-plan	Celeste	https://files.alnair.ae/uploads/2025/5/01/38/013841f2262aa3d0f9c26c69a3e28242.png,https://files.alnair.ae/uploads/2025/5/c4/c8/c4c8bc9f6433acee7a1a35ec94f3b400.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22762466	55.33791817	Off-plan property: Celeste by HRE Development	081fa9d3-a0f7-4d05-ab75-aa99feb00da8	400384.00	1	3	1	3	62.34	186.08	\N	\N	\N	\N	\N	2025-11-02 21:43:06.516189	2025-11-02 21:43:06.516189
bfc1f048-193c-4276-b13b-5bf2417d3c87	off-plan	Rose Gardens 1	https://files.alnair.ae/uploads/2025/10/f3/f7/f3f76a448b28f455583d32040eb9d0e9.png,https://files.alnair.ae/uploads/2025/10/23/7b/237b6c4ed8183bc4fc52d2bd96e1ad7f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22578995	55.27496397	Off-plan property: Rose Gardens 1 by Roz Real Estate Development	b095241c-35b6-4088-bc89-60827819da86	277919.54	0	2	1	2	41.99	445.84	\N	\N	\N	\N	\N	2025-11-02 21:43:06.519063	2025-11-02 21:43:06.519063
048944a7-39ff-4941-8e93-407776dcf57f	off-plan	Binghatti Skyhall	https://files.alnair.ae/uploads/2025/3/6b/c3/6bc396e467d10f94a4733ee7c4248c39.jpg,https://files.alnair.ae/uploads/2025/3/44/e7/44e7fddb6d1724cb74ba53fbf28b6820.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18097864	55.27606241	Off-plan property: Binghatti Skyhall by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	312800.00	0	1	1	2	37.37	92.48	\N	\N	\N	\N	\N	2025-11-02 21:43:06.520626	2025-11-02 21:43:06.520626
b3466946-e73b-4ebd-9691-4c2726bcb601	off-plan	Binghatti Hillside	https://files.alnair.ae/uploads/2025/7/50/49/50497dc20e65e6e1e13b6ca95a517a03.jpg,https://files.alnair.ae/uploads/2025/7/ae/1a/ae1a5977cc4d9dcc5d479eeb984a4a7f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07105202	55.24641931	Off-plan property: Binghatti Hillside by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	210799.73	0	0	1	2	33.31	38.63	\N	\N	\N	\N	\N	2025-11-02 21:43:06.522325	2025-11-02 21:43:06.522325
55751976-5436-4c1b-86e2-cae717f9b446	off-plan	Wellington Ocean	https://files.alnair.ae/uploads/2025/3/32/50/3250cd01ccd13ee66dfb58320c0f528a.png,https://files.alnair.ae/uploads/2025/3/14/60/14607c87999ea9dd64291fd926da5ef9.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29035150	55.30323465	Off-plan property: Wellington Ocean by Wellington Developments	6b943c81-024d-4f98-b4ea-30a841a22f9c	969869.86	2	2	2	2	152.27	253.13	\N	\N	\N	\N	\N	2025-11-02 21:43:06.52414	2025-11-02 21:43:06.52414
fb833906-7255-4f0d-ac9b-ad6dd575875d	off-plan	Jumeirah Asora Bay	https://files.alnair.ae/uploads/2025/3/15/4c/154c1990243a097db958e825af2f632e.jpg,https://files.alnair.ae/uploads/2025/3/f9/43/f9431e0ce37d1d4b13141bd03e7181e2.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22841629	55.24927047	Off-plan property: Jumeirah Asora Bay by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	95200000.00	1	3	1	3	0.00	0.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.525751	2025-11-02 21:43:06.525751
221bb8da-a213-410a-b93c-858aecab3220	off-plan	Timez	https://files.alnair.ae/uploads/2025/2/6e/18/6e1878c8ecd79508925fc496ccb03b20.jpg,https://files.alnair.ae/uploads/2025/2/bd/65/bd65c6c38b7a819d3ab1ba89bf8df35b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12133541	55.37047148	Off-plan property: Timez by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	417248.00	2	3	2	3	77.32	294.42	\N	\N	\N	\N	\N	2025-11-02 21:43:06.526784	2025-11-02 21:43:06.526784
dfcca45a-d129-4112-ad11-0a459cc5957f	off-plan	Celia Gardens	https://files.alnair.ae/uploads/2025/3/30/b7/30b7854eef04f81e40c9c8e267202c15.jpg,https://files.alnair.ae/uploads/2025/3/61/c8/61c875cd72be327e7f791a2a48a9f3c5.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13824152	55.31765543	Off-plan property: Celia Gardens by Abou Eid Real Estate Development	342af2c3-688b-4e08-a4ad-30a2e1ab23f8	497175.20	1	2	1	2	73.30	137.96	\N	\N	\N	\N	\N	2025-11-02 21:43:06.5284	2025-11-02 21:43:06.5284
1e957770-7cba-4ead-a88c-ae3a35e9a8a8	off-plan	SkyHills Astra	https://files.alnair.ae/uploads/2025/2/ea/1c/ea1ce09274db8d64e9c50befec62ced8.jpg,https://files.alnair.ae/uploads/2025/2/c8/9f/c89f6d3d40a3b7deb7ba6bc59e8ce2d5.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07280418	55.24868980	Off-plan property: SkyHills Astra by HRE Development	081fa9d3-a0f7-4d05-ab75-aa99feb00da8	421328.00	1	3	1	3	92.72	185.16	\N	\N	\N	\N	\N	2025-11-02 21:43:06.529981	2025-11-02 21:43:06.529981
11b48ecf-2b5e-4bb2-a6aa-605444f3461e	off-plan	La Cle	https://files.alnair.ae/uploads/2025/5/bf/97/bf97f446506fc642e280da6dfca0f039.jpg,https://files.alnair.ae/uploads/2025/5/9e/11/9e11d1ea96962121601e11e81a9d844a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01813997	55.12699328	Off-plan property: La Cle by MAAIA Developers	012910c3-b7c5-4260-8f83-919436c52ab7	490416.00	2	2	2	2	111.39	119.10	\N	\N	\N	\N	\N	2025-11-02 21:43:06.531549	2025-11-02 21:43:06.531549
e7003c28-36ae-4881-ae5c-a05e6585152e	off-plan	Serenia District - West	https://files.alnair.ae/uploads/2025/2/7d/23/7d23a48298f389061f917b057fd619f5.jpg,https://files.alnair.ae/uploads/2025/2/d3/2b/d32b1d0eaf7d0afe3c2c55a038313546.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06746226	55.14630586	Off-plan property: Serenia District - West by Palma Development	83505ce5-4591-436e-9a41-2c69c0108b0f	504832.00	1	4	1	4	76.65	574.98	\N	\N	\N	\N	\N	2025-11-02 21:43:06.53335	2025-11-02 21:43:06.53335
82a0ddb9-ed8f-4fb2-a6b3-59cb7cba4a7f	off-plan	15 Cascade	https://files.alnair.ae/uploads/2025/2/3b/44/3b4487caf132fe32223ca4efef2d5ae0.jpg,https://files.alnair.ae/uploads/2025/2/ae/fc/aefc300143fe2953c5682f3850e1a0b6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04258697	55.22862956	Off-plan property: 15 Cascade by Iman Developers	6ad5348a-4fe7-4ee9-b98b-aa545a89e019	236952.80	0	2	1	2	39.30	117.91	\N	\N	\N	\N	\N	2025-11-02 21:43:06.534867	2025-11-02 21:43:06.534867
788098a1-1478-4655-a11d-8a5a6852b901	off-plan	The Element at Sobha One	https://files.alnair.ae/uploads/2025/2/e8/89/e889a77e43bd157edaef543d3796e53c.jpg,https://files.alnair.ae/uploads/2025/2/6e/e7/6ee727cc2b76a5638d871da4b5dd07ef.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18437011	55.34018401	Off-plan property: The Element at Sobha One by Sobha	5f637246-907f-4e44-9b90-7c3065602155	498310.80	1	4	1	4	68.08	376.03	\N	\N	\N	\N	\N	2025-11-02 21:43:06.536468	2025-11-02 21:43:06.536468
bd7a4f39-e393-4690-8aa8-e6862bafa30f	off-plan	AGUA Residences	https://files.alnair.ae/uploads/2025/3/4d/de/4ddebdfce9b35534dc468756006e6dfb.jpg,https://files.alnair.ae/uploads/2025/2/48/8c/488cd419a531122e49f39c9c6c2675f5.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29141873	55.30378293	Off-plan property: AGUA Residences by Citi Developers	62e4c532-429d-485b-bb6e-2342d13e665b	938368.45	2	4	2	4	133.11	177.28	\N	\N	\N	\N	\N	2025-11-02 21:43:06.538043	2025-11-02 21:43:06.538043
8042dd14-287c-4e09-962d-8df8b6f214a4	off-plan	Binghatti Amberhall	https://files.alnair.ae/uploads/2025/2/51/5a/515acae838b356d4567e746ca5e074f4.jpg,https://files.alnair.ae/uploads/2025/2/4c/ad/4cad7aa8df91f0bb036fe1af37b3f560.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05010284	55.20694128	Off-plan property: Binghatti Amberhall by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	202639.73	0	2	1	2	33.59	152.96	\N	\N	\N	\N	\N	2025-11-02 21:43:06.539646	2025-11-02 21:43:06.539646
85956e9b-6aaf-469b-9c9d-72439a808413	off-plan	Coastal Haven	https://files.alnair.ae/uploads/2025/2/b3/21/b32134f68fb4fecefe12f92622285b51.jpg,https://files.alnair.ae/uploads/2025/2/cb/f3/cbf348272d696594ae03f88a1f8bb1d8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29067048	55.30878536	Off-plan property: Coastal Haven by Prestige One	9ac691dd-fc8e-4f5a-8a06-e72173cbc5ab	707200.00	2	3	2	3	111.52	410.60	\N	\N	\N	\N	\N	2025-11-02 21:43:06.541518	2025-11-02 21:43:06.541518
e556130a-99d1-4241-8075-d320b9316698	off-plan	Celeste Heights	https://files.alnair.ae/uploads/2025/2/91/8e/918e7ec26ab5b2490e13f1ba06d4deff.jpg,https://files.alnair.ae/uploads/2025/2/c3/55/c35578ec74da4b10c1f9d76e44ce4977.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02073419	55.15392849	Off-plan property: Celeste Heights by Zimaya Properties	d40a0781-0f89-4ee7-8edb-0d371bceadae	458320.00	2	3	2	3	110.54	441.98	\N	\N	\N	\N	\N	2025-11-02 21:43:06.543485	2025-11-02 21:43:06.543485
281e80fa-b343-4029-8780-08ac9628da64	off-plan	Sunset Bay 2	https://files.alnair.ae/uploads/2025/2/03/2b/032b0dd7e083cfda4a8944240c24520b.jpg,https://files.alnair.ae/uploads/2025/2/71/65/7165e7b5b66520efa9623fdb7c068055.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.28662773	55.29733300	Off-plan property: Sunset Bay 2 by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	1308600.98	3	3	3	3	195.87	195.87	\N	\N	\N	\N	\N	2025-11-02 21:43:06.545056	2025-11-02 21:43:06.545056
9d015acb-f982-4c84-87ce-27b9e9d45404	off-plan	Riverside Views - Capri 2	https://files.alnair.ae/uploads/2025/1/ef/77/ef77e4cccf77c971820310179306373f.jpg,https://files.alnair.ae/uploads/2025/1/f7/d3/f7d39ce3fce6025db14b1de4798d38e5.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.97606005	55.22906542	Off-plan property: Riverside Views - Capri 2 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	400656.00	1	2	1	2	91.36	131.91	\N	\N	\N	\N	\N	2025-11-02 21:43:06.546513	2025-11-02 21:43:06.546513
c3bfbc9c-b5e0-4bbd-976e-93e571fdb810	off-plan	Riverside Views - Royal 1	https://files.alnair.ae/uploads/2025/1/a6/aa/a6aa202f913769f546d61816a03bbc92.jpg,https://files.alnair.ae/uploads/2025/1/61/b7/61b78fd6a37056a5e9082c1544d73029.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.97621566	55.22885084	Off-plan property: Riverside Views - Royal 1 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	241536.00	1	2	1	2	74.14	132.12	\N	\N	\N	\N	\N	2025-11-02 21:43:06.547975	2025-11-02 21:43:06.547975
61bb6769-2606-429c-9b90-be3edb94c180	off-plan	Golf Grove By Regent	https://files.alnair.ae/uploads/2025/4/33/44/3344c07ffe7d545b5d36b664a111ec7e.jpg,https://files.alnair.ae/uploads/2025/3/d8/c9/d8c9c16f01c75d3b79295fcd33f38bfc.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02586219	55.19337326	Off-plan property: Golf Grove By Regent by Regent Developments	1f23062c-cf5e-4891-ac2b-8045bb65b65e	263296.00	1	1	1	2	67.38	108.99	\N	\N	\N	\N	\N	2025-11-02 21:43:06.549738	2025-11-02 21:43:06.549738
178e5b66-b22f-4198-8d7c-6af7a6f4fbdb	off-plan	Azizi Emerald	https://files.alnair.ae/uploads/2025/1/28/00/28009736e2583d347e10bd07ef1a2af4.jpg,https://files.alnair.ae/uploads/2025/1/33/3d/333db7c6303070626d0a271740f287ac.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.23326287	55.32172359	Off-plan property: Azizi Emerald by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	1483760.00	1	3	1	3	115.71	289.39	\N	\N	\N	\N	\N	2025-11-02 21:43:06.551203	2025-11-02 21:43:06.551203
772d97f2-d2ca-4c3b-8eb5-7d7032437789	off-plan	Damac Lagoon Views 12	https://files.alnair.ae/uploads/2025/1/5f/3f/5f3f1045093320546fbae8aa82931022.png,https://files.alnair.ae/uploads/2025/1/3e/9e/3e9ef997def1d9749242f9025fc3811f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00658250	55.22982064	Off-plan property: Damac Lagoon Views 12 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	366928.00	1	1	1	2	63.92	63.92	\N	\N	\N	\N	\N	2025-11-02 21:43:06.552671	2025-11-02 21:43:06.552671
75348471-7d62-4977-acde-1286a192647d	off-plan	City Walk Crestlane 2&3	https://files.alnair.ae/uploads/2025/1/79/50/7950f4dd0df90914374e194d473e1b00.jpg,https://files.alnair.ae/uploads/2025/1/1f/cb/1fcbfdcfea2cddf7c277736a057e71df.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20782782	55.25784147	Off-plan property: City Walk Crestlane 2&3 by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	4471952.00	4	4	4	4	426.33	426.33	\N	\N	\N	\N	\N	2025-11-02 21:43:06.554149	2025-11-02 21:43:06.554149
9d52eda3-4003-4111-93b8-c3ad4b448493	off-plan	Views VII	https://files.alnair.ae/uploads/2025/1/3a/7b/3a7b84d6d1db81b47a4ef14d18e23c6f.jpg,https://files.alnair.ae/uploads/2025/5/b0/72/b072d6746431ec237b6c8abc1344b084.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.93756339	55.21730392	Off-plan property: Views VII by Golden Woods	deaaebdd-4cef-4c79-bb86-7df0a24cd413	276020.16	1	3	1	3	72.52	164.26	\N	\N	\N	\N	\N	2025-11-02 21:43:06.555676	2025-11-02 21:43:06.555676
45f5d4f5-4acf-4c00-babb-b73afed2f777	off-plan	Woodland Terraces	https://files.alnair.ae/uploads/2025/1/20/e7/20e74d4aaeca90094b9cb62291e6af35.jpg,https://files.alnair.ae/uploads/2025/1/85/dd/85dd25d3732bbf960ccdbe171e12e7c5.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12984900	55.35500519	Off-plan property: Woodland Terraces by AMIS Properties	930bd2d2-cfc4-4ae6-8d21-0a27559e4030	390390.18	1	3	1	3	72.46	151.62	\N	\N	\N	\N	\N	2025-11-02 21:43:06.557129	2025-11-02 21:43:06.557129
f7b85c44-2ccb-492c-806e-82efc70734be	off-plan	Damac Lagoons - Santorini	https://files.alnair.ae/uploads/2025/1/a7/c5/a7c592e28b9edae0e1837b264e1ce4ea.jpg,https://files.alnair.ae/uploads/2025/1/f8/a5/f8a5a430ee28bf79cc08a0a062a5fc55.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01274456	55.23584604	Off-plan property: Damac Lagoons - Santorini by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	870400.00	1	3	1	3	2.07	4.14	\N	\N	\N	\N	\N	2025-11-02 21:43:06.558853	2025-11-02 21:43:06.558853
8cf3866d-9f3c-48c8-9800-5316bdaaa0eb	off-plan	Greygate Residences	https://files.alnair.ae/uploads/2025/1/1f/ce/1fce8e26af30ca02a6bca1cbb2155f8e.jpg,https://files.alnair.ae/uploads/2025/1/97/f2/97f274b80143b3a3e1539b276ed1572e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05882463	55.21242201	Off-plan property: Greygate Residences by ADE Properties	47bc978d-34b3-4000-bc2b-4e1216920aeb	304728.40	1	1	1	2	74.02	117.29	\N	\N	\N	\N	\N	2025-11-02 21:43:06.560453	2025-11-02 21:43:06.560453
1db5df0d-e844-4698-b035-fca83022406e	off-plan	Rijas Suites	https://files.alnair.ae/uploads/2025/1/dc/03/dc0363310a6f31a15d71f9badfa66a5f.jpg,https://files.alnair.ae/uploads/2025/1/35/e6/35e6781a4945fd336179609113cb700b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09602350	55.31602650	Off-plan property: Rijas Suites by Rijas Developers	c3dde52b-a111-456b-b000-a0ad359199a1	139231.36	0	2	1	2	24.90	199.74	\N	\N	\N	\N	\N	2025-11-02 21:43:06.563299	2025-11-02 21:43:06.563299
3c0f7602-52b5-49fb-a3d5-5c409676f2e3	off-plan	Wasel	https://files.alnair.ae/uploads/2025/1/c9/62/c962f830b186d4b7f64de1eea03ff782.jpg,https://files.alnair.ae/uploads/2025/1/98/cc/98cc9afdbef52df5d50734566456a956.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29524296	55.31928299	Off-plan property: Wasel by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	455600.00	1	4	1	4	55.65	543.20	\N	\N	\N	\N	\N	2025-11-02 21:43:06.564878	2025-11-02 21:43:06.564878
e1bd44b6-88d5-4878-bc38-ee74df1bbae8	off-plan	Belgravia Gardens	https://files.alnair.ae/uploads/2025/1/7b/46/7b4643e667d011e9d24bd4f3e9430325.jpg,https://files.alnair.ae/uploads/2025/1/77/76/77765a8825f1fc9fb9b3f52fa56e28ad.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09571128	55.33822462	Off-plan property: Belgravia Gardens by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	550209.22	2	3	2	3	115.72	227.32	\N	\N	\N	\N	\N	2025-11-02 21:43:06.566508	2025-11-02 21:43:06.566508
4287006c-bf4c-4948-9e4e-7b237fc3cdae	off-plan	Majestique Residence	https://files.alnair.ae/uploads/2025/1/49/cf/49cf554d61cae4604dbad88dfc34769e.jpg,https://files.alnair.ae/uploads/2025/1/03/95/0395400c29a8469f532eed22d61baa28.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94509489	55.21014445	Off-plan property: Majestique Residence by Credo Investments	fe699655-b30d-4690-b8f7-bb62ac05dadf	295405.60	2	2	2	2	82.03	101.77	\N	\N	\N	\N	\N	2025-11-02 21:43:06.568358	2025-11-02 21:43:06.568358
1e377013-8d0e-4e7a-95a9-7833e8fbb89b	off-plan	Beachfront Gates	https://files.alnair.ae/uploads/2025/1/92/6e/926ea6a08505a10290b5688c02d70edc.jpg,https://files.alnair.ae/uploads/2025/1/aa/3c/aa3c011a8c1c37e6c52fe7cd722a82d8.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.93702942	55.22392071	Off-plan property: Beachfront Gates by Dubai South	e0931680-f521-469b-8c27-42de9933fb4c	386919.73	1	3	1	3	98.29	181.24	\N	\N	\N	\N	\N	2025-11-02 21:43:06.569842	2025-11-02 21:43:06.569842
adb9c8de-fb2e-41b8-b7e6-77275589659f	off-plan	The Eighty Three	https://files.alnair.ae/uploads/2025/1/b9/3a/b93ae59227a17849cb2ffda18b6922ff.jpg,https://files.alnair.ae/uploads/2025/1/47/67/4767f8181c99e08566f149bd1b490bac.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.93842984	55.22130176	Off-plan property: The Eighty Three by Oksa Developer	43273c82-1e85-43bb-9d05-e9b2ae9c2e0f	156400.00	0	2	1	2	34.41	192.44	\N	\N	\N	\N	\N	2025-11-02 21:43:06.571661	2025-11-02 21:43:06.571661
48808236-b355-46f2-bbd7-a69176138323	off-plan	Reportage Hills	https://files.alnair.ae/uploads/2025/1/99/e4/99e4b0de2a7b3dfd7ea649ab185a867b.jpg,https://files.alnair.ae/uploads/2025/1/3f/65/3f6522abdf9b1b0c9e8c5b79d606d19f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01811138	55.23479998	Off-plan property: Reportage Hills by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	705840.00	1	3	1	3	1710.02	3420.05	\N	\N	\N	\N	\N	2025-11-02 21:43:06.574449	2025-11-02 21:43:06.574449
c7578cda-93b1-4f3d-9f11-51f64c948f05	off-plan	Flora Isle Beachfront Residences	https://files.alnair.ae/uploads/2025/1/98/d6/98d6a7b12783e9777ab531e79fa3c8af.jpg,https://files.alnair.ae/uploads/2025/1/07/2c/072c52e73f293c7b663996bb1ba0110d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.30106506	55.29693872	Off-plan property: Flora Isle Beachfront Residences by Centurion Development	dee72273-e224-48e8-b4f8-9acc72306a94	941120.00	1	3	1	3	108.07	315.94	\N	\N	\N	\N	\N	2025-11-02 21:43:06.575306	2025-11-02 21:43:06.575306
62138abf-5997-4a8b-8743-cd84369fbabe	off-plan	The Baltimore	https://files.alnair.ae/uploads/2025/1/0b/fb/0bfbfb5454e3f8a1ae6ea1faa1b47863.jpg,https://files.alnair.ae/uploads/2025/1/88/97/889711e2e6d16a2cea1b65b0c8a8158f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00802612	55.28870836	Off-plan property: The Baltimore by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	654401.54	3	3	3	3	132.67	132.67	\N	\N	\N	\N	\N	2025-11-02 21:43:06.576969	2025-11-02 21:43:06.576969
35611488-4728-4f79-9ff4-ac1fc046b7f3	off-plan	The Chedi Private Residences	https://files.alnair.ae/uploads/2025/2/c5/71/c571276d56ad2c2ff7d033f8fb9b927a.jpg,https://files.alnair.ae/uploads/2025/2/8f/99/8f99abda16b4fa9ed7bd81fd66de0206.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09925030	55.17134562	Off-plan property: The Chedi Private Residences by Al Seeb Real Estate Development	526a05d5-8cbd-4749-9067-ea34da40c35e	2784732.19	2	5	2	5	330.36	3088.66	\N	\N	\N	\N	\N	2025-11-02 21:43:06.578767	2025-11-02 21:43:06.578767
ced2589d-1cd7-4db2-a624-26cc954e65b2	off-plan	Esme Beach Residences	https://files.alnair.ae/uploads/2025/6/26/a4/26a4a1abc25a82637791061e0ead7393.png,https://files.alnair.ae/uploads/2025/6/c8/3c/c83ca449735aa06c4afd3d897de4108d.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29908294	55.29599592	Off-plan property: Esme Beach Residences by Elysian Development	ba852eb1-4aa8-42a9-af72-47201dd387bc	843200.00	1	2	1	2	69.87	173.42	\N	\N	\N	\N	\N	2025-11-02 21:43:06.580432	2025-11-02 21:43:06.580432
ead33866-f603-4660-9040-e55585db947d	off-plan	Allegro Residences	https://files.alnair.ae/uploads/2025/1/41/b5/41b57d0f9fbe5b8d01629405e7ed4184.jpg,https://files.alnair.ae/uploads/2025/1/b8/e5/b8e54efca1886e3c5ab641c6495d26e5.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.28996117	55.29433955	Off-plan property: Allegro Residences by Mill Hill	6617d5c6-80a6-4d8c-b92a-8fc64a09c3c8	817310.50	2	3	2	3	122.45	199.56	\N	\N	\N	\N	\N	2025-11-02 21:43:06.582458	2025-11-02 21:43:06.582458
236ff69c-1a6b-4a26-95c5-a70ba2f36152	off-plan	Golf Links 18	https://files.alnair.ae/uploads/2025/1/03/8f/038f213a1e95645ea0bf2946112526f1.jpg,https://files.alnair.ae/uploads/2025/1/7e/76/7e76a24fc633a5729a02574457a71d41.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03582944	55.22124007	Off-plan property: Golf Links 18 by Condor	552c1026-d364-4ea2-95ff-65710cce5b5d	179519.73	0	2	1	2	35.58	134.43	\N	\N	\N	\N	\N	2025-11-02 21:43:06.584578	2025-11-02 21:43:06.584578
52f75735-6023-4d30-ade4-81e9034f8e02	off-plan	Verano	https://files.alnair.ae/uploads/2025/1/5d/f0/5df0961700f7e77485c4d89380198f77.jpg,https://files.alnair.ae/uploads/2025/1/13/3d/133d22f2b74e894576b8a28352f1f69c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04055971	55.24765394	Off-plan property: Verano by Prescott Development	b1781062-53b7-4448-a786-f2bab2542727	197200.00	0	1	1	2	39.68	63.80	\N	\N	\N	\N	\N	2025-11-02 21:43:06.586348	2025-11-02 21:43:06.586348
a4968c56-163f-44c8-8c1b-80998093c7a5	off-plan	Viera Residences	https://files.alnair.ae/uploads/2025/1/95/42/954242c945f2a41980373fc0780fed73.jpg,https://files.alnair.ae/uploads/2025/1/ec/ed/eced02b0d97a60408de5905ce12c2e37.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03120611	55.19388691	Off-plan property: Viera Residences by Vantage Ventures	4aa6000a-30a9-4069-a021-62b731ed9c4f	452059.92	2	2	2	2	106.65	126.07	\N	\N	\N	\N	\N	2025-11-02 21:43:06.588084	2025-11-02 21:43:06.588084
933a7063-07a4-419a-b58e-22869832424b	off-plan	Park Lane 2 By Heilbronn	https://files.alnair.ae/uploads/2025/6/00/69/006981d14a3010e0be6865ed1fd818b8.jpg,https://files.alnair.ae/uploads/2025/6/92/96/92966bd5ddf4f460ed34e9aa022259a8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06263645	55.21593265	Off-plan property: Park Lane 2 By Heilbronn by Heilbronn Properties Ltd.	0ab53acf-bb57-47bc-8291-3dee23232e18	370161.54	1	2	1	2	67.40	196.09	\N	\N	\N	\N	\N	2025-11-02 21:43:06.589765	2025-11-02 21:43:06.589765
eeba8151-f3a6-453e-b012-9c01b2790d28	off-plan	Estrella By Nexus	https://files.alnair.ae/uploads/2025/3/21/33/2133b3157dd18129881cebf36b7cc01e.png,https://files.alnair.ae/uploads/2025/3/12/62/126284f98870f372145044a1564a6eb1.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09465300	55.31698520	Off-plan property: Estrella By Nexus by Nexus	15c1585b-4896-460c-9554-4298141fb1f3	308756.45	1	2	1	2	72.00	194.54	\N	\N	\N	\N	\N	2025-11-02 21:43:06.591508	2025-11-02 21:43:06.591508
73f17b2a-c542-4e9b-862a-be0cf859a869	off-plan	The Autograph i Series	https://files.alnair.ae/uploads/2025/1/3a/3d/3a3d4ac7e9d66271b2f39378f2d454ff.jpg,https://files.alnair.ae/uploads/2025/2/4a/84/4a84127dadfc43561be25ed47d1bd734.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05031465	55.21459285	Off-plan property: The Autograph i Series by Green Group	4141aec9-21ce-4490-8df8-f81950a8242f	544231.20	2	2	2	2	91.97	92.25	\N	\N	\N	\N	\N	2025-11-02 21:43:06.593642	2025-11-02 21:43:06.593642
c724f2fa-1743-4c71-aaab-af741282a045	off-plan	Marriott Residences JLT	https://files.alnair.ae/uploads/2024/12/18/6c/186c6bf0ece8ec2fd783b64a1a08e16e.png,https://files.alnair.ae/uploads/2024/12/f6/89/f689beeb5ebeea0bd910924e54039fed.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06632349	55.14310928	Off-plan property: Marriott Residences JLT by SABA Properties	4a3d26da-ed01-40c1-aba3-778761748561	620704.00	1	3	1	3	82.45	204.31	\N	\N	\N	\N	\N	2025-11-02 21:43:06.595468	2025-11-02 21:43:06.595468
d0785132-0520-427f-b051-579415dc5d59	off-plan	Al Haseen Residences 4	https://files.alnair.ae/uploads/2024/12/1a/24/1a24a61c3f9cf8bb3eb9ccfa759106ac.jpg,https://files.alnair.ae/uploads/2024/12/66/73/66731f9c5adef903cb95121cc04ea6fa.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.87113897	55.03644279	Off-plan property: Al Haseen Residences 4 by Dugasta Properties Development	d4b3354c-36e1-4395-ad29-70911062e48d	167517.18	0	2	1	2	35.76	107.10	\N	\N	\N	\N	\N	2025-11-02 21:43:06.597065	2025-11-02 21:43:06.597065
43314b73-fe50-4bbb-8278-478e0a2740c4	off-plan	Marriott Residences Sheikh Zayed Road	https://files.alnair.ae/uploads/2024/12/46/43/4643ee115dd162ab461c6b475e7a4bd7.jpg,https://files.alnair.ae/uploads/2024/12/64/fc/64fc527d1998de707a7444c4309cf4b4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11116063	55.18929094	Off-plan property: Marriott Residences Sheikh Zayed Road by Al Ali Property Investment	736859dd-b040-4f6e-82c5-8a1c4b0b8f23	796144.00	2	3	2	3	135.27	188.22	\N	\N	\N	\N	\N	2025-11-02 21:43:06.59993	2025-11-02 21:43:06.59993
d545d047-3042-4cca-9db7-c8d1fb537fdc	off-plan	Golf Dale	https://files.alnair.ae/uploads/2024/12/65/93/6593c470f5a4893bbfe49aa2366d5a1e.jpg,https://files.alnair.ae/uploads/2024/12/6c/c1/6cc13f6e55725db499d6dfbc4a68f2f9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.86463355	55.13923422	Off-plan property: Golf Dale by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	713153.54	2	3	2	3	129.97	237.74	\N	\N	\N	\N	\N	2025-11-02 21:43:06.601429	2025-11-02 21:43:06.601429
5539c2b5-3657-47e8-9221-b8b269d60eed	off-plan	The One	https://files.alnair.ae/uploads/2024/12/2a/5b/2a5bc19cb578e9a24b177f08f84fe173.jpg,https://files.alnair.ae/uploads/2024/12/cb/7c/cb7c0658c7eaa0f494b5c04191cb07ce.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09883850	55.17608350	Off-plan property: The One by Prestige One	9ac691dd-fc8e-4f5a-8a06-e72173cbc5ab	2244544.00	1	3	1	3	265.82	270.95	\N	\N	\N	\N	\N	2025-11-02 21:43:06.602916	2025-11-02 21:43:06.602916
f83f76a4-636d-47bc-b97a-6da1ca8c8e76	off-plan	Mews Mansions	https://files.alnair.ae/uploads/2025/8/7a/88/7a885f70d269e82d8811aabaeebd11ed.jpg,https://files.alnair.ae/uploads/2025/8/a6/19/a61963674d309dc82cd7bbb3944305f2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.16207147	55.31867802	Off-plan property: Mews Mansions by Al Ali Property Investment	736859dd-b040-4f6e-82c5-8a1c4b0b8f23	20400000.00	1	3	1	3	252.08	504.16	\N	\N	\N	\N	\N	2025-11-02 21:43:06.60452	2025-11-02 21:43:06.60452
56fc6f31-a296-4d4d-9b37-5083a8c81cbb	off-plan	Golf Acres	https://files.alnair.ae/uploads/2024/12/41/7d/417d37ad02a1d042a7fc0954c0dea3dd.jpg,https://files.alnair.ae/uploads/2024/12/b4/6a/b46ad86ed224ad0d82e473d5a42134c0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.86521020	55.13834236	Off-plan property: Golf Acres by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1248177.54	3	3	3	3	238.20	238.20	\N	\N	\N	\N	\N	2025-11-02 21:43:06.605354	2025-11-02 21:43:06.605354
c625309e-e336-4ba9-9c48-04c172a30b0b	off-plan	Verdan1a 1	https://files.alnair.ae/uploads/2024/12/fd/53/fd532d807bfdea4b60cac9eb08b1fcf1.jpg,https://files.alnair.ae/uploads/2024/12/3b/a4/3ba4fbb8c765b6317ee959608360ef44.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09544531	55.38067393	Off-plan property: Verdan1a 1 by Object One	9d128f32-1c6c-474d-b911-61803444decc	314826.94	1	2	1	2	73.10	127.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.606905	2025-11-02 21:43:06.606905
ebd2b1d7-fa2a-4e20-9a0c-fe07227dbe09	off-plan	Stamn Yuni	https://files.alnair.ae/uploads/2024/12/37/8e/378e03490140017c2994a1fa57d1da48.jpg,https://files.alnair.ae/uploads/2025/4/65/bc/65bc52639a74034b714c9bf588877cc0.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22740082	55.27911678	Off-plan property: Stamn Yuni by Stamn Development	0edd8c13-a7a3-4042-98f2-7b74e0791c14	378929.18	1	1	1	2	57.15	89.49	\N	\N	\N	\N	\N	2025-11-02 21:43:06.608558	2025-11-02 21:43:06.608558
82a2b9d4-8a54-4216-8f88-5c5e1d80a6bd	off-plan	The Boulevard	https://files.alnair.ae/uploads/2024/12/bf/48/bf48b31d3a042927473e2910a636f669.jpg,https://files.alnair.ae/uploads/2024/12/fe/d2/fed2c51981d034c1e70eb61a9dcc1b6e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09257550	55.38233750	Off-plan property: The Boulevard by Prestige One	9ac691dd-fc8e-4f5a-8a06-e72173cbc5ab	195840.00	0	2	1	2	40.69	383.20	\N	\N	\N	\N	\N	2025-11-02 21:43:06.61013	2025-11-02 21:43:06.61013
e749eab4-4eb8-4dd6-bfc6-a0dd7b4abd31	off-plan	Binghatti Haven	https://files.alnair.ae/uploads/2024/12/5a/9a/5a9a34f737949661f0a23c00db617327.png,https://files.alnair.ae/uploads/2024/12/43/8d/438ddee7a98708f731c9426a66cab9b5.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04373948	55.21859944	Off-plan property: Binghatti Haven by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	206719.73	0	3	1	3	35.66	148.75	\N	\N	\N	\N	\N	2025-11-02 21:43:06.611671	2025-11-02 21:43:06.611671
0c09c0ae-58c6-47f0-8846-6eaec0c13de6	off-plan	Villa del Divos	https://files.alnair.ae/uploads/2024/12/42/f7/42f75f2f1d02e2a4850f26622849931d.jpg,https://files.alnair.ae/uploads/2024/12/3e/d6/3ed699cecf51421bdffd190749ff0e36.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.30115081	55.29980332	Off-plan property: Villa del Divos by Mr. Eight	378511a2-e46d-48ad-88a8-72584c46191c	1305600.00	2	5	2	5	139.27	671.53	\N	\N	\N	\N	\N	2025-11-02 21:43:06.613189	2025-11-02 21:43:06.613189
8c24b230-9157-4ab5-9fb7-988723e345f4	off-plan	Binghatti Ruby	https://files.alnair.ae/uploads/2024/12/9c/e2/9ce2044252116075ddad6d80ea4b00a2.jpg,https://files.alnair.ae/uploads/2024/12/56/0b/560b30a5775621d827f5507d9abea6c0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06841163	55.21351397	Off-plan property: Binghatti Ruby by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	200854.86	0	3	1	3	33.59	182.06	\N	\N	\N	\N	\N	2025-11-02 21:43:06.614688	2025-11-02 21:43:06.614688
ef4d94c8-9b22-4881-aea8-2027bb5e73c7	off-plan	Vega	https://files.alnair.ae/uploads/2024/12/77/9b/779b40ecbc22c911052d4120c4e7134f.jpg,https://files.alnair.ae/uploads/2024/12/f4/a4/f4a498f30f76b4e4e80b95aad1e54639.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03797185	55.20550355	Off-plan property: Vega by Acube Developers	f937a811-2827-40a6-a476-25e4dc248127	204000.00	0	2	1	2	38.73	100.06	\N	\N	\N	\N	\N	2025-11-02 21:43:06.618715	2025-11-02 21:43:06.618715
ece8f73d-a0f6-4a09-8da8-b2f9f60e9034	off-plan	Reef 999	https://files.alnair.ae/uploads/2024/12/06/4e/064ee53a562e360da79e68487a89d618.png,https://files.alnair.ae/uploads/2024/12/61/12/6112be6efea7aedaf78ced4535a88609.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01809076	55.13354525	Off-plan property: Reef 999 by Reef Luxury Developments	e8a79f19-2efe-4d72-9a9e-0e4ebc39a9ca	356711.41	1	4	1	4	78.51	343.23	\N	\N	\N	\N	\N	2025-11-02 21:43:06.620342	2025-11-02 21:43:06.620342
f07cd7a4-cb78-402c-a577-2d5dd8c1bff0	off-plan	Weybridge Gardens 4	https://files.alnair.ae/uploads/2024/12/c3/53/c353087a5188c618974bf1e39aee34a8.jpg,https://files.alnair.ae/uploads/2025/1/a8/64/a864f4635c0e430e5ca18ccca24222e8.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09393562	55.37405626	Off-plan property: Weybridge Gardens 4 by Leos Development	8f713edb-84d7-465d-8744-965901f5d7e7	330026.03	1	2	1	2	98.64	112.46	\N	\N	\N	\N	\N	2025-11-02 21:43:06.62188	2025-11-02 21:43:06.62188
8b0ce778-fc7a-418a-8ef0-71b8ea99faf3	off-plan	Capital One	https://files.alnair.ae/uploads/2025/5/db/b0/dbb0172ec3349b7441126aff20435e33.png,https://files.alnair.ae/uploads/2025/5/5d/7b/5d7bfa8fa9bd3005eba66b50e739f192.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04688816	55.22752047	Off-plan property: Capital One by Centurion Development	dee72273-e224-48e8-b4f8-9acc72306a94	1109729.54	1	3	1	3	184.79	184.79	\N	\N	\N	\N	\N	2025-11-02 21:43:06.623427	2025-11-02 21:43:06.623427
03c23f4d-ea0b-490f-b35e-eee69bf5eb7d	off-plan	Rove Home Dubai Marina	https://files.alnair.ae/uploads/2024/12/4c/93/4c93cd3e81ba853caebcb39911e4c433.jpg,https://files.alnair.ae/uploads/2024/12/fd/e1/fde16c769cb7ce680a276bc466deeb6a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07478540	55.13941728	Off-plan property: Rove Home Dubai Marina by Irth Development	f62d2c43-fdd2-42ca-a285-58271ad51d03	1126352.00	1	1	1	2	101.73	101.73	\N	\N	\N	\N	\N	2025-11-02 21:43:06.626795	2025-11-02 21:43:06.626795
b2fabe77-ffff-415d-8e8d-c52659fb7434	off-plan	Bond Enclave	https://files.alnair.ae/uploads/2024/12/e0/4f/e04fd7c7aa4ca930de8d0ac2a13b6132.jpg,https://files.alnair.ae/uploads/2024/12/1c/17/1c17ffd267e0aebab20a7c97e9200824.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06428679	55.24180725	Off-plan property: Bond Enclave by Pearlshire	e705edd8-148f-473b-8694-c22aaede2859	312739.34	1	3	1	3	65.03	244.34	\N	\N	\N	\N	\N	2025-11-02 21:43:06.630169	2025-11-02 21:43:06.630169
52ef8346-a627-4662-9ccd-1d664cd97c53	off-plan	Guzel Towers	https://files.alnair.ae/uploads/2024/12/df/8e/df8e77fc8a524ef085f85b5235f70e8f.jpg,https://files.alnair.ae/uploads/2024/12/3d/a4/3da4bf69e924fa8ba7606959e8b24e1c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03262824	55.17276786	Off-plan property: Guzel Towers by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	216008.26	0	2	1	2	32.55	99.88	\N	\N	\N	\N	\N	2025-11-02 21:43:06.631756	2025-11-02 21:43:06.631756
f01e84ff-9548-40d4-a0d8-492d6c2a60e0	off-plan	Whitecliffs Residences	https://files.alnair.ae/uploads/2025/5/5a/bb/5abb81d38103678f02d28f52014fee9d.jpg,https://files.alnair.ae/uploads/2025/5/32/03/32036fb6d55fdbe9fc9ad840bb4a9121.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29064501	55.30875787	Off-plan property: Whitecliffs Residences by Ag Properties	0f7c019a-0553-415e-9c8f-d37bdb0fb1d6	589751.49	1	3	1	3	106.02	142.25	\N	\N	\N	\N	\N	2025-11-02 21:43:06.633627	2025-11-02 21:43:06.633627
500111d6-103d-435e-b572-129dbbbb3844	off-plan	Azizi Ruby	https://files.alnair.ae/uploads/2024/12/3f/49/3f49fa5144b01a602f3ed972fcb976cb.jpg,https://files.alnair.ae/uploads/2024/12/7b/f8/7bf82fd58fcfef2b3a69eda53d6692ce.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05941970	55.20373414	Off-plan property: Azizi Ruby by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	303008.00	1	3	1	3	64.29	331.66	\N	\N	\N	\N	\N	2025-11-02 21:43:06.635151	2025-11-02 21:43:06.635151
4ad968c2-c43b-4b23-b293-41a3f8c6917d	off-plan	LIV Maritime	https://files.alnair.ae/uploads/2024/11/40/2e/402e9943111237a32a95dfddd3bbb99f.jpg,https://files.alnair.ae/uploads/2024/11/e9/c1/e9c1d4c775887fe751a9acb0e1173855.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.27102901	55.26914701	Off-plan property: LIV Maritime by LIV	8c05fb6a-02a5-434a-a584-09ab3ac7d67c	1400677.06	2	3	2	3	174.56	256.50	\N	\N	\N	\N	\N	2025-11-02 21:43:06.637841	2025-11-02 21:43:06.637841
3c355308-0752-42f0-821a-76fa8783a84f	off-plan	MBL Signature	https://files.alnair.ae/uploads/2024/11/07/e2/07e2283f1c9ccb1c3975da374aeec7d9.jpg,https://files.alnair.ae/uploads/2024/11/eb/dc/ebdcb40c04c84a487af3d4c73358a831.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07780392	55.14745116	Off-plan property: MBL Signature by MAG Property Development	d5dfad6f-2582-4be3-89ae-c5625e33a996	413246.06	0	2	1	2	51.57	157.45	\N	\N	\N	\N	\N	2025-11-02 21:43:06.639364	2025-11-02 21:43:06.639364
99208f66-bded-4d27-9b3d-e3a2eb53b13f	off-plan	Skyvue Solair	https://files.alnair.ae/uploads/2024/11/70/6a/706a1239fe285a1c9b6192d5652b6c81.jpg,https://files.alnair.ae/uploads/2024/11/9d/03/9d03d2eb89249b3714590461b46d6952.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17474800	55.32533550	Off-plan property: Skyvue Solair by Sobha	5f637246-907f-4e44-9b90-7c3065602155	654973.55	1	3	1	3	87.73	212.65	\N	\N	\N	\N	\N	2025-11-02 21:43:06.640862	2025-11-02 21:43:06.640862
54584c47-35ea-439e-bf51-580f9759476f	off-plan	ESSENL1FE	https://files.alnair.ae/uploads/2024/11/65/c3/65c394bacdda26260afd31713c1a9bfb.jpg,https://files.alnair.ae/uploads/2024/11/34/03/340377ccee54676a8731959f464f829a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03966632	55.18311515	Off-plan property: ESSENL1FE by Object One	9d128f32-1c6c-474d-b911-61803444decc	236473.81	0	1	1	2	44.77	143.10	\N	\N	\N	\N	\N	2025-11-02 21:43:06.6426	2025-11-02 21:43:06.6426
7f5f7470-be7f-4bf6-ab7c-13e3e17c3669	off-plan	Arian	https://files.alnair.ae/uploads/2024/11/55/01/5501b94ee960ce3b0382695d1f5d6dd2.jpg,https://files.alnair.ae/uploads/2024/11/28/c6/28c6f8aa41952f1ab1cecac0c30a4f3b.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.97843725	55.09203672	Off-plan property: Arian by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	386240.00	1	3	1	3	74.51	173.82	\N	\N	\N	\N	\N	2025-11-02 21:43:06.644258	2025-11-02 21:43:06.644258
dc6c5f78-bd0d-49f3-a863-bc35a1b14a84	off-plan	Treppan Tower	https://files.alnair.ae/uploads/2024/12/f8/ef/f8ef871e5ca1f459ff266625315bee36.jpg,https://files.alnair.ae/uploads/2024/11/c6/17/c617ce7b8405820813dfd8dd518e7dff.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03329654	55.17386173	Off-plan property: Treppan Tower by Fakhruddin Properties	7aa8d80f-f1da-438b-a8ac-a57d0b201cd8	308448.00	1	3	1	3	44.52	270.90	\N	\N	\N	\N	\N	2025-11-02 21:43:06.645887	2025-11-02 21:43:06.645887
cf353625-904b-4e2d-aa44-39a6450c8e04	off-plan	Hotel London	https://files.alnair.ae/uploads/2024/11/1c/2b/1c2bc6fccb127e87f71c9da13899ed48.png,https://files.alnair.ae/uploads/2024/11/80/01/80015e3d4d05b17d00c578e223b5eb34.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.23059705	55.16138560	Off-plan property: Hotel London by The Heart of Europe	de44570c-141e-4809-a5a9-9dbc9556999c	797832.03	1	3	1	3	52.25	128.35	\N	\N	\N	\N	\N	2025-11-02 21:43:06.647568	2025-11-02 21:43:06.647568
da04575c-e8e5-46ba-8d6e-b8fc3d1b921a	off-plan	The Hillgate	https://files.alnair.ae/uploads/2024/11/9e/04/9e04b687231298ffa031d78ed226af00.jpg,https://files.alnair.ae/uploads/2024/11/79/11/79111b02858ed5a1198f0a65655fab64.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11107138	55.38351238	Off-plan property: The Hillgate by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	527633.22	2	3	2	3	111.16	284.87	\N	\N	\N	\N	\N	2025-11-02 21:43:06.649026	2025-11-02 21:43:06.649026
1dd49a52-d3d3-4777-a5f6-bcc8b0230314	off-plan	Amazonia	https://files.alnair.ae/uploads/2025/2/7a/ff/7afff63aca4d565972f8cc9b9411c8b6.jpg,https://files.alnair.ae/uploads/2024/11/2d/7d/2d7d0d70a35d0856a5730260eb292d22.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22516473	55.33825367	Off-plan property: Amazonia by Palladium Development	bb633fa5-9394-484e-a17b-feaaf78ce422	280160.00	0	2	1	2	39.02	124.76	\N	\N	\N	\N	\N	2025-11-02 21:43:06.650469	2025-11-02 21:43:06.650469
5b4a3b76-c235-4c74-a4a5-5855c8896f45	off-plan	Binghatti Starlight	https://files.alnair.ae/uploads/2025/3/41/2a/412afcf214a39509c4485e3ae200e0ba.jpg,https://files.alnair.ae/uploads/2025/3/22/c4/22c4cdea39106d9af56128ccadcc4642.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21252660	55.31954773	Off-plan property: Binghatti Starlight by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	233104.00	0	2	1	2	38.57	141.17	\N	\N	\N	\N	\N	2025-11-02 21:43:06.651961	2025-11-02 21:43:06.651961
01b3de9b-f81c-4321-a147-345e71240cb4	off-plan	Forest City Tower	https://files.alnair.ae/uploads/2025/3/cd/fd/cdfd555bc87c230b22fd107fa5cb3cdd.jpg,https://files.alnair.ae/uploads/2025/3/17/26/172665da41fae55f00e394b551b2d168.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09336317	55.32198596	Off-plan property: Forest City Tower by HZ Development	01a96495-fe84-4b5f-8d33-66eb5b31dcad	1396417.54	4	4	4	4	335.51	401.02	\N	\N	\N	\N	\N	2025-11-02 21:43:06.654541	2025-11-02 21:43:06.654541
789a25e7-262f-4805-8c8b-c9beb670396a	off-plan	Empire Lakeviews	https://files.alnair.ae/uploads/2024/11/3f/6e/3f6e3ba0a80d2369fe9b081b2aa5b66e.jpg,https://files.alnair.ae/uploads/2024/11/e5/31/e53126fcc3d2357f37a96ae03388033f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11452430	55.36432316	Off-plan property: Empire Lakeviews by Empire Developments	a45adfa1-9f07-48ed-a4d3-ba8f0d2021cd	225699.34	0	3	1	3	38.46	244.68	\N	\N	\N	\N	\N	2025-11-02 21:43:06.65607	2025-11-02 21:43:06.65607
92710963-55e9-43f9-86a2-77d9a7e3f150	off-plan	Sunset Bay	https://files.alnair.ae/uploads/2024/11/d4/5b/d45b9f0bd67838122143771588c75763.jpg,https://files.alnair.ae/uploads/2024/11/86/be/86bed60b3aec3178654adceb9f5b91cd.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.28873764	55.29852390	Off-plan property: Sunset Bay by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	1289114.62	3	3	3	3	187.85	187.85	\N	\N	\N	\N	\N	2025-11-02 21:43:06.658593	2025-11-02 21:43:06.658593
93a9cc01-eb44-4ed8-b56e-e261c6b85c9d	off-plan	Knightsbridge Phase 2	https://files.alnair.ae/uploads/2024/11/ba/de/badef4418b97711f8cd7929cb8517358.jpg,https://files.alnair.ae/uploads/2024/11/a1/5b/a15b332ac0b1919a95a1f8c84c5a0557.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12919556	55.35082153	Off-plan property: Knightsbridge Phase 2 by Leos Development	8f713edb-84d7-465d-8744-965901f5d7e7	3756642.32	1	3	1	3	320.77	641.55	\N	\N	\N	\N	\N	2025-11-02 21:43:06.660651	2025-11-02 21:43:06.660651
fec96ff3-4e8c-49ed-95e5-c1db28be3526	off-plan	Binghatti Pinnacle	https://files.alnair.ae/uploads/2025/9/e3/ad/e3ad0c589d3286bf1c8bacf4d26bf6aa.jpg,https://files.alnair.ae/uploads/2025/9/45/24/452422e90abe4aed2c58d61eaac69e76.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21226877	55.31447500	Off-plan property: Binghatti Pinnacle by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	394399.73	1	3	1	3	66.32	703.41	\N	\N	\N	\N	\N	2025-11-02 21:43:06.661408	2025-11-02 21:43:06.661408
d19e5588-b013-4d8e-9def-fd424f740e7a	off-plan	Glorious Central Residences	https://files.alnair.ae/uploads/2025/3/5c/df/5cdf305354c475911d95a88300cde894.jpg,https://files.alnair.ae/uploads/2025/3/63/49/634980df656c974d1edbbe9e2977baab.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14920581	55.39768651	Off-plan property: Glorious Central Residences by Glorious Future	48b7a963-81b0-47db-ac01-5ce171b0a57c	201633.60	0	1	1	2	53.65	86.73	\N	\N	\N	\N	\N	2025-11-02 21:43:06.665025	2025-11-02 21:43:06.665025
bbc1964d-e520-42ad-b5dd-0cf1a0c73d1a	off-plan	Vitalia Palm Jumeirah Residences	https://files.alnair.ae/uploads/2024/11/0d/5a/0d5a51528161621ce14592c67bb287f7.jpg,https://files.alnair.ae/uploads/2024/11/c3/4a/c34a2272980fd2e5240c04cc8becbb17.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14016764	55.14177778	Off-plan property: Vitalia Palm Jumeirah Residences by Pinnacle A K S Real Estate Development	f882965f-35fa-4483-9652-0d429c776d09	2461790.40	2	4	2	4	180.14	491.09	\N	\N	\N	\N	\N	2025-11-02 21:43:06.669049	2025-11-02 21:43:06.669049
6445ed42-b5ef-4d1a-b55e-1b5c1b22d843	off-plan	Avenue Park Towers	https://files.alnair.ae/uploads/2025/1/19/29/19293502959bd9a42a1e498417f9dea9.jpg,https://files.alnair.ae/uploads/2025/1/b9/85/b985f489bf6474504c1d9f6dd76e112a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.23345678	55.29323727	Off-plan property: Avenue Park Towers by Wasl	e0b7a2e8-0ba5-44cc-8ae0-f2450afb524a	1098547.34	3	4	3	4	161.84	477.34	\N	\N	\N	\N	\N	2025-11-02 21:43:06.670567	2025-11-02 21:43:06.670567
bf4ca676-2616-420c-a985-40838a039d10	off-plan	The Community Sports Arena	https://files.alnair.ae/uploads/2024/11/c0/66/c06609cc4cd97d191ebaa9a63fff6fd6.jpg,https://files.alnair.ae/uploads/2024/11/64/46/6446d334ea8ddd4770116e4702297522.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04378627	55.21962874	Off-plan property: The Community Sports Arena by Aqua	be42958b-d8c4-401b-8619-0b0cedcdd5c5	201305.30	0	3	1	3	45.43	190.65	\N	\N	\N	\N	\N	2025-11-02 21:43:06.672278	2025-11-02 21:43:06.672278
e8ad9df3-6e8d-4cfc-aa3e-2d9307aca548	off-plan	Raffi	https://files.alnair.ae/uploads/2024/11/c8/0f/c80f1fb3a6486cb80127c9dfaf04db4a.jpg,https://files.alnair.ae/uploads/2024/11/b0/87/b08776984d94d606b610d2a18704d06a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01841217	55.12152485	Off-plan property: Raffi by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	166464.00	0	3	1	3	30.57	177.07	\N	\N	\N	\N	\N	2025-11-02 21:43:06.67398	2025-11-02 21:43:06.67398
74ef545b-ec85-4bb2-8ebe-8a0a271b42d7	off-plan	Damac Lagoons - Nice	https://files.alnair.ae/uploads/2024/11/ae/ee/aeeee9edde60ac195f65b872a2e6d688.jpg,https://files.alnair.ae/uploads/2024/11/1e/46/1e46133427436fe9e45f3be69a6ba7cc.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00078308	55.23441636	Off-plan property: Damac Lagoons - Nice by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	897328.00	1	3	1	3	4.93	9.85	\N	\N	\N	\N	\N	2025-11-02 21:43:06.675466	2025-11-02 21:43:06.675466
48d3f513-6ca6-4ad1-87b2-ef7883e17a6b	off-plan	Laguna Residence	https://files.alnair.ae/uploads/2025/2/62/5e/625e7308fc5de5c52f434c2c78c9c15c.jpg,https://files.alnair.ae/uploads/2024/12/2f/cd/2fcdab9c18fc1262538c6ee54adf0912.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09036491	55.32521725	Off-plan property: Laguna Residence by One Development	043afefa-17ab-488c-93ff-b781995b857d	215424.00	0	3	1	3	40.45	352.45	\N	\N	\N	\N	\N	2025-11-02 21:43:06.676558	2025-11-02 21:43:06.676558
c946e9cc-1c62-4fcb-8bd5-6eee7e00d27f	off-plan	Brand Centro	https://files.alnair.ae/uploads/2024/12/19/bd/19bd79d28130e1d5e6c4d29a1bbf3996.jpg,https://files.alnair.ae/uploads/2024/12/bb/6a/bb6ab0177cf0540a3ef012dbd20df91f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21994750	55.27309929	Off-plan property: Brand Centro by EMS Development	0b2242eb-087d-487b-984e-5d529cc4c380	277726.69	0	2	1	2	35.04	229.63	\N	\N	\N	\N	\N	2025-11-02 21:43:06.67961	2025-11-02 21:43:06.67961
51dc001f-85b8-42a4-be2c-c47850b48f3d	off-plan	Bonds Avenue Residences	https://files.alnair.ae/uploads/2025/2/6e/a1/6ea14893f00831b19a67ac7d111a3288.jpg,https://files.alnair.ae/uploads/2025/2/d4/89/d48982172ad056642a7ed6295fc5b281.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29072237	55.30533001	Off-plan property: Bonds Avenue Residences by Amirah Developments	3611fe79-1291-46e6-b063-1609fa3131d8	536616.83	1	3	1	3	97.13	276.72	\N	\N	\N	\N	\N	2025-11-02 21:43:06.681261	2025-11-02 21:43:06.681261
34b16663-2395-4231-abb9-fc237cfaab79	off-plan	Mackerel Tower	https://files.alnair.ae/uploads/2024/11/9b/eb/9bebb7c6b45ead8f9e78ab35bf1d97c3.jpg,https://files.alnair.ae/uploads/2024/11/35/a0/35a04c812a2e299fd44144a5e7f4fa46.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29675254	55.31507179	Off-plan property: Mackerel Tower by Tarrad Development	6577dd65-71ee-4552-9286-4f98df3cc883	619888.00	2	4	2	4	113.89	349.76	\N	\N	\N	\N	\N	2025-11-02 21:43:06.682837	2025-11-02 21:43:06.682837
48f923e8-d57f-4498-97d8-fd0247aa45bd	off-plan	Sidr Residences	https://files.alnair.ae/uploads/2024/11/ea/09/ea09bff031c8c8a6e8c4c3b3351514f3.png,https://files.alnair.ae/uploads/2024/11/6b/89/6b89f68da5ac86fd038bc2d7334ab85a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.95750229	55.14989063	Off-plan property: Sidr Residences by Expo City	f152c1f4-6ec3-4c04-8438-a8190b3b68de	1376320.00	3	4	3	4	225.86	391.79	\N	\N	\N	\N	\N	2025-11-02 21:43:06.684322	2025-11-02 21:43:06.684322
f4e863d3-81f5-4710-bbff-ea53929cdf82	off-plan	Seagate	https://files.alnair.ae/uploads/2024/11/fa/95/fa9587c9c4f46c25b306839672cf8c9b.jpg,https://files.alnair.ae/uploads/2024/11/25/14/2514dc56da30ae997aaf9c6f8ea2883a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.25822646	55.27720436	Off-plan property: Seagate by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	652800.00	2	2	2	2	107.12	107.12	\N	\N	\N	\N	\N	2025-11-02 21:43:06.685912	2025-11-02 21:43:06.685912
8578e7a2-c000-4c7c-9a04-d72c1e63e5f8	off-plan	Stamn One	https://files.alnair.ae/uploads/2024/11/8d/b0/8db09e9329579b9667e7a4bdfa01c77f.jpg,https://files.alnair.ae/uploads/2024/11/07/8b/078b4ea8b142358f9974e4073d6999e8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22319870	55.27531408	Off-plan property: Stamn One by Stamn Development	0edd8c13-a7a3-4042-98f2-7b74e0791c14	295815.78	0	1	1	2	42.64	124.40	\N	\N	\N	\N	\N	2025-11-02 21:43:06.687418	2025-11-02 21:43:06.687418
87c8bb2e-337d-468d-b1e1-de49661a0f19	off-plan	ONDA	https://files.alnair.ae/uploads/2024/10/f7/25/f725f96351208d5d5bec9d57ba4b70ef.jpg,https://files.alnair.ae/uploads/2024/10/df/07/df07715ff463b9baf4f66f9c8be6a3af.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17866174	55.27394414	Off-plan property: ONDA by Kasco Real Estate Development	1b338acc-2755-400d-a415-3a983f896d20	394611.34	0	2	1	2	38.65	137.05	\N	\N	\N	\N	\N	2025-11-02 21:43:06.6893	2025-11-02 21:43:06.6893
a7fa9e8b-d1e2-4c43-9a6f-bd3fc868e197	off-plan	AG ARK	https://files.alnair.ae/uploads/2024/10/4e/cb/4ecbb8b81881358c491de1e9d2f3498d.jpg,https://files.alnair.ae/uploads/2024/10/f8/ca/f8ca4d0131441663ab4287ac13a500f0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08913517	55.38422115	Off-plan property: AG ARK by Ag Properties	0f7c019a-0553-415e-9c8f-d37bdb0fb1d6	249143.84	1	1	1	2	77.36	77.36	\N	\N	\N	\N	\N	2025-11-02 21:43:06.692203	2025-11-02 21:43:06.692203
83cc2159-5144-46a6-9aa9-52efd438b34f	off-plan	The Mansions - Sobha Hartland II	https://files.alnair.ae/uploads/2024/10/a0/d7/a0d74e540bb42ca9c5a51a3f6a848d0f.jpg,https://files.alnair.ae/uploads/2024/10/40/cd/40cd0dd6afed5bf01f6075624c25728d.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17663724	55.32774357	Off-plan property: The Mansions - Sobha Hartland II by Sobha	5f637246-907f-4e44-9b90-7c3065602155	35360000.00	1	3	1	3	378.14	756.29	\N	\N	\N	\N	\N	2025-11-02 21:43:06.694612	2025-11-02 21:43:06.694612
951125ae-3421-4718-8663-cbb90d64bb71	off-plan	Sobha Estate Phase II	https://files.alnair.ae/uploads/2024/10/c4/b5/c4b5ff888d86fdb43cea967697e0412b.jpg,https://files.alnair.ae/uploads/2024/10/41/c9/41c9666e8b4f9cf6ad3b4f528f7d2a48.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17931776	55.32837658	Off-plan property: Sobha Estate Phase II by Sobha	5f637246-907f-4e44-9b90-7c3065602155	8079298.42	1	3	1	3	440.94	881.88	\N	\N	\N	\N	\N	2025-11-02 21:43:06.695406	2025-11-02 21:43:06.695406
f0784546-c75e-49e4-b171-400c60941818	off-plan	Livel Residenza	https://files.alnair.ae/uploads/2024/10/46/5d/465d021f8024306f77663a1fd34eae1d.jpg,https://files.alnair.ae/uploads/2024/10/06/3d/063d2be9eb249a61da39cdaa12670daf.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06061495	55.21791950	Off-plan property: Livel Residenza by Vantage Developments	0e9a7b4c-dcea-4e7c-8d11-a232c5ddafb1	205511.23	0	2	1	2	41.99	115.76	\N	\N	\N	\N	\N	2025-11-02 21:43:06.696495	2025-11-02 21:43:06.696495
d948c785-6ae9-4215-8723-431334fe481c	off-plan	Eden House The Park	https://files.alnair.ae/uploads/2024/10/76/3b/763be8a49013f0bbbae3517ef71b3775.jpg,https://files.alnair.ae/uploads/2024/10/8a/18/8a184fb663302c68f0b0c7b4b5cb3583.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18787850	55.24813865	Off-plan property: Eden House The Park by H&H Development	b9e3db1f-eda1-44b1-8332-62be8b825be8	1793854.14	2	4	2	4	167.24	991.47	\N	\N	\N	\N	\N	2025-11-02 21:43:06.699105	2025-11-02 21:43:06.699105
aec7efe7-21f2-4d71-b47b-61480739e467	off-plan	Marina Cove	https://files.alnair.ae/uploads/2024/10/ce/c7/cec70fc0fb6380c74252580b0780c927.jpg,https://files.alnair.ae/uploads/2025/3/c7/ff/c7ff7fd9451ccf139fa5db09c0662c40.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07799037	55.14229260	Off-plan property: Marina Cove by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1244641.54	3	3	3	3	184.88	184.97	\N	\N	\N	\N	\N	2025-11-02 21:43:06.700622	2025-11-02 21:43:06.700622
719f55f7-9492-4806-8748-3bc84f5b2ce8	off-plan	Binghatti Hillviews	https://files.alnair.ae/uploads/2025/3/d6/92/d69274264291ca644101b18d8d4a1839.jpg,https://files.alnair.ae/uploads/2024/10/cf/02/cf02167c2d769164ca58ee1c8c70e35c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07861945	55.24879033	Off-plan property: Binghatti Hillviews by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	214880.00	0	2	1	2	38.09	147.90	\N	\N	\N	\N	\N	2025-11-02 21:43:06.702123	2025-11-02 21:43:06.702123
e3f7da78-6fea-4ed5-9e77-723f8790edec	off-plan	Maison Elysee III	https://files.alnair.ae/uploads/2024/10/b0/80/b0800ca9c16430fafc4fbd86977dc379.jpg,https://files.alnair.ae/uploads/2024/11/cf/2d/cf2d8610610abf9b76d183a2bab70d46.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04714028	55.20906012	Off-plan property: Maison Elysee III by Pantheon	a8c243a7-ac10-4ed9-a660-d05ee9b7ca60	250212.80	0	1	1	2	44.64	115.25	\N	\N	\N	\N	\N	2025-11-02 21:43:06.70365	2025-11-02 21:43:06.70365
6b53fe05-3895-403c-8b7f-91846cedeaf1	off-plan	Trafford Residences	https://files.alnair.ae/uploads/2024/12/61/34/6134a5b92f4a24478b9bb047adb8bc7a.jpg,https://files.alnair.ae/uploads/2024/10/b8/b1/b8b1886b3dd97b15b8c313c7f2dccc21.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94389409	55.22707924	Off-plan property: Trafford Residences by DV8 Developers	11f94184-adb1-4ac0-b41e-0fa99203b5ed	394400.00	2	2	2	2	117.12	117.12	\N	\N	\N	\N	\N	2025-11-02 21:43:06.705395	2025-11-02 21:43:06.705395
10e86016-c248-4f30-8653-c2c72f48be63	off-plan	Binghatti Skyrise	https://files.alnair.ae/uploads/2024/12/8d/57/8d57c9603f1d424b71e0f0c0e94b8ea4.jpg,https://files.alnair.ae/uploads/2024/12/e7/0e/e70e5ee9e5b59be8524bbb0f0df420dd.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18160788	55.27313600	Off-plan property: Binghatti Skyrise by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	513264.00	1	1	1	2	70.79	94.94	\N	\N	\N	\N	\N	2025-11-02 21:43:06.706878	2025-11-02 21:43:06.706878
3605dddd-2340-45a6-b8bc-02d65114fe75	off-plan	The Corner	https://files.alnair.ae/uploads/2024/10/dc/6a/dc6a28f3cc65c2766c2c2236af85793b.jpg,https://files.alnair.ae/uploads/2024/10/75/f9/75f95615fd2f901f5bdec19a6cf7c9c0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08688519	55.38864997	Off-plan property: The Corner by Arabian Gulf Properties	c05eb1e7-0720-4b45-8bc5-6c86b1efb977	188768.00	0	2	1	2	59.58	177.57	\N	\N	\N	\N	\N	2025-11-02 21:43:06.70976	2025-11-02 21:43:06.70976
cdc28aaf-42bb-4c16-895f-6137f9ea4ee0	off-plan	Samana Rome	https://files.alnair.ae/uploads/2024/10/ad/bc/adbc18f7e1ee04f62d38402f4f408b08.jpg,https://files.alnair.ae/uploads/2024/10/b7/96/b7968d8066188ccd38e24324d64b6ab6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12769651	55.35622525	Off-plan property: Samana Rome by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	517558.61	1	2	1	2	87.50	124.91	\N	\N	\N	\N	\N	2025-11-02 21:43:06.711311	2025-11-02 21:43:06.711311
767c1ad1-5af7-491c-90c3-d59f58b10c5c	off-plan	Binghatti Grove	https://files.alnair.ae/uploads/2024/10/2e/bc/2ebccee1a1e83a28e69f582d228e6eef.jpg,https://files.alnair.ae/uploads/2024/10/5d/a8/5da855d11749daea6fa5bda7aa08eefe.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05919835	55.21877244	Off-plan property: Binghatti Grove by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	322320.00	1	1	1	2	73.62	85.01	\N	\N	\N	\N	\N	2025-11-02 21:43:06.713701	2025-11-02 21:43:06.713701
7cbc48b3-781c-4f4a-8a64-0b555ac5e18e	off-plan	Samana Barari Lagoons	https://files.alnair.ae/uploads/2024/10/4f/95/4f95b120f1d0011e0eb5151af73e03e6.jpg,https://files.alnair.ae/uploads/2024/10/35/9e/359ec0a767c647eeb38db3798e845195.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09290574	55.32082808	Off-plan property: Samana Barari Lagoons by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	596917.87	2	2	2	2	124.77	124.77	\N	\N	\N	\N	\N	2025-11-02 21:43:06.715156	2025-11-02 21:43:06.715156
972f7e3a-020c-4729-b85d-fd19afd0b153	off-plan	Gharbi 2 Residences	https://files.alnair.ae/uploads/2025/1/8d/5e/8d5eb382b154a328b5e0553f133e23db.jpg,https://files.alnair.ae/uploads/2024/11/55/21/5521936f92c5acb61982a6d56230bea0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05953616	55.20911984	Off-plan property: Gharbi 2 Residences by Rabdan Real Estate Developments	8147c5dd-d275-4d04-84d4-4fce9ce87e0e	481440.00	2	2	2	2	151.15	161.19	\N	\N	\N	\N	\N	2025-11-02 21:43:06.71686	2025-11-02 21:43:06.71686
36f84178-e650-44fd-8470-c5e320f7404f	off-plan	Avenue Residence 7	https://files.alnair.ae/uploads/2024/10/63/0b/630b68cca09f9d97a4696145bab7a2ed.png,https://files.alnair.ae/uploads/2024/11/bf/a8/bfa85bb6b50bd54c50a6eb419c259279.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03661986	55.14140730	Off-plan property: Avenue Residence 7 by Nabni	918debfb-40e2-4fb6-b357-ce145abb1fbf	397236.69	1	3	1	3	82.31	189.22	\N	\N	\N	\N	\N	2025-11-02 21:43:06.720063	2025-11-02 21:43:06.720063
ac5d6764-073d-432b-8d2a-0fb796bd032f	off-plan	Amethyst By Siroya	https://files.alnair.ae/uploads/2025/1/9b/29/9b29426883096f36377d613e1be14c5a.jpg,https://files.alnair.ae/uploads/2025/1/3c/74/3c7424771f54220e308fc4ea844ebe6b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09363932	55.31854928	Off-plan property: Amethyst By Siroya by Siroya	6ba52c81-99af-4838-951e-16e6d4e7a057	358496.00	2	2	2	2	95.44	98.20	\N	\N	\N	\N	\N	2025-11-02 21:43:06.722913	2025-11-02 21:43:06.722913
71f09e3b-2428-4d7f-af57-24e028832de4	off-plan	Mag 777	https://files.alnair.ae/uploads/2024/10/7f/43/7f43a8b596f9fb86654076db7bb3eb6a.jpg,https://files.alnair.ae/uploads/2024/10/5b/46/5b4648784093ca76e8a878a487a30a95.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03997468	55.21899976	Off-plan property: Mag 777 by MAG Property Development	d5dfad6f-2582-4be3-89ae-c5625e33a996	214064.00	0	2	1	2	44.41	128.57	\N	\N	\N	\N	\N	2025-11-02 21:43:06.724382	2025-11-02 21:43:06.724382
de35ef0e-d79d-45a5-8d31-063b6cdb746f	off-plan	Verdana 10 Residences	https://files.alnair.ae/uploads/2024/9/4e/28/4e28eb61cc191d0f894838ce6d74dfae.jpg,https://files.alnair.ae/uploads/2024/9/b1/fe/b1fecc7fdae0f479f8f54d46fc78335a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98824908	55.16758482	Off-plan property: Verdana 10 Residences by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	307360.00	2	2	2	2	99.31	180.88	\N	\N	\N	\N	\N	2025-11-02 21:43:06.726181	2025-11-02 21:43:06.726181
f4246d8f-02eb-411e-add8-38b0110caa51	off-plan	Parkway	https://files.alnair.ae/uploads/2024/9/3d/c3/3dc321527bf99aa9c38514569692cd70.jpg,https://files.alnair.ae/uploads/2024/9/4a/72/4a72b1acc5beaee5b1b7246ad369fd87.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18005687	55.32580206	Off-plan property: Parkway by Prestige One	9ac691dd-fc8e-4f5a-8a06-e72173cbc5ab	451520.00	1	3	1	3	67.76	161.39	\N	\N	\N	\N	\N	2025-11-02 21:43:06.727714	2025-11-02 21:43:06.727714
e85ffcab-8782-46d7-b9bd-7508db96c516	off-plan	Saas Hills	https://files.alnair.ae/uploads/2024/11/e7/b9/e7b9bd8b1be90439bf969e115b6f3ec6.jpg,https://files.alnair.ae/uploads/2024/11/a1/a0/a1a0302eaa5ca9e27dc561c8a6e8fca7.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07972540	55.24738850	Off-plan property: Saas Hills by SAAS	518dfa5d-38e9-4f39-b2b1-7d543b332cb9	261454.29	0	5	1	5	45.17	555.37	\N	\N	\N	\N	\N	2025-11-02 21:43:06.730425	2025-11-02 21:43:06.730425
cbbac9bd-f36a-4775-bb27-f953b67e3ddc	off-plan	Vanguard By Franсk Muller	https://files.alnair.ae/uploads/2024/9/01/9f/019f8606648efcd3d0aebd01227a2bd5.jpg,https://files.alnair.ae/uploads/2024/9/32/dd/32dd27e00b908aaf48d13a1488f8dee7.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08812160	55.15190730	Off-plan property: Vanguard By Franсk Muller by London Gate	4b47b8ee-6457-403f-81cf-12bbbf751d23	468353.54	0	1	1	2	61.10	132.48	\N	\N	\N	\N	\N	2025-11-02 21:43:06.73234	2025-11-02 21:43:06.73234
ec564565-d2f1-40a0-bb33-fcc62dbedd6d	off-plan	Verdana VII Residences	https://files.alnair.ae/uploads/2024/9/25/be/25bee01f5c1e28c460fc06d4035fd5ce.jpg,https://files.alnair.ae/uploads/2024/9/52/ba/52bad13fb61828c69bd5c89857d49c93.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98996669	55.17156575	Off-plan property: Verdana VII Residences by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	150422.53	0	4	1	4	36.14	167.50	\N	\N	\N	\N	\N	2025-11-02 21:43:06.733908	2025-11-02 21:43:06.733908
ff66f79f-f3f7-48ae-8ed8-4eb9a96f287b	off-plan	Pier Point	https://files.alnair.ae/uploads/2024/9/2d/44/2d445b9d85d091a9105b7adc31b0bbc8.jpg,https://files.alnair.ae/uploads/2024/9/69/a0/69a0ba10758ff9531166c939be67d00d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.26621669	55.28476702	Off-plan property: Pier Point by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	2635649.54	3	3	3	3	249.17	249.17	\N	\N	\N	\N	\N	2025-11-02 21:43:06.735446	2025-11-02 21:43:06.735446
644b0182-c969-47c4-931e-84d44c48aa44	off-plan	Verdana VII Townhouses	https://files.alnair.ae/uploads/2024/9/ea/20/ea2096c22469da219334c07fbea6a22e.jpg,https://files.alnair.ae/uploads/2024/9/59/3d/593d2152f2643d791e5c6199a40a16c6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.99106250	55.17084405	Off-plan property: Verdana VII Townhouses by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	461040.00	1	3	1	3	1080.87	2161.75	\N	\N	\N	\N	\N	2025-11-02 21:43:06.736928	2025-11-02 21:43:06.736928
06902e70-cab3-4e9e-b2bf-eb82ea58132c	off-plan	V1stara House	https://files.alnair.ae/uploads/2024/9/17/af/17afdaebf0e7174dcbed49640ed54a71.jpg,https://files.alnair.ae/uploads/2024/10/28/61/2861316557dee46d328d64e11732f77a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02630023	55.14032374	Off-plan property: V1stara House by Object One	9d128f32-1c6c-474d-b911-61803444decc	400471.31	1	3	1	3	105.38	228.43	\N	\N	\N	\N	\N	2025-11-02 21:43:06.737713	2025-11-02 21:43:06.737713
d5dacc76-99fd-4a8f-976e-2be1ce41ce2b	off-plan	Kensington Gardens	https://files.alnair.ae/uploads/2024/9/61/1e/611ec2854e185aef24115cdf650daeb9.jpg,https://files.alnair.ae/uploads/2024/9/9f/64/9f64493cb926b0eb4baa0c45a7cee5c4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13391007	55.41288519	Off-plan property: Kensington Gardens by Leos Development	8f713edb-84d7-465d-8744-965901f5d7e7	1349900.10	1	3	1	3	220.46	440.93	\N	\N	\N	\N	\N	2025-11-02 21:43:06.739205	2025-11-02 21:43:06.739205
496ff9e0-1728-46f0-be76-8dcbe006f678	off-plan	Reef 1000	https://files.alnair.ae/uploads/2024/10/c0/a6/c0a6f0321fc1356ba6ee866d5859c716.png,https://files.alnair.ae/uploads/2024/10/b5/b7/b5b7d233bda660ecfe1752871bda1510.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08616004	55.37989944	Off-plan property: Reef 1000 by Reef Luxury Developments	e8a79f19-2efe-4d72-9a9e-0e4ebc39a9ca	352343.63	1	2	1	2	81.10	168.52	\N	\N	\N	\N	\N	2025-11-02 21:43:06.740232	2025-11-02 21:43:06.740232
4e76fcd7-181f-499c-89e6-b9d1bf4de598	off-plan	Binghatti Ivory	https://files.alnair.ae/uploads/2024/9/c8/1d/c81d913542f4a44c096fb8cb6e9da731.jpg,https://files.alnair.ae/uploads/2024/9/86/69/8669ffe2010c0578c14909520a246fac.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21068473	55.31783648	Off-plan property: Binghatti Ivory by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	303449.73	0	2	1	2	43.95	135.64	\N	\N	\N	\N	\N	2025-11-02 21:43:06.741918	2025-11-02 21:43:06.741918
850b3656-ed2b-4f1b-a05b-59f1528838c5	off-plan	Golf Hillside	https://files.alnair.ae/uploads/2024/9/1d/85/1d85e4483fb964aec84927968a00d8bb.jpg,https://files.alnair.ae/uploads/2024/9/6c/b3/6cb3fc08b5c0ac6d56b6227f29899218.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12853586	55.26132703	Off-plan property: Golf Hillside by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	768097.54	2	3	2	3	110.55	148.92	\N	\N	\N	\N	\N	2025-11-02 21:43:06.743574	2025-11-02 21:43:06.743574
6c5f3a57-c02d-45ae-8c44-e291219d0c3a	off-plan	District One Phase II Villas	https://files.alnair.ae/uploads/2024/9/7d/db/7ddb229b9c95d105c41987ea1ddeb2fc.jpg,https://files.alnair.ae/uploads/2024/9/76/b3/76b33d931aafe666a52ddc0fa26f83da.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.16816871	55.27742466	Off-plan property: District One Phase II Villas by Nakheel	d190bf02-5336-42e6-bba1-91ee1ab4b2d5	3808000.00	1	3	1	3	6.30	12.60	\N	\N	\N	\N	\N	2025-11-02 21:43:06.74612	2025-11-02 21:43:06.74612
e8946b48-2d15-4482-a41f-921399e55a70	off-plan	Zephyra Residences	https://files.alnair.ae/uploads/2024/9/ea/55/ea553338b9820a9a96bc3d7a407bd80a.jpg,https://files.alnair.ae/uploads/2024/9/7f/0f/7f0f511f92951a8297d86c5b5c7a555a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29150229	55.30066416	Off-plan property: Zephyra Residences by Arsenal East	603248a2-002d-4a62-8f0f-6f6758bb124f	499254.91	1	3	1	3	74.78	340.19	\N	\N	\N	\N	\N	2025-11-02 21:43:06.751333	2025-11-02 21:43:06.751333
36c65feb-2145-4106-a86a-6b13b42fabe0	off-plan	Enara	https://files.alnair.ae/uploads/2024/9/14/23/1423bdb74e35aadeb27af6e4dcefea9f.jpg,https://files.alnair.ae/uploads/2024/9/57/65/5765a2ec943bc5c206471f76af69907f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19170867	55.28727539	Off-plan property: Enara by Omniyat	6e10dff0-abd2-49b5-9c98-71ec8f1b446f	16320000.00	1	3	1	3	561.13	561.13	\N	\N	\N	\N	\N	2025-11-02 21:43:06.753122	2025-11-02 21:43:06.753122
5c44dfe2-7e21-47f3-b784-d7b1e67ad315	off-plan	Bayz 102	https://files.alnair.ae/uploads/2024/9/09/63/096321aeb634c7725e652b6d5483be42.jpg,https://files.alnair.ae/uploads/2024/9/18/34/1834fe81c2d3dc39b3a2bfd4ce44ae7d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18772638	55.26005298	Off-plan property: Bayz 102 by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	631040.00	0	5	1	5	69.56	802.93	\N	\N	\N	\N	\N	2025-11-02 21:43:06.755992	2025-11-02 21:43:06.755992
e6e048a8-5f1c-4e28-bda6-cb8438c9c434	off-plan	Sky Hills Residences 2	https://files.alnair.ae/uploads/2024/9/96/16/96168a11c33ae7e0f2f09d4b251a95ae.jpg,https://files.alnair.ae/uploads/2024/9/56/47/564722cf33243e02357a8df09a6fba1b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05516925	55.20030677	Off-plan property: Sky Hills Residences 2 by HRE Development	081fa9d3-a0f7-4d05-ab75-aa99feb00da8	489484.94	1	3	1	3	110.50	325.69	\N	\N	\N	\N	\N	2025-11-02 21:43:06.760484	2025-11-02 21:43:06.760484
b3297240-6b20-4548-b583-8129f286113a	off-plan	Sobha Solis	https://files.alnair.ae/uploads/2024/9/99/0d/990dc26f3cfe9b418767e02f528e548e.jpg,https://files.alnair.ae/uploads/2024/9/e3/26/e326f07776d2b3dbadc5de55f905444f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04885399	55.24263693	Off-plan property: Sobha Solis by Sobha	5f637246-907f-4e44-9b90-7c3065602155	544259.49	1	3	1	3	95.33	176.07	\N	\N	\N	\N	\N	2025-11-02 21:43:06.762266	2025-11-02 21:43:06.762266
e90d4cd3-ee2e-48e6-8530-87bcf6ca6f62	off-plan	Binghatti Royale	https://files.alnair.ae/uploads/2025/9/f6/f7/f6f7aec168ee7690e536a3715a82f606.jpg,https://files.alnair.ae/uploads/2024/9/2c/9b/2c9b4b9571afb18811f9c8fcba8aad35.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05398593	55.19971870	Off-plan property: Binghatti Royale by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	431024.53	1	1	1	2	74.93	74.94	\N	\N	\N	\N	\N	2025-11-02 21:43:06.76425	2025-11-02 21:43:06.76425
0ffbf9ca-72bd-4f9f-8c38-5c847b7a9d9d	off-plan	Binghatti Ghost	https://files.alnair.ae/uploads/2024/9/45/57/4557b5f18c2f9c07396549cc27459720.jpg,https://files.alnair.ae/uploads/2024/9/fa/87/fa872f0456ae2c0a7bebe995f0e86d76.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21386260	55.31842030	Off-plan property: Binghatti Ghost by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	268770.00	0	3	1	3	40.47	227.83	\N	\N	\N	\N	\N	2025-11-02 21:43:06.766192	2025-11-02 21:43:06.766192
41fe7d42-e18f-41e1-bfb1-5f3a1c675ad8	off-plan	Maya 3	https://files.alnair.ae/uploads/2024/12/64/ba/64ba6f905b0e125fe26b95c8191473e8.png,https://files.alnair.ae/uploads/2024/8/a1/8a/a18a03b20daf1bb419dab47f1b21e894.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08545557	55.38722858	Off-plan property: Maya 3 by Dugasta Properties Development	d4b3354c-36e1-4395-ad29-70911062e48d	447597.49	1	2	1	2	117.31	214.74	\N	\N	\N	\N	\N	2025-11-02 21:43:06.767863	2025-11-02 21:43:06.767863
7734b06d-3332-461e-a45a-c1fc5602453a	off-plan	Barari Parkview	https://files.alnair.ae/uploads/2025/3/7a/ca/7acafadb52cfa28e4f6b84455dde4c25.jpg,https://files.alnair.ae/uploads/2025/3/c7/2f/c72f2f0531fe34101fcc8f675cbd2c3b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09112280	55.31066090	Off-plan property: Barari Parkview by Al Mawared Properties	58f85f83-676e-493e-836c-48a308084479	373710.86	1	3	1	3	93.17	151.59	\N	\N	\N	\N	\N	2025-11-02 21:43:06.770955	2025-11-02 21:43:06.770955
49510e7b-3d06-4dbb-b5b7-6cd93f0dd32c	off-plan	Jasmine Lane	https://files.alnair.ae/uploads/2024/8/59/05/5905837f27132bb7ab6eb8b74d8c7798.jpg,https://files.alnair.ae/uploads/2024/8/98/0b/980b15305081e5479ca26497366894bb.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01351515	55.21164715	Off-plan property: Jasmine Lane by Fortune 5	9ec513c1-685a-4c58-b25d-e6cbc636b894	1210400.00	1	3	1	3	24.04	48.09	\N	\N	\N	\N	\N	2025-11-02 21:43:06.773886	2025-11-02 21:43:06.773886
304ad027-8b76-4907-8958-3ba688ee4049	off-plan	South Garden	https://files.alnair.ae/uploads/2024/9/70/c8/70c8823a09fe616f7b6fea6965216b83.jpg,https://files.alnair.ae/uploads/2024/9/0b/42/0b425eab79aa42638b2c53a957d02492.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02007043	55.10627123	Off-plan property: South Garden by Wasl	e0b7a2e8-0ba5-44cc-8ae0-f2450afb524a	462400.00	2	2	2	2	110.47	110.47	\N	\N	\N	\N	\N	2025-11-02 21:43:06.774854	2025-11-02 21:43:06.774854
e51794a7-a2b7-4bcc-b2a8-4d737e19246e	off-plan	Legado	https://files.alnair.ae/uploads/2024/9/c4/48/c448d294e5e32a482f80c9ef7acd482b.jpg,https://files.alnair.ae/uploads/2024/9/53/2e/532e116e3a8f1bc770c924c97d8f7c9c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04618900	55.20476085	Off-plan property: Legado by Prescott Development	b1781062-53b7-4448-a786-f2bab2542727	193120.00	0	2	1	2	34.53	143.38	\N	\N	\N	\N	\N	2025-11-02 21:43:06.776325	2025-11-02 21:43:06.776325
e0c8640a-06d1-4785-a4b0-9d9492c728bc	off-plan	V1V1D Residence	https://files.alnair.ae/uploads/2024/8/93/a0/93a0f5a31ce3e41e62719bf705448a12.jpg,https://files.alnair.ae/uploads/2024/8/46/79/46795a03ddfabd6c3d2a0b07ae983961.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03574499	55.17605826	Off-plan property: V1V1D Residence by Object One	9d128f32-1c6c-474d-b911-61803444decc	431196.98	1	1	1	2	104.01	104.01	\N	\N	\N	\N	\N	2025-11-02 21:43:06.777879	2025-11-02 21:43:06.777879
bed0fc3e-1574-4684-868c-dd8830caad58	off-plan	Waref Residences	https://files.alnair.ae/uploads/2024/11/08/7b/087b39045ddf8e7b958beb6477f9cd5d.jpg,https://files.alnair.ae/uploads/2024/11/80/82/8082bfe5729bc6f5b763b395e96d6755.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06884652	55.21216951	Off-plan property: Waref Residences by SIDO Developer	460b5059-9409-43e7-b7a1-c9c78727daf8	208188.80	0	2	1	2	41.34	162.67	\N	\N	\N	\N	\N	2025-11-02 21:43:06.779845	2025-11-02 21:43:06.779845
3060854a-9728-4248-9a7c-d316b52eb808	off-plan	Evora Residence	https://files.alnair.ae/uploads/2024/9/2b/0f/2b0f1174ab6cfcb6f8586f4b3907f27b.jpg,https://files.alnair.ae/uploads/2024/11/c1/5b/c15bcd47c79848e6ccf81f6109d8f334.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03956399	55.13919264	Off-plan property: Evora Residence by Anax Developments	854e1059-f59d-4ff6-8bf9-368829493fbb	563795.34	2	3	2	3	160.35	241.46	\N	\N	\N	\N	\N	2025-11-02 21:43:06.78165	2025-11-02 21:43:06.78165
70a3d176-93b5-478d-913c-762949306371	off-plan	I'Sola Bella	https://files.alnair.ae/uploads/2024/8/29/02/2902e1c7e0aaf2f7002d502e9bef35d7.jpg,https://files.alnair.ae/uploads/2024/8/32/38/32381b8ad5e30222de20716ab8c121c0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05168792	55.19990275	Off-plan property: I'Sola Bella by MAK Developers	d512be0a-9cdd-4edc-9e4c-b5dc93232758	209440.00	0	2	1	2	38.18	103.49	\N	\N	\N	\N	\N	2025-11-02 21:43:06.783125	2025-11-02 21:43:06.783125
bb05f778-55a0-4c28-b42e-5887096b4b0d	off-plan	One Sky Park	https://files.alnair.ae/uploads/2024/9/07/41/0741b03b6c83ac69523a03a73c7258c9.jpg,https://files.alnair.ae/uploads/2024/8/7b/ba/7bbab7ca6459340c3712107ae0185a19.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05584717	55.19658923	Off-plan property: One Sky Park by Iman Developers	6ad5348a-4fe7-4ee9-b98b-aa545a89e019	243014.86	0	1	1	2	41.16	88.26	\N	\N	\N	\N	\N	2025-11-02 21:43:06.784613	2025-11-02 21:43:06.784613
d0026b34-8a4d-4377-b877-bceede4df19c	off-plan	Fairmont Residences Solara Tower	https://files.alnair.ae/uploads/2024/8/8c/aa/8caae456d882da5b97437a89a054c54a.jpg,https://files.alnair.ae/uploads/2024/8/b5/61/b561036257fe42137fd1a088e9a7a53d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18970937	55.27189898	Off-plan property: Fairmont Residences Solara Tower by SOL Properties	da59d484-2f29-4f4b-849b-6f69819597ac	1604256.00	2	4	2	4	161.09	797.48	\N	\N	\N	\N	\N	2025-11-02 21:43:06.786121	2025-11-02 21:43:06.786121
0c372740-84e0-4d34-bee5-6782e311232c	off-plan	Ocean Pearl 2	https://files.alnair.ae/uploads/2024/8/4f/65/4f65533afe87020f46acc709c5008473.jpg,https://files.alnair.ae/uploads/2024/8/cd/44/cd441ef33619349b9e6019f3fc418c60.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29863003	55.32053978	Off-plan property: Ocean Pearl 2 by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	613060.80	1	4	1	4	83.61	183.71	\N	\N	\N	\N	\N	2025-11-02 21:43:06.787644	2025-11-02 21:43:06.787644
c7eeb67c-c7d2-4968-b989-e406fb71fc59	off-plan	Lilac Park	https://files.alnair.ae/uploads/2025/1/7f/f3/7ff36fd6b6afcda78c4db70b9baa1c2f.png,https://files.alnair.ae/uploads/2025/1/11/c5/11c5b837774c4d5bdfa8a04456a057dc.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05162606	55.21822074	Off-plan property: Lilac Park by SOL Properties	da59d484-2f29-4f4b-849b-6f69819597ac	897600.00	1	3	1	3	19.36	38.73	\N	\N	\N	\N	\N	2025-11-02 21:43:06.789158	2025-11-02 21:43:06.789158
581ba022-ddd0-4814-a1cf-7521abb3733b	off-plan	Canal Bay	https://files.alnair.ae/uploads/2024/8/b8/63/b8634cf648e88b3d5c310e02fcc5e0b3.png,https://files.alnair.ae/uploads/2024/8/8f/01/8f011f26680ae1162dec7af9e4f27f5c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18185485	55.27671895	Off-plan property: Canal Bay by NED Properties	97585794-da8b-483e-8ee8-eefe8f66fa43	612000.00	2	2	2	2	102.19	103.28	\N	\N	\N	\N	\N	2025-11-02 21:43:06.790453	2025-11-02 21:43:06.790453
eab8221b-6868-47b9-a8f7-afc0d4d0333a	off-plan	Astra South	https://files.alnair.ae/uploads/2024/12/1d/69/1d692155a5eba8cd5427399062c239aa.jpg,https://files.alnair.ae/uploads/2024/8/fe/7a/fe7a49aec0bb8677da3d1dfe6815c28c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94418714	55.22452295	Off-plan property: Astra South by Dugasta Properties Development	d4b3354c-36e1-4395-ad29-70911062e48d	443568.90	2	2	2	2	94.69	166.55	\N	\N	\N	\N	\N	2025-11-02 21:43:06.793579	2025-11-02 21:43:06.793579
51319992-73f8-413d-bf57-fc1bd22b3949	off-plan	Verdana 6 Residences	https://files.alnair.ae/uploads/2024/8/1f/ad/1fad2861a5fa61f09b2bac298befcd4b.jpg,https://files.alnair.ae/uploads/2024/8/cd/5f/cd5f1f5687f4a5278820e43329fb2eba.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98914800	55.17519950	Off-plan property: Verdana 6 Residences by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	252960.00	1	4	1	4	64.85	255.30	\N	\N	\N	\N	\N	2025-11-02 21:43:06.795104	2025-11-02 21:43:06.795104
d148b339-3991-4b9f-a71b-a7bef091761c	off-plan	Verdana 6 Townhouses	https://files.alnair.ae/uploads/2024/8/cd/84/cd84bf9777c05655d78324fce8b0e1dc.jpg,https://files.alnair.ae/uploads/2024/8/1b/b4/1bb4425025879fe5bbd44ece2a52e885.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98990044	55.17417669	Off-plan property: Verdana 6 Townhouses by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	462128.00	1	3	1	3	2043.16	4086.31	\N	\N	\N	\N	\N	2025-11-02 21:43:06.797153	2025-11-02 21:43:06.797153
40e400e8-f5d2-4f0c-96cf-21dc9d96264e	off-plan	Al Haseen Residences 3	https://files.alnair.ae/uploads/2024/8/ab/e3/abe359a29e946b8d797a2235ef83e67c.jpg,https://files.alnair.ae/uploads/2024/8/33/7e/337e74e47aa2c58bfa7a7a8f8268b3d8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.87070153	55.03927514	Off-plan property: Al Haseen Residences 3 by Dugasta Properties Development	d4b3354c-36e1-4395-ad29-70911062e48d	448126.80	1	2	1	2	102.04	108.81	\N	\N	\N	\N	\N	2025-11-02 21:43:06.798237	2025-11-02 21:43:06.798237
203a27f3-7e9c-4c1f-9bb9-e1872be285a1	off-plan	Dezire South Residences	https://files.alnair.ae/uploads/2024/8/48/3a/483ad4df11e641b48a0d3737fc1f9c63.jpg,https://files.alnair.ae/uploads/2024/8/cd/93/cd9307c8758ae29876c4dbc0767c9b17.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.89030300	55.07456600	Off-plan property: Dezire South Residences by Dugasta Properties Development	d4b3354c-36e1-4395-ad29-70911062e48d	409637.44	2	2	2	2	103.64	103.64	\N	\N	\N	\N	\N	2025-11-02 21:43:06.799818	2025-11-02 21:43:06.799818
83588824-45d1-4519-8aed-0240c8649806	off-plan	One Beverly	https://files.alnair.ae/uploads/2024/9/4d/f4/4df43e9aed4a5e7611c96f2a151c9bcf.jpg,https://files.alnair.ae/uploads/2024/9/1d/03/1d0301076371f3bf3557e9b84e98a8e2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06711849	55.23320675	Off-plan property: One Beverly by HMB Homes	5e76bc8e-626d-4bac-a67f-215db9f997ff	190400.00	0	1	1	2	35.95	73.39	\N	\N	\N	\N	\N	2025-11-02 21:43:06.801475	2025-11-02 21:43:06.801475
3d78d09d-ebe0-41a5-9396-c5a7ad6e241e	off-plan	Dugasta Warsan	https://files.alnair.ae/uploads/2024/8/0b/01/0b01301a96db3bfb464d10eeea9da0b4.jpg,https://files.alnair.ae/uploads/2024/8/87/b5/87b5296d76342dfc8dc55421eaafd3ee.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14724419	55.39226644	Off-plan property: Dugasta Warsan by Dugasta Properties Development	d4b3354c-36e1-4395-ad29-70911062e48d	231869.66	0	2	1	2	60.92	162.20	\N	\N	\N	\N	\N	2025-11-02 21:43:06.803697	2025-11-02 21:43:06.803697
be781f00-60e4-4478-8317-8ec8b8868cf6	off-plan	7 Seasons	https://files.alnair.ae/uploads/2024/8/8b/92/8b921f21cdab9e3a9fcedb3f1eba7020.jpg,https://files.alnair.ae/uploads/2024/8/f6/09/f6097267df4c518c8ceceba8efc5a801.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14275701	55.39807543	Off-plan property: 7 Seasons by Dugasta Properties Development	d4b3354c-36e1-4395-ad29-70911062e48d	241268.35	0	2	1	2	63.39	129.62	\N	\N	\N	\N	\N	2025-11-02 21:43:06.805161	2025-11-02 21:43:06.805161
4a50ba16-2010-4b3e-a432-eaf7baeefe1f	off-plan	Moonsa Residences 2	https://files.alnair.ae/uploads/2024/8/b8/e8/b8e8a1f1921a478509e303aab6186397.jpg,https://files.alnair.ae/uploads/2024/9/ad/a7/ada72be44961b8f231879542c6f366eb.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14286156	55.40046751	Off-plan property: Moonsa Residences 2 by Dugasta Properties Development	d4b3354c-36e1-4395-ad29-70911062e48d	202027.18	0	1	1	2	40.59	159.42	\N	\N	\N	\N	\N	2025-11-02 21:43:06.806801	2025-11-02 21:43:06.806801
582847a7-5ce4-40db-b775-f1b318ce7216	off-plan	Iluka Residences	https://files.alnair.ae/uploads/2024/8/23/ec/23ecd0e44cbf95bbea4801a91ac129fe.jpg,https://files.alnair.ae/uploads/2025/1/79/37/793768641ba8cbacede47c991af7bd58.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29170290	55.29323266	Off-plan property: Iluka Residences by MS Homes	33f0f509-0aaf-499e-8557-9ecc46fcf990	961883.66	2	3	2	3	150.22	188.87	\N	\N	\N	\N	\N	2025-11-02 21:43:06.80851	2025-11-02 21:43:06.80851
7aae4884-2cf9-4cd3-8a7b-8d30fc5c4cef	off-plan	Terra Tower	https://files.alnair.ae/uploads/2024/8/50/67/5067010e103bab24554282ec1d30cf11.jpg,https://files.alnair.ae/uploads/2024/9/fe/38/fe38b1402c99afc61f01e1ff6a2290b0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09764658	55.37243754	Off-plan property: Terra Tower by Dugasta Properties Development	d4b3354c-36e1-4395-ad29-70911062e48d	332780.58	1	3	1	3	66.86	222.37	\N	\N	\N	\N	\N	2025-11-02 21:43:06.809947	2025-11-02 21:43:06.809947
103c3cad-02d5-4586-bc9c-d9c5864b4b4f	off-plan	AB Cavalier	https://files.alnair.ae/uploads/2024/8/61/e2/61e235daf5ebf47c75b921b5e09ff7c7.jpg,https://files.alnair.ae/uploads/2024/8/29/5a/295a1793ad79e7a178c3b39a39996654.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05315431	55.21284409	Off-plan property: AB Cavalier by AB Developers	823c1424-3caa-4a77-97e7-553cd5f04f2d	356320.00	1	1	1	2	80.18	148.87	\N	\N	\N	\N	\N	2025-11-02 21:43:06.81147	2025-11-02 21:43:06.81147
4599c287-ea7a-4339-a818-0e2ace09340f	off-plan	PG Maison	https://files.alnair.ae/uploads/2024/8/81/be/81be95fea293225e3474b28a0ac82428.jpg,https://files.alnair.ae/uploads/2024/8/7a/c2/7ac2868fa30ff739126acfe4c7bdb315.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02631546	55.13886206	Off-plan property: PG Maison by PG Properties	561fbee3-e86f-45d6-8539-fc385b1fe3d2	523858.94	2	2	2	2	133.13	141.96	\N	\N	\N	\N	\N	2025-11-02 21:43:06.813489	2025-11-02 21:43:06.813489
386c08a7-2ca6-4720-b69d-fdd40c7c6f46	off-plan	Golf Point	https://files.alnair.ae/uploads/2024/12/a2/49/a24947640e6c4456dea4a82ce8058e4c.jpg,https://files.alnair.ae/uploads/2024/8/d2/b1/d2b10d969c0e35d6e95756e69ec1618d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.86073360	55.14394154	Off-plan property: Golf Point by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	937281.54	3	3	3	3	174.66	192.50	\N	\N	\N	\N	\N	2025-11-02 21:43:06.815138	2025-11-02 21:43:06.815138
4116aeda-cda9-4eb4-aede-9cf837742d88	off-plan	Time 3	https://files.alnair.ae/uploads/2024/9/64/ed/64ed2574e62c00b6fdb5c7e1fd220878.jpg,https://files.alnair.ae/uploads/2024/9/1b/72/1b72a7c73b6d4c5d973aec443f68592f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09639383	55.38146183	Off-plan property: Time 3 by Time Properties	041913a8-13d7-47ec-b576-4705512c83ac	247792.00	1	1	1	2	73.11	114.73	\N	\N	\N	\N	\N	2025-11-02 21:43:06.816832	2025-11-02 21:43:06.816832
4ac9a487-b698-481b-a91d-1780e8d7cc88	off-plan	Gharbi I Residences	https://files.alnair.ae/uploads/2024/8/76/da/76daf6c63caf22d6d77649f93a516e5d.jpg,https://files.alnair.ae/uploads/2024/8/bd/c9/bdc97e107acd2d8459371b2ca40d3719.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05933145	55.23553491	Off-plan property: Gharbi I Residences by Rabdan Real Estate Developments	8147c5dd-d275-4d04-84d4-4fce9ce87e0e	372640.00	1	2	1	2	106.56	325.53	\N	\N	\N	\N	\N	2025-11-02 21:43:06.818283	2025-11-02 21:43:06.818283
2257585c-1dce-4fcc-b24e-700a91e14eeb	off-plan	Knightsbridge Phase 1	https://files.alnair.ae/uploads/2024/7/99/62/996283a4e2984aa2c471faff0abe91ad.jpg,https://files.alnair.ae/uploads/2024/8/ac/1c/ac1c3c954a7373d10e95761a759535e1.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13106550	55.35123750	Off-plan property: Knightsbridge Phase 1 by Leos Development	8f713edb-84d7-465d-8744-965901f5d7e7	2160235.97	1	3	1	3	88.83	177.66	\N	\N	\N	\N	\N	2025-11-02 21:43:06.81976	2025-11-02 21:43:06.81976
fc2d01c4-183e-44cc-8dd5-716652ca087c	off-plan	Club Place	https://files.alnair.ae/uploads/2024/7/34/ae/34ae6434feb7b543d7efaf73cfc43d1a.jpg,https://files.alnair.ae/uploads/2024/7/7f/98/7f985bfd821160e9c159ce3e757451f4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12722848	55.26088446	Off-plan property: Club Place by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	753137.54	2	3	2	3	108.51	179.40	\N	\N	\N	\N	\N	2025-11-02 21:43:06.820512	2025-11-02 21:43:06.820512
e2c26585-34e1-4e10-9d77-f5168d9376a8	off-plan	Ocean Pearl	https://files.alnair.ae/uploads/2024/7/84/7e/847eb772221446c4bdbf3ef231e4d9b7.jpg,https://files.alnair.ae/uploads/2024/7/14/c9/14c9ba391cc714171549b7c2f9ae92f1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29988197	55.31468153	Off-plan property: Ocean Pearl by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	964620.80	2	4	2	4	142.56	183.41	\N	\N	\N	\N	\N	2025-11-02 21:43:06.821942	2025-11-02 21:43:06.821942
b0c60bde-d3ad-4c76-95ef-31bc7da8b5f4	off-plan	Mayfair Gardens	https://files.alnair.ae/uploads/2024/7/17/e3/17e3b4ede6b5803bd0855bbed1a632ee.jpg,https://files.alnair.ae/uploads/2024/7/e6/d6/e6d684ae3bae048a8ab21ef624f0aaf8.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21859862	55.27448192	Off-plan property: Mayfair Gardens by Majid Developments	d455a56f-fc60-458a-864a-efe2ca9f6df1	504916.05	1	1	1	2	76.09	101.17	\N	\N	\N	\N	\N	2025-11-02 21:43:06.823377	2025-11-02 21:43:06.823377
9f241dac-737f-464f-9365-1951700b954b	off-plan	Riverside Views - Marine 1	https://files.alnair.ae/uploads/2025/1/ba/a3/baa38418e14a3cc48328844016b49ace.jpg,https://files.alnair.ae/uploads/2025/1/1b/5d/1b5d25c07e484f88e107bd21b0117b96.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.97626429	55.22900105	Off-plan property: Riverside Views - Marine 1 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	408000.00	1	2	1	2	89.20	137.77	\N	\N	\N	\N	\N	2025-11-02 21:43:06.824871	2025-11-02 21:43:06.824871
a688263d-e131-4d24-b0fa-d8477a4791e2	off-plan	ALTUS	https://files.alnair.ae/uploads/2024/7/5d/5a/5d5a06550a438ddd5d5a4bb4bac8cfae.png,https://files.alnair.ae/uploads/2024/7/2a/67/2a673182cc2fd0edfe2506c3dae54c71.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20718353	55.35332143	Off-plan property: ALTUS by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1085793.54	3	3	3	3	148.27	179.02	\N	\N	\N	\N	\N	2025-11-02 21:43:06.826598	2025-11-02 21:43:06.826598
bfdf7ece-d03f-4c58-8578-83ef4ede0eec	off-plan	Hyde Residences	https://files.alnair.ae/uploads/2024/7/15/7e/157e706032c6c72cd32ba260900d5eba.png,https://files.alnair.ae/uploads/2025/7/68/58/68584f6d7d81fa039c5c90a02635257e.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10402307	55.24223238	Off-plan property: Hyde Residences by City View Development	011a56d6-22b9-4e65-a12d-dbbd170458b5	619555.34	1	2	1	2	74.33	124.07	\N	\N	\N	\N	\N	2025-11-02 21:43:06.828012	2025-11-02 21:43:06.828012
b8b7b47a-5a0c-4c59-9eec-60e4df1df395	off-plan	Alba Tower	https://files.alnair.ae/uploads/2024/7/7c/b2/7cb209f8e69841aad0043391102f3559.jpg,https://files.alnair.ae/uploads/2024/7/cb/6c/cb6c31309ab0d58a69069f7b47efa0bc.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22440525	55.27931423	Off-plan property: Alba Tower by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	333472.00	2	2	2	2	63.73	184.97	\N	\N	\N	\N	\N	2025-11-02 21:43:06.82942	2025-11-02 21:43:06.82942
81f82292-c68c-4d25-b81c-bc990754bde8	off-plan	One Residence	https://files.alnair.ae/uploads/2024/7/5f/ec/5fec2069c27931c702280a03c1c78a98.jpg,https://files.alnair.ae/uploads/2024/7/f5/02/f5026e6514f24e55d480b41033d00b12.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19417233	55.28532336	Off-plan property: One Residence by Ginco Properties	506e86f8-e9a6-4cf0-87d2-a7db97ac97b9	414800.00	0	2	1	2	43.62	131.14	\N	\N	\N	\N	\N	2025-11-02 21:43:06.831026	2025-11-02 21:43:06.831026
f4cacdf8-a265-485e-92b9-df7c2fcc151e	off-plan	Aurora by Binghatti	https://files.alnair.ae/uploads/2024/7/b8/89/b889332bdb73f225dc2d483858d0c44c.png,https://files.alnair.ae/uploads/2025/3/1b/16/1b1656675c0ea267ddd68889a2351421.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05684000	55.21905400	Off-plan property: Aurora by Binghatti by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	329459.73	1	1	1	2	70.31	74.53	\N	\N	\N	\N	\N	2025-11-02 21:43:06.832509	2025-11-02 21:43:06.832509
c5351ab9-190f-4c9d-a5b0-e55a33097f0a	off-plan	The Pulse Townhouses	https://files.alnair.ae/uploads/2024/7/65/89/6589a3bbac6f9e93b262d21d81e13c05.png,https://files.alnair.ae/uploads/2024/7/0c/65/0c65ac43858a02101fdf3f82c4111f52.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94531922	55.22215605	Off-plan property: The Pulse Townhouses by Dubai South	e0931680-f521-469b-8c27-42de9933fb4c	1060800.00	1	3	1	3	44.83	89.66	\N	\N	\N	\N	\N	2025-11-02 21:43:06.833924	2025-11-02 21:43:06.833924
b49d6758-e8ef-4be2-9b0c-745d42eb602a	off-plan	Ghaff Land Residence	https://files.alnair.ae/uploads/2024/7/ab/a2/aba2b7e4ffd0f7fa02b3a6b4f3d29563.jpg,https://files.alnair.ae/uploads/2024/7/e1/61/e161f5a917b7a3a3f68274defdba56a0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03433588	55.23378494	Off-plan property: Ghaff Land Residence by Arabian Gulf Properties	c05eb1e7-0720-4b45-8bc5-6c86b1efb977	183140.32	0	2	1	2	44.04	210.43	\N	\N	\N	\N	\N	2025-11-02 21:43:06.834875	2025-11-02 21:43:06.834875
1cd6fdf5-bf6e-444f-8986-c99c34396140	off-plan	Damac Lagoons Costa Brava	https://files.alnair.ae/uploads/2024/7/20/a7/20a77aaec566c2b05060c22592cdb0d5.png,https://files.alnair.ae/uploads/2024/7/f2/77/f2776f451c768be770fae8d8c513e8d1.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.99907900	55.23957447	Off-plan property: Damac Lagoons Costa Brava by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	612000.00	1	3	1	3	2.12	4.24	\N	\N	\N	\N	\N	2025-11-02 21:43:06.836321	2025-11-02 21:43:06.836321
1ad7e784-23be-4ac5-8724-e4efd4a382e3	off-plan	Neila	https://files.alnair.ae/uploads/2024/7/08/c7/08c7435190d5c3229948239f6f45f42b.jpg,https://files.alnair.ae/uploads/2024/7/64/b3/64b324811410c62fbed0123d14fb77fe.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03837687	55.14029771	Off-plan property: Neila by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	188496.00	0	0	1	2	33.35	33.35	\N	\N	\N	\N	\N	2025-11-02 21:43:06.837304	2025-11-02 21:43:06.837304
d576784b-0fb8-455a-abc4-513d769bc72b	off-plan	Nineteen Riviera Lagoon	https://files.alnair.ae/uploads/2024/7/29/04/290490f8bee3a36862d360475257f873.png,https://files.alnair.ae/uploads/2024/7/d9/56/d956da59c2baaa67606a5cb11fd4d603.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12676952	55.34316525	Off-plan property: Nineteen Riviera Lagoon by Riviera Group	98de99b1-9599-4bea-bd9b-23a7b3ec1f8a	6664000.00	1	3	1	3	333.71	667.43	\N	\N	\N	\N	\N	2025-11-02 21:43:06.840075	2025-11-02 21:43:06.840075
8e32dd3a-b0cc-4fb1-acb0-f4cb3db3d25d	off-plan	Anantara South Palm Jumeirah	https://files.alnair.ae/uploads/2024/7/7c/0a/7c0aa40d173fd2f20cfeb90800a6ff92.jpg,https://files.alnair.ae/uploads/2024/7/c9/51/c9519d509aa04258344dcbd8109a940e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12818914	55.15389000	Off-plan property: Anantara South Palm Jumeirah by Seven Tides	f605b496-c28f-452d-b005-c5f1a77748fc	6419441.54	4	4	4	4	843.70	985.80	\N	\N	\N	\N	\N	2025-11-02 21:43:06.841946	2025-11-02 21:43:06.841946
ef2146a4-d35c-4dd3-9c3b-15c57895d60a	off-plan	Skyscape Altius	https://files.alnair.ae/uploads/2024/7/b7/55/b75594557a6e4d92c9d071a8efdb4883.jpg,https://files.alnair.ae/uploads/2024/7/33/1c/331c3ef75d6c6a785845ebf04c2e6813.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17226832	55.33020687	Off-plan property: Skyscape Altius by Sobha	5f637246-907f-4e44-9b90-7c3065602155	517513.46	1	4	1	4	76.88	268.17	\N	\N	\N	\N	\N	2025-11-02 21:43:06.843475	2025-11-02 21:43:06.843475
452baa22-69fe-4e00-862c-db0e3406be05	off-plan	The Autograph S Series	https://files.alnair.ae/uploads/2024/7/d1/5d/d15d645e229928b96969463c00b0cccd.jpg,https://files.alnair.ae/uploads/2024/7/08/b3/08b3bb8406b8bd655ca93a7392fc0883.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05547176	55.20199925	Off-plan property: The Autograph S Series by Green Group	4141aec9-21ce-4490-8df8-f81950a8242f	884231.20	2	2	2	2	184.02	191.48	\N	\N	\N	\N	\N	2025-11-02 21:43:06.844979	2025-11-02 21:43:06.844979
6dfb11d0-72bb-4391-bd84-b03e99c743cd	off-plan	Sky Suites	https://files.alnair.ae/uploads/2024/12/3e/da/3eda917484046577aca2e1473d24372b.jpg,https://files.alnair.ae/uploads/2024/7/28/fc/28fc7d5145205964ccbd9ee91210afc0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06325662	55.20916611	Off-plan property: Sky Suites by Peace Homes Development	b8fb9b75-948a-4296-82c3-953c9d1bc61e	273377.95	0	2	1	2	43.45	409.33	\N	\N	\N	\N	\N	2025-11-02 21:43:06.846621	2025-11-02 21:43:06.846621
71d6e816-799a-49f7-b4ad-da8fdb2735f3	off-plan	Damac Lagoons - Monte Carlo	https://files.alnair.ae/uploads/2024/7/97/db/97db7fef4e49ec4cd28bd2766f2792a1.jpg,https://files.alnair.ae/uploads/2024/7/61/b4/61b4e9fcc46d8e3b69313d0afe1f343a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00659350	55.21834200	Off-plan property: Damac Lagoons - Monte Carlo by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	660960.00	1	3	1	3	36.98	73.97	\N	\N	\N	\N	\N	2025-11-02 21:43:06.84816	2025-11-02 21:43:06.84816
3780af90-e86f-4df8-a8e2-14b029c73f7a	off-plan	Marina Views	https://files.alnair.ae/uploads/2024/7/71/80/7180bd8c3662e37dd268328669b45a7f.jpg,https://files.alnair.ae/uploads/2024/7/28/4a/284aea70482376318ee106427c7ce7a2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.25823252	55.27545154	Off-plan property: Marina Views by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1127493.31	2	2	2	2	116.81	116.81	\N	\N	\N	\N	\N	2025-11-02 21:43:06.848865	2025-11-02 21:43:06.848865
b46aa2eb-be17-4003-9eb1-2fc79ecfa208	off-plan	Peace Lagoons	https://files.alnair.ae/uploads/2024/7/18/2b/182bab95fbec6f6e1df6da64196bdc67.jpg,https://files.alnair.ae/uploads/2024/7/a2/95/a295843e9b174966ca9de64c8e0b9d63.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09745544	55.38083658	Off-plan property: Peace Lagoons by Peace Homes Development	b8fb9b75-948a-4296-82c3-953c9d1bc61e	381007.26	1	2	1	2	59.22	128.08	\N	\N	\N	\N	\N	2025-11-02 21:43:06.850329	2025-11-02 21:43:06.850329
8a42328a-5f7f-4e1d-8504-089f55d56734	off-plan	Bayshore at Creek Beach	https://files.alnair.ae/uploads/2024/7/ce/95/ce95a750c02248869a79552b5adf6d4c.jpg,https://files.alnair.ae/uploads/2024/7/ca/b6/cab60920494bbf91a27322a5e33ca38f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20079350	55.34894150	Off-plan property: Bayshore at Creek Beach by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	541280.00	1	2	1	2	64.11	101.01	\N	\N	\N	\N	\N	2025-11-02 21:43:06.85177	2025-11-02 21:43:06.85177
fb926fd7-b211-446c-bea1-30033ac309a9	off-plan	11 Hills Park	https://files.alnair.ae/uploads/2024/11/1e/5c/1e5c02098ed1a1076276cb4601ef5444.jpg,https://files.alnair.ae/uploads/2024/7/d8/ea/d8ea8ca9bc50390c04bec51139593be6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07776080	55.24698392	Off-plan property: 11 Hills Park by TownX	95773061-50af-429b-ab24-d3b738a4e758	234004.59	0	1	1	2	45.23	110.90	\N	\N	\N	\N	\N	2025-11-02 21:43:06.85323	2025-11-02 21:43:06.85323
9e06fd43-85ef-405d-a386-ffb98ce4d208	off-plan	Urban Life Residences	https://files.alnair.ae/uploads/2024/12/40/7e/407ed1b3b6b74540ff0a5c59720a72bb.jpg,https://files.alnair.ae/uploads/2025/2/6c/5a/6c5aa78ef2472420d3c026a057e3dd26.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17756578	55.27133569	Off-plan property: Urban Life Residences by Urban Properties	b1a9c547-6be6-4905-b1fe-73a103b0d4d0	502486.82	1	2	1	2	72.19	163.70	\N	\N	\N	\N	\N	2025-11-02 21:43:06.855044	2025-11-02 21:43:06.855044
2cc60344-14af-424b-bf2a-5969db7320cd	off-plan	Takaya	https://files.alnair.ae/uploads/2024/7/4b/d1/4bd1ce4b0ec62248cf1d6ec48988b96f.jpg,https://files.alnair.ae/uploads/2024/7/09/af/09af89ca37bc5db024f35e1b826ff92f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04704611	55.23484558	Off-plan property: Takaya by Union Properties	7f9e7c95-ca62-47ae-8388-5e4d22362c86	440200.45	1	4	1	4	77.20	620.19	\N	\N	\N	\N	\N	2025-11-02 21:43:06.856911	2025-11-02 21:43:06.856911
5f8c993e-90d4-423e-bf5b-7f7cef2324a5	off-plan	Ellington House	https://files.alnair.ae/uploads/2025/1/4b/a3/4ba32bbf159b7e516e5b9d2aeaa3ef50.jpg,https://files.alnair.ae/uploads/2024/7/fe/ff/feffe804d3f35ddb7f60bff2b32830ce.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11917858	55.25793448	Off-plan property: Ellington House by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	483925.81	1	3	1	3	78.13	162.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.858431	2025-11-02 21:43:06.858431
2599ec2e-cfda-441a-a8bf-a38afac75672	off-plan	Damac Lagoons - Mykonos	https://files.alnair.ae/uploads/2024/7/60/fd/60fd5949e04d2e531f76a6b767e0d113.jpg,https://files.alnair.ae/uploads/2024/7/95/d1/95d12acaa2fbac87ee456a75afaacbe4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00790266	55.22286415	Off-plan property: Damac Lagoons - Mykonos by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	720800.00	1	3	1	3	4.59	9.17	\N	\N	\N	\N	\N	2025-11-02 21:43:06.859882	2025-11-02 21:43:06.859882
86bdd8be-f3fa-4df1-b7c2-b664f76b498f	off-plan	Blossom 76 By Tranquil	https://files.alnair.ae/uploads/2025/2/d9/26/d92678105b28a76a486fc8af573988be.jpg,https://files.alnair.ae/uploads/2025/2/d9/1d/d91dda45fae786cfcaa2be68feb2764a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05944437	55.21621160	Off-plan property: Blossom 76 By Tranquil by Tranquil Infra Developers	7331f038-7b3e-4359-8f89-e23a2f080bb9	178758.40	0	1	1	2	39.39	96.71	\N	\N	\N	\N	\N	2025-11-02 21:43:06.86191	2025-11-02 21:43:06.86191
dc5c5915-5dea-4752-a6b4-80d34dde3008	off-plan	Verdana 5 Townhouses	https://files.alnair.ae/uploads/2024/6/58/ff/58ff7fccc8313a068079e173a63e0983.jpg,https://files.alnair.ae/uploads/2024/6/75/d1/75d1361a65e20860bb2780d3964edbcb.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98845233	55.17669931	Off-plan property: Verdana 5 Townhouses by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	493680.00	1	3	1	3	763.86	1527.72	\N	\N	\N	\N	\N	2025-11-02 21:43:06.864741	2025-11-02 21:43:06.864741
c95fbcd5-08b4-4d48-b014-5d92f35d98e4	off-plan	Havelock Heights	https://files.alnair.ae/uploads/2024/9/dc/ac/dcacc8551d32fddb64b475da97c5fcd7.jpg,https://files.alnair.ae/uploads/2024/7/5b/66/5b66fd7237dbbd20dedcaa1e66402661.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06202417	55.20174377	Off-plan property: Havelock Heights by HMB Homes	5e76bc8e-626d-4bac-a67f-215db9f997ff	197200.00	0	3	1	3	34.47	268.23	\N	\N	\N	\N	\N	2025-11-02 21:43:06.865483	2025-11-02 21:43:06.865483
577dc87a-7c8e-41d5-878b-247d20717f2e	off-plan	Verdana 5 Residences	https://files.alnair.ae/uploads/2024/6/c4/44/c4449691d323fb6dd492e6b77a60762f.jpg,https://files.alnair.ae/uploads/2024/6/49/c5/49c586bbead92dcdc436fadad3c8945a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98824300	55.17589400	Off-plan property: Verdana 5 Residences by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	242080.00	1	4	1	4	79.53	171.22	\N	\N	\N	\N	\N	2025-11-02 21:43:06.867044	2025-11-02 21:43:06.867044
7bd6c281-970d-4200-83e7-d6d99876602b	off-plan	Mansory Residences by AMAAL	https://files.alnair.ae/uploads/2025/6/70/5b/705b8d63ae97937f92517d9ff218f55b.png,https://files.alnair.ae/uploads/2025/6/7b/d9/7bd979b64089bb04d589e9be73908d48.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18372390	55.33570871	Off-plan property: Mansory Residences by AMAAL by Amaal Development	c1ea77b0-4cd5-470a-8fb4-70b3b14f5442	482769.54	1	3	1	3	70.61	192.03	\N	\N	\N	\N	\N	2025-11-02 21:43:06.869741	2025-11-02 21:43:06.869741
23e7f4bc-4c23-497e-9ac1-99fe8435a321	off-plan	Milos	https://files.alnair.ae/uploads/2024/6/74/fa/74fab5ac3f369a218895c931241d01fb.jpg,https://files.alnair.ae/uploads/2024/6/4d/c2/4dc2fb5a426f42fdbbcf7f1836cc67a9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08382211	55.38374210	Off-plan property: Milos by Karma Development	38bcb8fc-3257-4311-90fa-8a5712e8ec0a	288276.48	1	1	1	2	81.18	92.13	\N	\N	\N	\N	\N	2025-11-02 21:43:06.871458	2025-11-02 21:43:06.871458
9d14ba03-23e0-426a-8fa3-a53a00ca879d	off-plan	Binghatti Apex	https://files.alnair.ae/uploads/2024/6/b7/7f/b77fde7cbb3704ea332fb8d76f7c75b0.jpg,https://files.alnair.ae/uploads/2024/7/3e/c8/3ec8cccaf4f16661313c5122c4269785.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06525017	55.20217493	Off-plan property: Binghatti Apex by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	229540.53	0	1	1	2	37.16	77.48	\N	\N	\N	\N	\N	2025-11-02 21:43:06.873074	2025-11-02 21:43:06.873074
73d4b8e1-004c-4b9b-b86c-c8263fc477c0	off-plan	Minati Homes	https://files.alnair.ae/uploads/2024/11/67/b3/67b3dc85dbccdd963849c220ae747a27.jpg,https://files.alnair.ae/uploads/2025/7/a5/a6/a5a6b2ce1523f6aebfc014342dd2b1ca.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03155829	55.13894386	Off-plan property: Minati Homes by Januss Developers	7fd8611b-101f-4330-8412-747e19f6a03a	329120.00	1	2	1	2	72.19	211.03	\N	\N	\N	\N	\N	2025-11-02 21:43:06.875629	2025-11-02 21:43:06.875629
5be09fc4-1749-42ce-b9d8-2f777bd48305	off-plan	Skyscape Aura	https://files.alnair.ae/uploads/2024/6/45/27/45274b8fc7d93be69d2fcbfe8326b2d0.jpg,https://files.alnair.ae/uploads/2024/6/d7/02/d702940ea201c242b0def6cf921e5dbc.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17229833	55.33022761	Off-plan property: Skyscape Aura by Sobha	5f637246-907f-4e44-9b90-7c3065602155	516062.88	1	3	1	3	75.88	189.12	\N	\N	\N	\N	\N	2025-11-02 21:43:06.877063	2025-11-02 21:43:06.877063
2eb2ee6b-35e3-4c4f-a5fd-014858a8acca	off-plan	Riva Residence	https://files.alnair.ae/uploads/2024/12/ca/84/ca84913ef0983c62c6c96e5b3f01cf38.jpg,https://files.alnair.ae/uploads/2024/11/c5/df/c5df232268ee23eb6f4da4213e4fdccb.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.26556934	55.27026559	Off-plan property: Riva Residence by Vakson First Property Development	7c89a325-c002-4997-bdce-842f3a4c1771	979200.00	2	3	2	3	138.80	287.16	\N	\N	\N	\N	\N	2025-11-02 21:43:06.879098	2025-11-02 21:43:06.879098
9018ad1e-d821-4c3c-893e-b6dbbfb71142	off-plan	Verve City Walk	https://files.alnair.ae/uploads/2024/6/32/3f/323ff61ba6d185295002c0ff7a7a37d1.jpg,https://files.alnair.ae/uploads/2024/6/41/7d/417d53d7f1b23d0e0f8a01be47b0a705.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20606200	55.26681754	Off-plan property: Verve City Walk by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	1224000.00	2	2	2	2	0.11	0.11	\N	\N	\N	\N	\N	2025-11-02 21:43:06.880717	2025-11-02 21:43:06.880717
ae2f5586-f0e0-4c15-ad35-ddf5418df006	off-plan	W Residences at Dubai Harbour	https://files.alnair.ae/uploads/2024/6/35/5a/355a66fac379dfd3f04f50461e42380a.jpg,https://files.alnair.ae/uploads/2024/6/69/07/6907ecdcb28b98d37f2d6a6206515c7d.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09183695	55.14334738	Off-plan property: W Residences at Dubai Harbour by ARADA	7d6bd1e9-574b-4682-b1b0-f6ef56f1dcae	1317840.00	1	5	1	5	99.31	713.68	\N	\N	\N	\N	\N	2025-11-02 21:43:06.882088	2025-11-02 21:43:06.882088
743a0243-bca2-4513-8fc0-ccbe974b7ba0	off-plan	Butterfly Towers	https://files.alnair.ae/uploads/2025/1/04/e1/04e18a6a19108f60aacefe7c10fd50bc.jpg,https://files.alnair.ae/uploads/2025/8/78/cb/78cb435d200c70681413303cec3daec0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06765300	55.24668753	Off-plan property: Butterfly Towers by Al Sayyah Group	b8f64de0-e740-47ce-9fd4-0acb0a1037ee	355987.34	1	2	1	2	78.36	132.86	\N	\N	\N	\N	\N	2025-11-02 21:43:06.884781	2025-11-02 21:43:06.884781
d15fb225-6e40-454d-865a-643f3802b5c9	off-plan	Elo 3	https://files.alnair.ae/uploads/2024/12/44/da/44da6d9c0a9d1c971e22eb44b93df6fb.jpg,https://files.alnair.ae/uploads/2024/6/68/1c/681c7cc584cfc24fe9f2b30c508dfe62.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98230517	55.39013934	Off-plan property: Elo 3 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	356592.00	2	2	2	2	90.03	109.90	\N	\N	\N	\N	\N	2025-11-02 21:43:06.886207	2025-11-02 21:43:06.886207
fe6aabac-88b3-453a-a524-4c102aac9394	off-plan	Vue By Crystal Bay	https://files.alnair.ae/uploads/2024/9/4f/bc/4fbcc18dc44f0ffdf0ccbba45eaa9e6f.jpg,https://files.alnair.ae/uploads/2024/9/b4/79/b47943a02b8affe18f27efea4597cef2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05352608	55.21236542	Off-plan property: Vue By Crystal Bay by Crystal Bay Development	9f67106b-4370-4084-b925-9c601f3c0deb	220320.00	0	2	1	2	45.89	183.76	\N	\N	\N	\N	\N	2025-11-02 21:43:06.888783	2025-11-02 21:43:06.888783
50ae25fd-9b34-43ac-8822-04a8271c32fa	off-plan	Sereno Residences	https://files.alnair.ae/uploads/2024/8/30/ad/30ad28389fa6250e1911518e78eb06e3.jpg,https://files.alnair.ae/uploads/2024/8/87/06/8706285d22ab16a8148c194fb2f6d85a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05989272	55.20969450	Off-plan property: Sereno Residences by Svarn Development	6a29a5e4-6067-4ba8-845d-498af9a81c79	319790.94	1	2	1	2	69.34	194.97	\N	\N	\N	\N	\N	2025-11-02 21:43:06.891405	2025-11-02 21:43:06.891405
fd3805de-ae77-4634-aadc-3650faf6c8df	off-plan	Parkside BLVD	https://files.alnair.ae/uploads/2024/5/89/ef/89ef2ca3a3f2415ce9883f7cf704761a.jpg,https://files.alnair.ae/uploads/2024/5/b1/8f/b18fe5c3ce002ff90b7b17b2a5f25814.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05953130	55.23718983	Off-plan property: Parkside BLVD by Tabeer	7d0313ac-b8a1-442a-a962-501f92b22c54	196656.00	0	2	1	2	42.18	158.86	\N	\N	\N	\N	\N	2025-11-02 21:43:06.892801	2025-11-02 21:43:06.892801
7bd8165a-6553-4855-ab9d-f0ca52edd4fd	off-plan	The Golf Place	https://files.alnair.ae/uploads/2024/5/78/a2/78a25635877b452de7b1a8c78d082723.jpg,https://files.alnair.ae/uploads/2025/7/da/56/da56095224b83313cfc64bf1ed2fc248.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03729302	55.22127025	Off-plan property: The Golf Place by Prestige One	9ac691dd-fc8e-4f5a-8a06-e72173cbc5ab	405552.00	1	3	1	3	90.71	185.04	\N	\N	\N	\N	\N	2025-11-02 21:43:06.894712	2025-11-02 21:43:06.894712
96a26791-bf02-4fc2-a887-a7deb049d901	off-plan	Marbella Resort Hotel	https://files.alnair.ae/uploads/2024/5/99/1f/991f0a980377000fb1dabaa95012c44e.jpg,https://files.alnair.ae/uploads/2024/5/3e/60/3e604b1bd410ecc1b0555ef0c49e2561.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.23123014	55.16087422	Off-plan property: Marbella Resort Hotel by The Heart of Europe	de44570c-141e-4809-a5a9-9dbc9556999c	784548.10	1	3	1	3	52.62	86.60	\N	\N	\N	\N	\N	2025-11-02 21:43:06.896802	2025-11-02 21:43:06.896802
398d1e5c-70aa-440e-8e24-5db9a775e2a5	off-plan	Me Do Re 2	https://files.alnair.ae/uploads/2024/7/73/45/734582baaaabe5ddb91382afca36f2dc.jpg,https://files.alnair.ae/uploads/2024/7/86/31/863106ea09dc0b77fc0c33b11953332d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07109383	55.14434315	Off-plan property: Me Do Re 2 by Me Do Re	5ef5c942-6e90-430d-b8ba-eb466d332c4d	340000.00	0	1	1	2	40.00	116.52	\N	\N	\N	\N	\N	2025-11-02 21:43:06.898622	2025-11-02 21:43:06.898622
16b59005-a531-4ba8-883f-c4519ce0d325	off-plan	Valores Residences	https://files.alnair.ae/uploads/2024/12/14/d3/14d3ef76e007375397eb0e29db8a209b.jpg,https://files.alnair.ae/uploads/2024/12/1d/f8/1df8434895a9fa5124136628033caa93.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01811385	55.12799710	Off-plan property: Valores Residences by Valores Property Development	a0e1ea1f-6442-4058-9b2f-0d2c038b516f	437335.20	2	2	2	2	93.74	289.11	\N	\N	\N	\N	\N	2025-11-02 21:43:06.900453	2025-11-02 21:43:06.900453
2c072724-a42c-46fd-8b7f-e46394fd9b65	off-plan	One B Tower	https://files.alnair.ae/uploads/2024/5/12/b0/12b05c8a914bdf13d52f859f04538d02.jpg,https://files.alnair.ae/uploads/2024/5/71/5c/715ccc8bf5c71d82630ff5e90d400216.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17958050	55.25220484	Off-plan property: One B Tower by Wasl	e0b7a2e8-0ba5-44cc-8ae0-f2450afb524a	695232.00	1	4	1	4	63.73	361.49	\N	\N	\N	\N	\N	2025-11-02 21:43:06.902427	2025-11-02 21:43:06.902427
451430d2-0ce5-4ce4-9005-f32933e66803	off-plan	Palatium Residences	https://files.alnair.ae/uploads/2024/6/86/ca/86caf8da3c6fe1bece3d832a2eb59f4a.png,https://files.alnair.ae/uploads/2024/6/72/d2/72d25baab95161c6e4c772bf42bb69f8.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05257722	55.20663209	Off-plan property: Palatium Residences by Ahmadyar Real Estate Development	e3027be7-b577-4695-abbe-4d676b3667ed	303924.37	1	2	1	2	71.54	120.08	\N	\N	\N	\N	\N	2025-11-02 21:43:06.904022	2025-11-02 21:43:06.904022
ba10157c-80eb-4978-ae0d-7d24c5a4f10f	off-plan	Skyscape Avenue	https://files.alnair.ae/uploads/2024/5/be/b0/beb05a1aae9d368a92c47ea49120d777.jpg,https://files.alnair.ae/uploads/2024/5/0b/fe/0bfe654636ec41994a5a8542dc49c22b.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17667579	55.32527305	Off-plan property: Skyscape Avenue by Sobha	5f637246-907f-4e44-9b90-7c3065602155	517648.10	1	3	1	3	78.58	191.62	\N	\N	\N	\N	\N	2025-11-02 21:43:06.905447	2025-11-02 21:43:06.905447
499083c3-e576-4225-9a2b-af341e6e731c	off-plan	One By Binghatti	https://files.alnair.ae/uploads/2024/5/78/d6/78d66ad1edc15f26212fe3fc24df695d.jpg,https://files.alnair.ae/uploads/2025/3/c4/47/c447f9d00f11a72abc3cb6fb1117d4af.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18371130	55.26369818	Off-plan property: One By Binghatti by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	409223.73	0	2	1	2	42.91	148.48	\N	\N	\N	\N	\N	2025-11-02 21:43:06.906918	2025-11-02 21:43:06.906918
1d4f941e-0175-4034-a93a-670a4e8baef1	off-plan	Tiger Sky Tower	https://files.alnair.ae/uploads/2024/5/e9/29/e929cc931d85f278931b8e81b10c4ab5.jpg,https://files.alnair.ae/uploads/2024/5/29/87/29879fa37d170894ebed0a234fdb6f95.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18731983	55.29255331	Off-plan property: Tiger Sky Tower by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	728192.96	1	4	1	4	81.12	276.26	\N	\N	\N	\N	\N	2025-11-02 21:43:06.908374	2025-11-02 21:43:06.908374
58f9eff9-4cf4-4948-8cb2-11033f7e5cb9	off-plan	The Atria	https://files.alnair.ae/uploads/2024/5/61/4d/614d85192cbddbb777895f5a3758801d.jpg,https://files.alnair.ae/uploads/2024/5/51/4b/514b699cb97065373436cebb851b837f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18018854	55.26390149	Off-plan property: The Atria by Deyaar	562c648e-bd2d-453f-83dc-6595824a64d8	372560.85	0	2	1	2	51.93	117.24	\N	\N	\N	\N	\N	2025-11-02 21:43:06.90983	2025-11-02 21:43:06.90983
f7146bca-b3a5-4608-ad4c-fdbf079472ca	off-plan	Jardin Astral	https://files.alnair.ae/uploads/2024/7/03/e5/03e518bda2ab20443e18c9d27a64479a.jpg,https://files.alnair.ae/uploads/2024/7/8a/3e/8a3ebf6197fe6c9beb1d21adfe8a06be.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22495484	55.27718157	Off-plan property: Jardin Astral by Galaxy Realty	514a33cd-4a28-4acd-a796-47147d8869cc	471920.00	1	2	1	2	72.56	89.09	\N	\N	\N	\N	\N	2025-11-02 21:43:06.911557	2025-11-02 21:43:06.911557
f0455cdf-f2d8-49d0-8cba-3f25063c36b4	off-plan	Altia One	https://files.alnair.ae/uploads/2024/12/dc/cc/dccc9e6806a1a66b69414899aa373f76.jpg,https://files.alnair.ae/uploads/2024/12/12/dc/12dc7ce55fe7a8b43192e0c7da52848e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10934091	55.38270436	Off-plan property: Altia One by Yas Developers	d590865e-aad9-42c8-b68e-c02693960240	383656.00	1	1	1	2	80.64	106.56	\N	\N	\N	\N	\N	2025-11-02 21:43:06.914411	2025-11-02 21:43:06.914411
b2ae5271-54f6-4f22-ba31-84c9a688b36f	off-plan	Kempinski Marina Residences	https://files.alnair.ae/uploads/2024/5/58/4c/584c8c0cf6516379671f7fa64a0a1bdd.jpg,https://files.alnair.ae/uploads/2024/5/44/9d/449d6d47de338b338ad4cf7ea3a5fc3c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08761228	55.14780422	Off-plan property: Kempinski Marina Residences by ABA Real Estate Development	a11dafe3-3354-4f2c-863b-1917905fd9f7	4655973.06	4	4	4	4	605.66	614.15	\N	\N	\N	\N	\N	2025-11-02 21:43:06.916077	2025-11-02 21:43:06.916077
64a1c03c-fa25-4fac-97cf-7cff99ce2665	off-plan	Tonino Lamborghini Residences	https://files.alnair.ae/uploads/2024/5/bc/26/bc26aba2f939d273fed49e7745c0f8e2.jpg,https://files.alnair.ae/uploads/2024/5/91/3a/913a32bfa5355eded8e6c424a78ced76.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.16096137	55.32625996	Off-plan property: Tonino Lamborghini Residences by Gulf Land Property Developers	032304fb-fc12-40e2-8ff8-bee6699c0b0d	684803.79	1	3	1	3	90.64	160.80	\N	\N	\N	\N	\N	2025-11-02 21:43:06.917693	2025-11-02 21:43:06.917693
447f6d4e-1439-4f55-8658-f4bd285df6c3	off-plan	Aqua Flora	https://files.alnair.ae/uploads/2024/5/b7/ea/b7eade3d8ebbbcdc41016dbdb8cc325f.jpg,https://files.alnair.ae/uploads/2024/5/9d/73/9d731fcce84143414640ec91f7ad1c92.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07296817	55.24779461	Off-plan property: Aqua Flora by Vincitore	3636d588-69e3-4d16-b9a8-725d1bdf8629	295120.00	0	3	1	3	44.92	208.82	\N	\N	\N	\N	\N	2025-11-02 21:43:06.91914	2025-11-02 21:43:06.91914
52a67992-8b84-427d-b394-85f3ad2bfac1	off-plan	Mangrove	https://files.alnair.ae/uploads/2024/5/2f/b4/2fb424013d3c61b6242df86df5937a23.jpg,https://files.alnair.ae/uploads/2025/4/53/e8/53e8245df408f86f5b48864d79d51b05.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20299481	55.35173088	Off-plan property: Mangrove by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1064305.54	3	3	3	3	149.85	158.03	\N	\N	\N	\N	\N	2025-11-02 21:43:06.920777	2025-11-02 21:43:06.920777
2232b575-ceb4-4445-9ff8-54aff38fff21	off-plan	Athlon	https://files.alnair.ae/uploads/2024/5/54/44/5444f337ba3d8972ad6b07ba056d1cb7.jpg,https://files.alnair.ae/uploads/2024/5/21/0c/210c1eed0a1cb2e6d9b68907c901632c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05862296	55.31110263	Off-plan property: Athlon by Aldar	cd0e36ac-7988-43f3-9aa0-b33902187156	3235345.07	1	3	1	3	156.57	313.14	\N	\N	\N	\N	\N	2025-11-02 21:43:06.922106	2025-11-02 21:43:06.922106
1259d9b0-e69a-4b92-b138-59ef7cec49d5	off-plan	Creek Views	https://files.alnair.ae/uploads/2024/7/12/10/1210219d8bc1986b6c7b6f8af4a83539.jpg,https://files.alnair.ae/uploads/2024/7/66/49/6649cdba31d77e52f3756ddf3d6f40e3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22994265	55.33673532	Off-plan property: Creek Views by Iraz Developments	6db578c9-b07e-4778-abc6-fb33ce70d277	527269.01	2	4	2	4	98.52	305.58	\N	\N	\N	\N	\N	2025-11-02 21:43:06.92315	2025-11-02 21:43:06.92315
4abf936c-a335-46bd-afe3-8b5b3d679ba0	off-plan	Coral By Vision	https://files.alnair.ae/uploads/2025/2/d8/d5/d8d51b56d0067678072f1f3020ce74f7.jpg,https://files.alnair.ae/uploads/2025/2/b6/94/b694fe5c8883f7ad57d5658f291e7d32.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22358875	55.27864471	Off-plan property: Coral By Vision by Vision developments	e155b5fb-b446-446a-b47d-90bc8f6d55d6	372096.00	0	2	1	2	64.38	181.63	\N	\N	\N	\N	\N	2025-11-02 21:43:06.924532	2025-11-02 21:43:06.924532
700f4bb9-8301-4834-b84b-4c943d1e2621	off-plan	DaVinci Tower	https://files.alnair.ae/uploads/2024/5/5f/e7/5fe7f628c6a8018f7040c25491b5d127.jpg,https://files.alnair.ae/uploads/2024/5/1d/fb/1dfb1c914208ed3f431721d22454ee60.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18600789	55.28335590	Off-plan property: DaVinci Tower by DarGlobal	4b39b795-8d4c-4141-b0e7-2d6e9a8ba72f	1893418.93	1	4	1	4	181.67	428.71	\N	\N	\N	\N	\N	2025-11-02 21:43:06.925999	2025-11-02 21:43:06.925999
6e838a95-21ee-4bf3-9ca7-5970e79e811b	off-plan	Jade Tower	https://files.alnair.ae/uploads/2024/4/cb/f9/cbf9c123b7500372a178162ca183ec3c.jpg,https://files.alnair.ae/uploads/2024/4/bb/a7/bba781a04735c9be2fefebac69d71401.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08634996	55.31522347	Off-plan property: Jade Tower by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	267087.68	1	2	1	2	69.11	122.52	\N	\N	\N	\N	\N	2025-11-02 21:43:06.92761	2025-11-02 21:43:06.92761
dd5c3c23-3401-4e8d-afa3-751ae637a793	off-plan	LUM1NAR	https://files.alnair.ae/uploads/2024/4/58/74/5874808b8be51ae3cbcbf3cdd9f2a011.jpg,https://files.alnair.ae/uploads/2024/4/ab/f8/abf81ee266dd2c1f3dce6fcfd3bf6eb3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03689091	55.17890766	Off-plan property: LUM1NAR by Object One	9d128f32-1c6c-474d-b911-61803444decc	228785.18	0	2	1	2	51.41	184.67	\N	\N	\N	\N	\N	2025-11-02 21:43:06.929279	2025-11-02 21:43:06.929279
4b1b1899-2930-4f1c-b9bc-2dc4c54d875f	off-plan	Damac Lagoon Views 11	https://files.alnair.ae/uploads/2024/4/a1/40/a140ba33f48827a586f90fc5f938f173.jpg,https://files.alnair.ae/uploads/2024/4/53/04/5304c6ab26897ee9d8e642a6336d34f3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01710881	55.23921289	Off-plan property: Damac Lagoon Views 11 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	662048.00	2	2	2	2	140.43	166.94	\N	\N	\N	\N	\N	2025-11-02 21:43:06.931718	2025-11-02 21:43:06.931718
27116770-c909-47d6-affa-42c0bebc735f	off-plan	Sea View Residence	https://files.alnair.ae/uploads/2025/5/b8/01/b801e2885d29ac29aaa929e38a236002.jpg,https://files.alnair.ae/uploads/2024/8/66/62/6662afc1dec53c59e89ef0e41d1af001.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29940252	55.31398066	Off-plan property: Sea View Residence by Sama Ezdan	5d91183a-b2e6-4072-95fd-a408857cd44c	607376.00	1	2	1	2	92.07	141.03	\N	\N	\N	\N	\N	2025-11-02 21:43:06.933574	2025-11-02 21:43:06.933574
8d8b9472-9bcb-4d37-b800-6ed21ef6d9c2	off-plan	Port De La Mer - Le Pont	https://files.alnair.ae/uploads/2024/7/76/f5/76f57dc00ab49c1277aeb9afb62ff765.jpg,https://files.alnair.ae/uploads/2024/7/f3/27/f32741bd617ff2cf05c2f68d26659fb0.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.23943314	55.25118023	Off-plan property: Port De La Mer - Le Pont by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	802400.00	1	1	1	2	77.76	77.76	\N	\N	\N	\N	\N	2025-11-02 21:43:06.93507	2025-11-02 21:43:06.93507
53f0d6f6-7c5f-46bd-b9dd-586c34e5d5aa	off-plan	Port De La Mer - La Cote	https://files.alnair.ae/uploads/2024/7/6c/77/6c7740a4694aedffc19c5567289fd411.jpg,https://files.alnair.ae/uploads/2024/7/99/dd/99dd3e58fa650ea48e7db9357808f153.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.24031079	55.25277212	Off-plan property: Port De La Mer - La Cote by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	680000.00	1	1	1	2	73.67	73.67	\N	\N	\N	\N	\N	2025-11-02 21:43:06.937587	2025-11-02 21:43:06.937587
03449b24-2730-41b5-a97b-ac36da40648c	off-plan	Six Senses Residences Marina	https://files.alnair.ae/uploads/2024/4/e4/25/e425da9d699fb0d299cf1031660f810d.jpg,https://files.alnair.ae/uploads/2025/2/ce/21/ce21e257332a9b22e3fdd99e27549a72.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08931310	55.15027955	Off-plan property: Six Senses Residences Marina by Select Group	e5e2dd29-98f2-4191-8f60-5eb6dc3cad47	2815472.00	4	5	4	5	308.22	1310.16	\N	\N	\N	\N	\N	2025-11-02 21:43:06.94041	2025-11-02 21:43:06.94041
3d9f75e5-c837-420f-b3d1-bc951d5657fc	off-plan	Q Gardens Aliya	https://files.alnair.ae/uploads/2024/10/59/fc/59fccf94a3771bf6cef1c211213f260d.jpg,https://files.alnair.ae/uploads/2025/5/a0/2a/a02a93da9ea5d3e2fa47ab22dd06de50.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05122682	55.21626810	Off-plan property: Q Gardens Aliya by AYS Property Development	3323282f-72a8-48b7-a6c2-8d6380bb0973	438833.92	1	1	1	2	74.94	121.13	\N	\N	\N	\N	\N	2025-11-02 21:43:06.942105	2025-11-02 21:43:06.942105
6aeca256-2aaf-4ed1-8cc7-b494281a4cb6	off-plan	Binghatti Hills	https://files.alnair.ae/uploads/2024/4/6c/80/6c80be39f546dd03a22856bd91627c9c.jpg,https://files.alnair.ae/uploads/2025/3/c5/43/c5434ae993023f62482c481821de949f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07108518	55.24885139	Off-plan property: Binghatti Hills by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	235108.37	0	2	1	2	41.43	165.58	\N	\N	\N	\N	\N	2025-11-02 21:43:06.943726	2025-11-02 21:43:06.943726
5d611427-2cd3-4d30-9c3a-6bf904eac2e5	off-plan	Verdana 4	https://files.alnair.ae/uploads/2024/4/c2/10/c2108d1590435d5636f6b1545179cd5b.jpg,https://files.alnair.ae/uploads/2025/10/eb/18/eb18ef31bb52c0e0f95810e906eeb46a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.99506667	55.17550564	Off-plan property: Verdana 4 by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	620743.71	1	3	1	3	762.96	1525.91	\N	\N	\N	\N	\N	2025-11-02 21:43:06.945265	2025-11-02 21:43:06.945265
221d8284-9b51-4169-bde9-da6f574288a0	off-plan	Beach Oasis 2	https://files.alnair.ae/uploads/2024/4/ff/48/ff4807780f637bf022ec28f3f49a4461.jpg,https://files.alnair.ae/uploads/2024/4/96/8b/968bbb20457bcc44d17bda3df8854b59.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03567208	55.23630882	Off-plan property: Beach Oasis 2 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	261664.00	1	2	1	2	58.25	99.13	\N	\N	\N	\N	\N	2025-11-02 21:43:06.946052	2025-11-02 21:43:06.946052
f5f66a0a-ecd1-487d-8903-6b5b15a1ef42	off-plan	Riviera 69	https://files.alnair.ae/uploads/2024/7/84/00/840076ec3703ccc9ffeb3ed9241d9d44.png,https://files.alnair.ae/uploads/2024/7/62/68/6268515f8fbd827613584e2dde467081.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17212484	55.31480876	Off-plan property: Riviera 69 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	380800.00	0	2	1	2	28.27	115.94	\N	\N	\N	\N	\N	2025-11-02 21:43:06.947674	2025-11-02 21:43:06.947674
c2e29ef4-04da-4baa-98d5-de67147a84ef	off-plan	Diamondz	https://files.alnair.ae/uploads/2024/12/d2/a4/d2a4e27be64bbbbdad2303d5191b65cd.jpg,https://files.alnair.ae/uploads/2024/4/e5/38/e538268ce1a13de8768c9790ddd3b87f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06399159	55.14094681	Off-plan property: Diamondz by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	514080.00	1	4	1	4	69.30	183.27	\N	\N	\N	\N	\N	2025-11-02 21:43:06.949299	2025-11-02 21:43:06.949299
427a88c1-805a-49dc-9ecb-f7293f159a5d	off-plan	Valo	https://files.alnair.ae/uploads/2024/4/be/8c/be8c9c1fa1105a8b9ede4dc54cf6d06e.jpg,https://files.alnair.ae/uploads/2025/2/c4/cc/c4cca688764daf796207075c8b16901a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20820763	55.35236388	Off-plan property: Valo by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1181265.54	3	3	3	3	168.15	168.15	\N	\N	\N	\N	\N	2025-11-02 21:43:06.950874	2025-11-02 21:43:06.950874
21f070d3-6012-44c2-8296-fa26afe87299	off-plan	The Waterway	https://files.alnair.ae/uploads/2024/4/fb/c6/fbc6cede046fd928dafdaa6333910742.jpg,https://files.alnair.ae/uploads/2025/3/a0/d2/a0d2de37cd2f9594b41cad4526ea8839.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18143334	55.32785927	Off-plan property: The Waterway by Prestige One	9ac691dd-fc8e-4f5a-8a06-e72173cbc5ab	497760.00	1	2	1	2	104.89	313.18	\N	\N	\N	\N	\N	2025-11-02 21:43:06.952243	2025-11-02 21:43:06.952243
00e3e3f3-ed20-4912-b855-a409c45fbfc3	off-plan	Casa Vista Residence	https://files.alnair.ae/uploads/2024/6/ee/99/ee995bb690a61f0aa3c9a024353ae0a3.jpg,https://files.alnair.ae/uploads/2025/5/3a/62/3a62e14e15322d2c7397a28fa70cbb92.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05167673	55.21577297	Off-plan property: Casa Vista Residence by Casa Vista & Golden Woods Developers	473bcd76-c441-4ac5-b6de-b68468c54b34	284494.32	1	1	1	2	64.37	98.09	\N	\N	\N	\N	\N	2025-11-02 21:43:06.954814	2025-11-02 21:43:06.954814
dd5b2fc1-2d53-4d7f-8fb7-2d6332f274b9	off-plan	Four Seasons Private Residences  - DIFC	https://files.alnair.ae/uploads/2024/4/f7/70/f770cc7b1585eb4b98e72f9588db8970.jpg,https://files.alnair.ae/uploads/2024/4/79/f6/79f6b08e8af395f737ef238a09f859f4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21092311	55.27929034	Off-plan property: Four Seasons Private Residences  - DIFC by H&H Development	b9e3db1f-eda1-44b1-8332-62be8b825be8	19948318.98	4	5	4	5	747.12	934.99	\N	\N	\N	\N	\N	2025-11-02 21:43:06.95622	2025-11-02 21:43:06.95622
c8d2c053-e9cc-4cd0-b6a6-8a9e6fc3c14c	off-plan	Century	https://files.alnair.ae/uploads/2024/4/76/a6/76a6f13e8ea51669cb86ffab846b588c.jpg,https://files.alnair.ae/uploads/2024/4/cc/6f/cc6fc99b350312fc2b57066193750257.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18556400	55.29307958	Off-plan property: Century by AMBS Real Estate Development	31f110a8-7428-43b4-a91e-ab7e13c58595	272000.00	0	0	1	2	36.88	36.88	\N	\N	\N	\N	\N	2025-11-02 21:43:06.957901	2025-11-02 21:43:06.957901
b575d3d5-0804-4686-8c69-8e7af51142fd	off-plan	MAG City Townhouses	https://files.alnair.ae/uploads/2024/4/95/2c/952c9ba38bcaada1e8e0496d0d90d5ed.jpg,https://files.alnair.ae/uploads/2024/4/d9/39/d939ac84a6a1435a748dc08e68666d20.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14173706	55.28543449	Off-plan property: MAG City Townhouses by MAG Property Development	d5dfad6f-2582-4be3-89ae-c5625e33a996	775200.00	1	3	1	3	1.75	3.50	\N	\N	\N	\N	\N	2025-11-02 21:43:06.959267	2025-11-02 21:43:06.959267
6324cfaf-aef9-474e-ba05-3d04b16bcc71	off-plan	Damac Hills 2 - Victoria	https://files.alnair.ae/uploads/2024/4/91/45/9145b49f2a489b58a0b2abf9d832643a.jpg,https://files.alnair.ae/uploads/2024/4/75/c2/75c27bca526d8181eeae1b91f02b9246.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98156511	55.38301862	Off-plan property: Damac Hills 2 - Victoria by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	448800.00	1	3	1	3	1.77	3.54	\N	\N	\N	\N	\N	2025-11-02 21:43:06.959972	2025-11-02 21:43:06.959972
5f41a46a-7770-4e86-9802-16d549a09f0d	off-plan	Elo 2	https://files.alnair.ae/uploads/2024/3/7b/3e/7b3e68ce355396719ec29026f1803e95.jpg,https://files.alnair.ae/uploads/2024/3/ce/ca/cecafbfb55d58d71dc0e21a25aac108c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98268925	55.39075977	Off-plan property: Elo 2 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	356864.00	2	2	2	2	90.25	109.90	\N	\N	\N	\N	\N	2025-11-02 21:43:06.960707	2025-11-02 21:43:06.960707
62331e02-44fe-4a9d-9f3a-fc3e6ba2602c	off-plan	Opal Gardens	https://files.alnair.ae/uploads/2024/3/d9/18/d9182e89d20e225abb3048f179524700.jpg,https://files.alnair.ae/uploads/2024/3/ab/9a/ab9aecdf07ea3457b64b49fca44ad551.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12791811	55.33899307	Off-plan property: Opal Gardens by Nakheel	d190bf02-5336-42e6-bba1-91ee1ab4b2d5	2176000.00	1	3	1	3	4.06	8.13	\N	\N	\N	\N	\N	2025-11-02 21:43:06.962566	2025-11-02 21:43:06.962566
14b4a9a4-7389-4209-b5ff-d5fc94ca5203	off-plan	Rixos Dubai Islands	https://files.alnair.ae/uploads/2024/3/84/4d/844d8a99773b191c8ff3ef21233ef17f.jpg,https://files.alnair.ae/uploads/2024/3/45/7e/457ee08357b26f9cd8c4370e95b7d60a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.30457049	55.31382859	Off-plan property: Rixos Dubai Islands by Nakheel	d190bf02-5336-42e6-bba1-91ee1ab4b2d5	829600.00	1	2	1	2	156.91	1216.00	\N	\N	\N	\N	\N	2025-11-02 21:43:06.96343	2025-11-02 21:43:06.96343
d559c7a4-fb68-4d5e-87d7-c5c2e4aa15c3	off-plan	Rivana The Valley	https://files.alnair.ae/uploads/2024/3/72/55/7255964f14a85978e071401dd6d41038.jpg,https://files.alnair.ae/uploads/2025/3/36/28/36284bc2d99415f086cd11d052462c01.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00845200	55.45518637	Off-plan property: Rivana The Valley by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1156000.00	1	3	1	3	1695.58	3391.15	\N	\N	\N	\N	\N	2025-11-02 21:43:06.964877	2025-11-02 21:43:06.964877
2bea7d8b-dae2-4c83-8b78-2f213e334b0b	off-plan	Jewel	https://files.alnair.ae/uploads/2024/3/23/e0/23e0fccb4024a4618489ba1831a9e368.jpg,https://files.alnair.ae/uploads/2024/3/19/78/197830d52d310c939b541a27f65c6a55.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01813693	55.12750424	Off-plan property: Jewel by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	311168.00	1	1	1	2	64.47	104.79	\N	\N	\N	\N	\N	2025-11-02 21:43:06.965605	2025-11-02 21:43:06.965605
2cd98180-0630-4747-934f-c52b91c16c34	off-plan	Elo	https://files.alnair.ae/uploads/2024/3/69/dd/69dd840389622257b0aa9c13907a11c3.jpg,https://files.alnair.ae/uploads/2024/3/9b/c2/9bc253a3bb9506269fe0e9cf09450ca3.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98353900	55.39220005	Off-plan property: Elo by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	369376.00	2	2	2	2	91.10	96.98	\N	\N	\N	\N	\N	2025-11-02 21:43:06.967139	2025-11-02 21:43:06.967139
e07a2535-76e2-46d9-82a5-f096216ba859	off-plan	Electra	https://files.alnair.ae/uploads/2024/3/89/ec/89ec27949a279007ac64def0d32df867.jpg,https://files.alnair.ae/uploads/2025/5/56/2f/562f0002a4404747f73f2a3b1cae528c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04595500	55.20473084	Off-plan property: Electra by Acube Developers	f937a811-2827-40a6-a476-25e4dc248127	254579.22	0	3	1	3	48.12	159.33	\N	\N	\N	\N	\N	2025-11-02 21:43:06.968532	2025-11-02 21:43:06.968532
1f4c75a4-ad98-40ff-aff6-ce6b83f4fb70	off-plan	THE F1FTH	https://files.alnair.ae/uploads/2024/3/83/62/8362b44acc370bf21bd8b7d1883f2ffb.png,https://files.alnair.ae/uploads/2024/3/1a/16/1a16b797df04a3068cfeab4ebe3c9376.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06989972	55.20709544	Off-plan property: THE F1FTH by Object One	9d128f32-1c6c-474d-b911-61803444decc	358165.79	1	1	1	2	78.57	127.99	\N	\N	\N	\N	\N	2025-11-02 21:43:06.970016	2025-11-02 21:43:06.970016
d75427bf-7eaf-43d7-a50d-2da21a1c6752	off-plan	Karl Lagerfeld Villas	https://files.alnair.ae/uploads/2024/12/d6/c3/d6c3c9a3637e92bf0baae2b3ae984a65.jpg,https://files.alnair.ae/uploads/2024/3/1d/af/1daf3af63dd23642faa7dc9c3666b370.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13075776	55.34377329	Off-plan property: Karl Lagerfeld Villas by Taraf	a5fa31f8-5b72-4718-a5d1-2c22a14d0782	5013136.80	1	3	1	3	677.22	1354.44	\N	\N	\N	\N	\N	2025-11-02 21:43:06.97139	2025-11-02 21:43:06.97139
1a9fe80c-6f29-4375-baed-aad427bba73a	off-plan	Seaside	https://files.alnair.ae/uploads/2024/9/af/76/af766da330588334fd8d48fe0d183ef8.jpg,https://files.alnair.ae/uploads/2024/3/24/ea/24ea4771ee0b5e8484ab1716bf3dc86c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29225624	55.30199693	Off-plan property: Seaside by Prestige One	9ac691dd-fc8e-4f5a-8a06-e72173cbc5ab	701760.00	2	3	2	3	64.72	226.91	\N	\N	\N	\N	\N	2025-11-02 21:43:06.972115	2025-11-02 21:43:06.972115
1395be26-55c0-4ac2-b33f-15a094116e4d	off-plan	Muraba Veil	https://files.alnair.ae/uploads/2024/12/21/b7/21b7539fecfd393fb267ba4530e6b097.png,https://files.alnair.ae/uploads/2024/3/50/d7/50d7188141f767e5061130d123bdc165.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18694117	55.25355155	Off-plan property: Muraba Veil by Muraba Properties	7476b6f6-9c5d-44f4-80e2-f254031f4964	3420729.66	2	4	2	4	356.56	1424.48	\N	\N	\N	\N	\N	2025-11-02 21:43:06.974191	2025-11-02 21:43:06.974191
6f2117f3-4299-47e4-8831-5a62e5c9b2d1	off-plan	Binghatti Phoenix	https://files.alnair.ae/uploads/2024/3/18/7c/187cadb784e7bbe81a7b2e52deec7a59.jpg,https://files.alnair.ae/uploads/2025/3/ed/51/ed51e84a818763b1d4ccfd77f4de5331.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04881026	55.21054745	Off-plan property: Binghatti Phoenix by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	320960.00	1	1	1	2	75.32	391.20	\N	\N	\N	\N	\N	2025-11-02 21:43:06.975734	2025-11-02 21:43:06.975734
785b6bec-6266-486f-a23c-59b27bb3487d	off-plan	Binghatti Avenue	https://files.alnair.ae/uploads/2024/7/42/bf/42bfb9122f18ae7f1f39b9d7d9fd0c80.jpg,https://files.alnair.ae/uploads/2025/5/df/8c/df8cdd478608b977bfcce53fe7dba56e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21228284	55.31614906	Off-plan property: Binghatti Avenue by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	564400.00	3	3	3	3	132.39	132.39	\N	\N	\N	\N	\N	2025-11-02 21:43:06.977239	2025-11-02 21:43:06.977239
2b705d9c-5fe9-459b-adad-a62574dccdd0	off-plan	Vivanti Residences	https://files.alnair.ae/uploads/2024/2/66/9b/669bec310c5cf0e5af33828a87f7faf4.jpg,https://files.alnair.ae/uploads/2025/4/db/28/db2811049517ec38b380dcf40dbcaea4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06015514	55.20919900	Off-plan property: Vivanti Residences by Meteora	fb4692a7-86dc-4258-85b6-c25bebac8361	202368.00	0	3	1	3	41.53	334.10	\N	\N	\N	\N	\N	2025-11-02 21:43:06.980288	2025-11-02 21:43:06.980288
d6e15b10-cb7e-4bbd-9df4-c60e05cf4679	off-plan	Eleve	https://files.alnair.ae/uploads/2024/2/4a/1a/4a1a975f331faf0c2c849e5764e0907e.jpg,https://files.alnair.ae/uploads/2024/2/23/df/23df004bfefb30fa0999448c245def8a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.97887698	55.09328750	Off-plan property: Eleve by Deyaar	562c648e-bd2d-453f-83dc-6595824a64d8	402496.62	2	3	2	3	99.59	273.69	\N	\N	\N	\N	\N	2025-11-02 21:43:06.981837	2025-11-02 21:43:06.981837
5d8b1ae3-3780-45d1-af97-04a2bfa4748a	off-plan	The 100	https://files.alnair.ae/uploads/2024/2/83/76/8376d17147cc6f2d9203cd0743483931.jpg,https://files.alnair.ae/uploads/2024/2/f7/b6/f7b6f7a77b253a3b655ca38beeccda57.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.15445653	55.28954241	Off-plan property: The 100 by The 100	723ce433-e943-43c4-b416-25e3cac11fdc	3400000.00	4	4	4	4	398.78	398.78	\N	\N	\N	\N	\N	2025-11-02 21:43:06.983643	2025-11-02 21:43:06.983643
d23aa050-f9bc-4cf8-b12d-171f95e697e3	off-plan	Sonate Residences	https://files.alnair.ae/uploads/2024/2/9e/51/9e510594512ca491e951b583ffbd2213.jpg,https://files.alnair.ae/uploads/2024/2/eb/0e/eb0e4b4ca5d317e41639f0956efcf520.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04025779	55.18422157	Off-plan property: Sonate Residences by Condor	552c1026-d364-4ea2-95ff-65710cce5b5d	345029.55	1	3	1	3	78.67	214.42	\N	\N	\N	\N	\N	2025-11-02 21:43:06.985115	2025-11-02 21:43:06.985115
74f11e0f-2589-4361-a5e8-d3898f2e3842	off-plan	Lucky Oasis Residence	https://files.alnair.ae/uploads/2024/3/b9/3c/b93cf172c55acca9dc7fbbfcb038b637.jpg,https://files.alnair.ae/uploads/2024/3/bc/47/bc47f31c23cd773dbb8759e063dd9552.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05193695	55.21441184	Off-plan property: Lucky Oasis Residence by Lucky Aeon	36e9f280-55ae-417d-9730-075feb51ed84	188223.73	0	3	1	3	39.67	187.57	\N	\N	\N	\N	\N	2025-11-02 21:43:06.986837	2025-11-02 21:43:06.986837
e8ad58cf-0812-4ee7-963e-a58740ad0969	off-plan	WADI Villas	https://files.alnair.ae/uploads/2024/2/61/c6/61c6cdb0d7c40b3680ef0cb39ede9266.jpg,https://files.alnair.ae/uploads/2024/2/56/3e/563e6170647bf6ecb5abea1ae2a26a13.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12558202	55.34446746	Off-plan property: WADI Villas by Arista Properties	1ff4a488-52a3-4779-aa13-8aa0a6651aa6	4007824.80	1	3	1	3	262.79	525.57	\N	\N	\N	\N	\N	2025-11-02 21:43:06.988702	2025-11-02 21:43:06.988702
08f32391-146d-4ad2-b7ef-a4076754a032	off-plan	The Alba Residences	https://files.alnair.ae/uploads/2024/5/66/e4/66e447a75e150b14cd901c225cccf691.jpg,https://files.alnair.ae/uploads/2024/9/b8/99/b89906b91054dab2ae83924aa78744e6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14023300	55.13981760	Off-plan property: The Alba Residences by Omniyat	6e10dff0-abd2-49b5-9c98-71ec8f1b446f	4705600.00	2	4	2	4	147.90	1393.55	\N	\N	\N	\N	\N	2025-11-02 21:43:06.989534	2025-11-02 21:43:06.989534
6e88156c-b2a3-40c8-b00d-50d3ccb57ef3	off-plan	99 Parkplace	https://files.alnair.ae/uploads/2024/2/32/3b/323b51cd4d818b5a35a49aa68ec3da37.jpg,https://files.alnair.ae/uploads/2024/2/06/ff/06ffc6df148ff35b4affb8d005468e3f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05149939	55.20586412	Off-plan property: 99 Parkplace by Tabeer	7d0313ac-b8a1-442a-a962-501f92b22c54	488784.00	2	2	2	2	120.50	137.96	\N	\N	\N	\N	\N	2025-11-02 21:43:06.991034	2025-11-02 21:43:06.991034
9819f75e-a921-42d8-8220-7a3199d39282	off-plan	Regent Residences Dubai – Sankari Place	https://files.alnair.ae/uploads/2024/2/59/44/594481fc85f9ac1c88f885a487f076f0.jpg,https://files.alnair.ae/uploads/2024/9/01/73/0173b8a8be7c8d254a610c73b3ee7a5f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18752219	55.28650382	Off-plan property: Regent Residences Dubai – Sankari Place by Sankari Property	85f34ca0-84b8-4638-a6c5-2e55353e9f8d	10744000.00	3	5	3	5	678.19	975.48	\N	\N	\N	\N	\N	2025-11-02 21:43:06.992707	2025-11-02 21:43:06.992707
089ae4fa-2d7b-4e78-8103-f8b76e35675f	off-plan	Hatimi Residences	https://files.alnair.ae/uploads/2024/2/81/e9/81e968eaa5714e43a861017fd34edc80.jpg,https://files.alnair.ae/uploads/2024/5/60/a7/60a718da6f8cc5327c65878e74a56ef0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29185757	55.29138118	Off-plan property: Hatimi Residences by Fakhruddin Properties	7aa8d80f-f1da-438b-a8ac-a57d0b201cd8	2420800.00	3	4	3	4	235.14	426.50	\N	\N	\N	\N	\N	2025-11-02 21:43:06.994544	2025-11-02 21:43:06.994544
f3d5a05b-f385-40ed-8e3a-7d99b9b0dc68	off-plan	Bay Villas Dubai Islands	https://files.alnair.ae/uploads/2024/2/97/2f/972f3c7887a38827caaa0f1d7f47f406.jpg,https://files.alnair.ae/uploads/2024/2/21/24/2124397fb7a8e1b059a3c261cc353112.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.31909850	55.32674600	Off-plan property: Bay Villas Dubai Islands by Nakheel	d190bf02-5336-42e6-bba1-91ee1ab4b2d5	2937600.00	1	3	1	3	6.35	12.69	\N	\N	\N	\N	\N	2025-11-02 21:43:06.996249	2025-11-02 21:43:06.996249
40d7d56b-b5b9-4e8f-8257-e683ffc0281d	off-plan	Safa Gate	https://files.alnair.ae/uploads/2025/1/26/2d/262d13b90c7660805a63a576ca3d7fe0.png,https://files.alnair.ae/uploads/2025/1/5c/3e/5c3e3080d6753e580f3162ecafb69206.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18295506	55.25025219	Off-plan property: Safa Gate by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	326400.00	0	3	1	3	36.45	291.87	\N	\N	\N	\N	\N	2025-11-02 21:43:06.997046	2025-11-02 21:43:06.997046
25bfa7c7-a680-48dc-9e55-7676be0705ba	off-plan	Enaya Residences	https://files.alnair.ae/uploads/2024/9/68/aa/68aaf38d577038a88bb343aea8db1ddb.jpg,https://files.alnair.ae/uploads/2024/9/8f/6d/8f6d1a7b36e21f80cb1c441cd3d6803a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04000141	55.18184312	Off-plan property: Enaya Residences by DV8 Developers	11f94184-adb1-4ac0-b41e-0fa99203b5ed	280704.00	1	2	1	2	64.47	127.74	\N	\N	\N	\N	\N	2025-11-02 21:43:06.998536	2025-11-02 21:43:06.998536
c7b63b0a-d1f6-4508-94e3-0ab73888d0d4	off-plan	Kaya	https://files.alnair.ae/uploads/2024/2/29/9e/299e1a2ce52989445227fb9954b99352.jpg,https://files.alnair.ae/uploads/2024/2/b5/9e/b59eb2cadb346db64c38e4c4011c5f59.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00536982	55.28613209	Off-plan property: Kaya by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	197441.54	1	2	1	2	57.60	94.58	\N	\N	\N	\N	\N	2025-11-02 21:43:07.000027	2025-11-02 21:43:07.000027
fbc8877a-5e32-447a-9994-6d811684cbe3	off-plan	Binghatti Phantom	https://files.alnair.ae/uploads/2024/2/78/0e/780eccc78c912b89ee4885e744d1cdb3.jpg,https://files.alnair.ae/uploads/2025/5/95/a9/95a92530c6d81c461f11c8949e0036ba.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05938684	55.21685047	Off-plan property: Binghatti Phantom by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	481440.00	1	1	1	2	84.82	84.82	\N	\N	\N	\N	\N	2025-11-02 21:43:07.001511	2025-11-02 21:43:07.001511
4d3351e1-b366-4a7c-8c48-2bcf11d69c64	off-plan	One Park Central	https://files.alnair.ae/uploads/2024/3/10/cc/10cc169d8d91b77bd1efe9e838406f73.jpg,https://files.alnair.ae/uploads/2024/2/a4/5b/a45b0b7b015fea608fb43d521d82842d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05570400	55.20262971	Off-plan property: One Park Central by Iman Developers	6ad5348a-4fe7-4ee9-b98b-aa545a89e019	208351.46	0	0	1	2	35.76	36.14	\N	\N	\N	\N	\N	2025-11-02 21:43:07.002923	2025-11-02 21:43:07.002923
5eef52ac-c863-4097-8fd0-3daf9dce928a	off-plan	W1NNER	https://files.alnair.ae/uploads/2024/2/e7/f3/e7f3eaf22c536389d8f23b997d4cf291.png,https://files.alnair.ae/uploads/2025/5/66/3b/663b9fab1759620dde20a964b4183bf6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04342600	55.19417055	Off-plan property: W1NNER by Object One	9d128f32-1c6c-474d-b911-61803444decc	356053.17	1	2	1	2	79.85	192.46	\N	\N	\N	\N	\N	2025-11-02 21:43:07.004394	2025-11-02 21:43:07.004394
0cd91901-3da6-44d7-b79a-34b335c2e667	off-plan	SquareX Residence	https://files.alnair.ae/uploads/2024/3/13/3b/133b94aa2be7e5b95f0875059af3dc7a.jpg,https://files.alnair.ae/uploads/2024/3/4d/76/4d76e19bdd85135492e02c71d924744f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05997655	55.20439044	Off-plan property: SquareX Residence by Tasmeer Indigo Properties	a90315f8-75de-4e44-bd69-d890cae817b0	308949.57	1	1	1	2	73.95	77.26	\N	\N	\N	\N	\N	2025-11-02 21:43:07.00578	2025-11-02 21:43:07.00578
147e02ad-5a54-4dc6-9160-b582069cd05c	off-plan	Empire Estates	https://files.alnair.ae/uploads/2024/2/87/15/8715771b7104b4521fd45e2d54adfb78.jpg,https://files.alnair.ae/uploads/2024/2/82/3a/823afc87e842a76cf71872f74ea435dd.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05837535	55.23641746	Off-plan property: Empire Estates by Empire Developments	a45adfa1-9f07-48ed-a4d3-ba8f0d2021cd	622608.00	1	3	1	3	59.92	102.89	\N	\N	\N	\N	\N	2025-11-02 21:43:07.007191	2025-11-02 21:43:07.007191
60f7594e-c5cf-40ac-986b-d652b639d5fd	off-plan	Rove Home Marasi Drive	https://files.alnair.ae/uploads/2024/2/eb/4d/eb4d612309ca303c2ebc619c46472c26.jpg,https://files.alnair.ae/uploads/2024/2/0e/f0/0ef08056cfedcf679f4542325900358a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18123564	55.27507324	Off-plan property: Rove Home Marasi Drive by Irth Development	f62d2c43-fdd2-42ca-a285-58271ad51d03	356536.78	0	2	1	2	37.25	98.29	\N	\N	\N	\N	\N	2025-11-02 21:43:07.008784	2025-11-02 21:43:07.008784
70954d3b-b3ff-4549-9728-1cdca4e6eaf5	off-plan	Sobha Orbis	https://files.alnair.ae/uploads/2024/3/5d/59/5d594ac66532b6b6a9849c43899f17ca.jpg,https://files.alnair.ae/uploads/2024/4/d9/3d/d93dff2ed17130bec7e41987566d23a4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04946633	55.24908003	Off-plan property: Sobha Orbis by Sobha	5f637246-907f-4e44-9b90-7c3065602155	481060.02	1	2	1	2	77.14	116.27	\N	\N	\N	\N	\N	2025-11-02 21:43:07.010186	2025-11-02 21:43:07.010186
365ac6a3-c8e4-4f19-8931-e2122c8e088e	off-plan	Keturah Resort	https://files.alnair.ae/uploads/2024/12/51/37/51378c86278488b1ed49b4c6dea838de.jpg,https://files.alnair.ae/uploads/2024/2/99/c5/99c5a12c82485be6112e1abb51fa621f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20707674	55.31898916	Off-plan property: Keturah Resort by MAG Property Development	d5dfad6f-2582-4be3-89ae-c5625e33a996	92663600.00	1	3	1	3	613.56	1227.13	\N	\N	\N	\N	\N	2025-11-02 21:43:07.011533	2025-11-02 21:43:07.011533
563af705-9eaa-415d-bed1-9d2f8d8617da	off-plan	Rixos Residences	https://files.alnair.ae/uploads/2024/1/ff/d0/ffd0a5b2ad73ec1b027b299a9a401cc0.jpg,https://files.alnair.ae/uploads/2025/2/a3/21/a321b521c1ed2c4cfa562351a8fb28f6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19219535	55.28249703	Off-plan property: Rixos Residences by East & West Properties	68607746-dd6d-42bf-8ebb-36d8a9d7bba7	693600.00	1	1	1	2	75.00	75.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.012569	2025-11-02 21:43:07.012569
26bcf858-d9b7-4eda-bbf5-d4bf86d676bc	off-plan	Riviera 67	https://files.alnair.ae/uploads/2024/3/df/b0/dfb06c36b7b6b9fea4fd47f24fc1bdb2.jpg,https://files.alnair.ae/uploads/2024/3/3d/54/3d5497de02c60be7236202e8c49cf881.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17259319	55.31463057	Off-plan property: Riviera 67 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	896240.00	1	3	1	3	46.64	149.67	\N	\N	\N	\N	\N	2025-11-02 21:43:07.014514	2025-11-02 21:43:07.014514
58932c6f-4db4-46d1-8338-6a8e82198bef	off-plan	Helvetia Residences	https://files.alnair.ae/uploads/2024/2/a1/50/a1504e4654ae00ccb3acfbe0f351057a.jpg,https://files.alnair.ae/uploads/2025/2/f2/24/f2249ee5cc7b5c6e4ce0b859f393f9f4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04741243	55.20551026	Off-plan property: Helvetia Residences by DHG Real Estate Group	d91870ea-e002-4706-b7d4-0251346ea15a	184960.00	0	3	1	3	39.39	343.97	\N	\N	\N	\N	\N	2025-11-02 21:43:07.016028	2025-11-02 21:43:07.016028
d776f032-ec3e-4fdf-9e1c-2f4a37c8679e	off-plan	Cello Residences	https://files.alnair.ae/uploads/2024/7/ac/67/ac6746d188c5b58993f4039508be7dfe.jpg,https://files.alnair.ae/uploads/2024/1/ac/17/ac173c06218e1de640758147257962c8.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05154513	55.19863307	Off-plan property: Cello Residences by Taraf	a5fa31f8-5b72-4718-a5d1-2c22a14d0782	259039.20	0	3	1	3	49.33	203.92	\N	\N	\N	\N	\N	2025-11-02 21:43:07.017779	2025-11-02 21:43:07.017779
8f4789d5-ebe1-464d-a311-8cc00ae1eda5	off-plan	FH Residency	https://files.alnair.ae/uploads/2024/3/dd/c4/ddc4e1c779df0764c282c82446ad2118.jpg,https://files.alnair.ae/uploads/2024/3/a2/c2/a2c2c3f304e52730a0c930e700a1331f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03996618	55.18375572	Off-plan property: FH Residency by Forum Real Estate Development	d6473fdf-38b7-4cf9-be95-c2b2a32f8a3d	287254.03	1	3	1	3	51.81	148.38	\N	\N	\N	\N	\N	2025-11-02 21:43:07.019363	2025-11-02 21:43:07.019363
0b6a33f8-5010-4ce3-bafa-480e36b4d0c6	off-plan	Burj Azizi	https://files.alnair.ae/uploads/2025/1/bd/15/bd1598bae4b9d1f9455efe08262bc384.jpg,https://files.alnair.ae/uploads/2025/1/eb/bb/ebbba3a77d2a2317426b089ec597f9f6.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22434419	55.28224621	Off-plan property: Burj Azizi by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	2388704.00	1	3	1	3	73.21	289.21	\N	\N	\N	\N	\N	2025-11-02 21:43:07.020851	2025-11-02 21:43:07.020851
3cf7afad-5c8b-44dd-aaf5-a3c2f3a41132	off-plan	Trinity	https://files.alnair.ae/uploads/2024/1/64/c9/64c973671c769cbed8516dcae4269d61.jpg,https://files.alnair.ae/uploads/2024/3/16/c1/16c1270b38458785c4e6f5a7ad48f9cc.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06021952	55.23480794	Off-plan property: Trinity by Karma Development	38bcb8fc-3257-4311-90fa-8a5712e8ec0a	485108.74	2	2	2	2	118.35	180.72	\N	\N	\N	\N	\N	2025-11-02 21:43:07.02243	2025-11-02 21:43:07.02243
aa2b837d-12e4-4ef3-b590-fe92efd22481	off-plan	The East Crest By Meteora	https://files.alnair.ae/uploads/2024/8/23/dd/23dddf554a4182d1e5f4c03a3676eb04.jpg,https://files.alnair.ae/uploads/2024/8/6c/df/6cdf0c581ced4c3c64fffa3b03e21a47.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05987450	55.21874173	Off-plan property: The East Crest By Meteora by Meteora	fb4692a7-86dc-4258-85b6-c25bebac8361	263840.00	1	1	1	2	67.00	70.14	\N	\N	\N	\N	\N	2025-11-02 21:43:07.023862	2025-11-02 21:43:07.023862
681e8095-e0f8-4539-8044-8df558eac3a0	off-plan	Binghatti Rose	https://files.alnair.ae/uploads/2024/12/0e/bb/0ebb2a0d1f88c2845ea008ee609dc285.jpg,https://files.alnair.ae/uploads/2025/5/87/d1/87d1fb958ea18b0259e262cbb49a1566.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05759479	55.19918628	Off-plan property: Binghatti Rose by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	217600.00	1	1	1	2	61.00	61.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.025271	2025-11-02 21:43:07.025271
3150263e-776b-4bab-a20c-ec5d247f36ea	off-plan	Habtoor Grande Residence	https://files.alnair.ae/uploads/2024/1/a4/de/a4decc8fcf713486a1e7fb178cd9ff4f.jpg,https://files.alnair.ae/uploads/2024/1/1f/de/1fde9f528777d29185c0f44b8f0aeca4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08736239	55.14009298	Off-plan property: Habtoor Grande Residence by Al Habtoor Group	a1854004-59ab-4cd2-a89f-9d2f22c5130a	3061995.39	2	3	2	3	201.79	311.97	\N	\N	\N	\N	\N	2025-11-02 21:43:07.027035	2025-11-02 21:43:07.027035
7a193ee8-e26b-4767-bb3f-12f8397f49aa	off-plan	Aeon	https://files.alnair.ae/uploads/2024/1/c7/99/c79922d7187e70b4fc9e8038daca5827.jpg,https://files.alnair.ae/uploads/2025/1/8f/91/8f917087e83997c73998fdd1e5abcf8c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20646520	55.35181671	Off-plan property: Aeon by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	869825.54	2	2	2	2	119.75	119.75	\N	\N	\N	\N	\N	2025-11-02 21:43:07.028481	2025-11-02 21:43:07.028481
ba099c63-96c4-4588-ab6e-175b6acca7dd	off-plan	Red Square	https://files.alnair.ae/uploads/2024/1/1a/5e/1a5e23c38d879b998a7cab6b0caa17b0.jpg,https://files.alnair.ae/uploads/2024/1/77/80/7780501e675a96e28610938b44aa95ba.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03946980	55.18244174	Off-plan property: Red Square by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	306034.82	1	2	1	2	60.52	85.71	\N	\N	\N	\N	\N	2025-11-02 21:43:07.030107	2025-11-02 21:43:07.030107
0c57ab09-4704-4f8e-b746-77eead1ce456	off-plan	Bayz 101	https://files.alnair.ae/uploads/2024/1/ed/e9/ede9f88d22570f4676a7ff05faacf17e.jpg,https://files.alnair.ae/uploads/2024/1/ad/50/ad50b2d4134bb7e60da00955aad517b9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19184049	55.26345798	Off-plan property: Bayz 101 by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	326400.00	0	3	1	3	34.65	753.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.031593	2025-11-02 21:43:07.031593
3ed4c923-2a62-4abe-970e-5617204f7e15	off-plan	Westwood Grande	https://files.alnair.ae/uploads/2024/12/2f/0f/2f0f3f13c4bc429257eb1d0a5ea81f88.jpg,https://files.alnair.ae/uploads/2023/12/7e/4b/7e4bcd8aba5ff1e67e3534f0980967ed.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05477993	55.19813485	Off-plan property: Westwood Grande by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	171360.00	0	0	1	2	41.40	41.40	\N	\N	\N	\N	\N	2025-11-02 21:43:07.033282	2025-11-02 21:43:07.033282
ad0b8f31-8116-49a9-bcaa-0b96e9df057b	off-plan	Taormina Village	https://files.alnair.ae/uploads/2023/12/22/e8/22e8ca68e209f6eb18ca05b3d1ae8083.jpg,https://files.alnair.ae/uploads/2024/2/0e/37/0e3736790e6286f2bc6367fa39db1003.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09265344	55.30776411	Off-plan property: Taormina Village by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	864859.09	1	3	1	3	1632.53	3265.06	\N	\N	\N	\N	\N	2025-11-02 21:43:07.034685	2025-11-02 21:43:07.034685
b2aaebdd-b9bb-46c5-adef-7c2cb2dfba0a	off-plan	Celia Heights	https://files.alnair.ae/uploads/2023/12/4f/97/4f971d605d82b7c4977c4ea1f03717a7.jpg,https://files.alnair.ae/uploads/2023/12/17/93/179385829ead19220c2d7376bb25050f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09352327	55.32027491	Off-plan property: Celia Heights by Abou Eid Real Estate Development	342af2c3-688b-4e08-a4ad-30a2e1ab23f8	272000.00	1	2	1	2	56.21	95.78	\N	\N	\N	\N	\N	2025-11-02 21:43:07.035403	2025-11-02 21:43:07.035403
652d6ef4-dd3e-45d6-8f72-bef2bcf8c2c3	off-plan	Aeternitas	https://files.alnair.ae/uploads/2024/1/e3/1f/e31f818921edc0b0050efc8b770f871f.jpg,https://files.alnair.ae/uploads/2024/1/0c/5f/0c5fd25b49089fb20c916e554ec09018.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08836452	55.14943063	Off-plan property: Aeternitas by London Gate	4b47b8ee-6457-403f-81cf-12bbbf751d23	2638400.00	4	5	4	5	252.97	376.08	\N	\N	\N	\N	\N	2025-11-02 21:43:07.036839	2025-11-02 21:43:07.036839
0d392a00-ab5d-4191-8a27-55cc683d535b	off-plan	Mercer House	https://files.alnair.ae/uploads/2023/12/93/61/9361fe70c66a9253a92be9a83ebcd675.jpg,https://files.alnair.ae/uploads/2023/12/11/a8/11a813deeb1f8b468c88d2d9551a27ae.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06093300	55.13949700	Off-plan property: Mercer House by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	734897.22	1	3	1	3	88.92	933.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.038231	2025-11-02 21:43:07.038231
937d2653-8834-4410-869e-9955cf88bd27	off-plan	Iconic Tower	https://files.alnair.ae/uploads/2024/12/a0/10/a010d6c8160684174cadd2b8ba22e2b7.jpg,https://files.alnair.ae/uploads/2025/2/fb/9e/fb9e83afc4b7d4348b9ad0e6e06647b3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10120558	55.17024692	Off-plan property: Iconic Tower by MERED	89db6da6-014b-4199-bada-74e94dca2987	798418.74	1	4	1	4	80.31	257.88	\N	\N	\N	\N	\N	2025-11-02 21:43:07.040959	2025-11-02 21:43:07.040959
5ee3e712-5b15-46b8-98a5-818386f38e18	off-plan	The Orchard Place	https://files.alnair.ae/uploads/2023/12/90/ab/90abc81810b1b6e44bd89e3f09862f66.jpg,https://files.alnair.ae/uploads/2023/12/d5/d4/d5d46ad2f637eb3d4caa743d13908bb0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05663876	55.21122950	Off-plan property: The Orchard Place by Peak Summit Real Estate Development	919708eb-abe9-4e30-b104-990f07b7a9c2	211324.96	0	3	1	3	48.44	227.18	\N	\N	\N	\N	\N	2025-11-02 21:43:07.042468	2025-11-02 21:43:07.042468
f8bd2a87-6e8c-4839-a280-078b9627d834	off-plan	Q Gardens Lofts 2	https://files.alnair.ae/uploads/2024/2/23/30/23300c0aaf6c6ec128693f608f883008.jpg,https://files.alnair.ae/uploads/2025/5/7c/f9/7cf9797da39f9def9c732d5a728aa45b.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05475571	55.21096250	Off-plan property: Q Gardens Lofts 2 by AYS Property Development	3323282f-72a8-48b7-a6c2-8d6380bb0973	259751.84	1	1	1	2	93.95	102.87	\N	\N	\N	\N	\N	2025-11-02 21:43:07.043943	2025-11-02 21:43:07.043943
f955e7f3-bf4c-4f2a-8829-f73d43004e13	off-plan	Mercedes Benz Places by Binghatti	https://files.alnair.ae/uploads/2024/1/a8/61/a861bc21f8808b21b46f8b0213177dd7.jpg,https://files.alnair.ae/uploads/2024/10/68/c0/68c00e0c08f82486b34b84d69983247d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18841700	55.27999368	Off-plan property: Mercedes Benz Places by Binghatti by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	2747200.00	2	4	2	4	170.56	372.12	\N	\N	\N	\N	\N	2025-11-02 21:43:07.045379	2025-11-02 21:43:07.045379
7493c5c9-b3f7-4d0c-a002-140d8dafa85c	off-plan	Eden House The Canal	https://files.alnair.ae/uploads/2024/1/c9/8a/c98a3f3f77c0b2e4713ad3bf490c6258.png,https://files.alnair.ae/uploads/2023/12/c0/3f/c03fa9775f20c982b551407717c72b7e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19575573	55.23806008	Off-plan property: Eden House The Canal by H&H Development	b9e3db1f-eda1-44b1-8332-62be8b825be8	2856000.00	2	2	2	2	185.99	185.99	\N	\N	\N	\N	\N	2025-11-02 21:43:07.047025	2025-11-02 21:43:07.047025
32e1ec4f-5194-40d7-bc8c-1302ab808643	off-plan	Views V	https://files.alnair.ae/uploads/2025/1/ce/2b/ce2b316108e9f5b44cd3e992e4066b06.jpg,https://files.alnair.ae/uploads/2025/5/d2/e9/d2e9f681c8a484139183bb216de78e88.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05337968	55.20675547	Off-plan property: Views V by Golden Woods	deaaebdd-4cef-4c79-bb86-7df0a24cd413	316149.41	1	2	1	2	59.99	117.35	\N	\N	\N	\N	\N	2025-11-02 21:43:07.048431	2025-11-02 21:43:07.048431
59119618-cd0f-42b4-9f83-28f0e131fec1	off-plan	360 Riverside Crescent	https://files.alnair.ae/uploads/2023/11/04/ac/04acf829c6626836cf7478f7a40b3566.jpg,https://files.alnair.ae/uploads/2023/11/d5/30/d530f9a7b31bcf551df758b9fa3668cc.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17447144	55.32377959	Off-plan property: 360 Riverside Crescent by Sobha	5f637246-907f-4e44-9b90-7c3065602155	940094.83	2	2	2	2	132.41	135.69	\N	\N	\N	\N	\N	2025-11-02 21:43:07.049831	2025-11-02 21:43:07.049831
283d2b07-fbac-49e2-9fc4-51828612bf79	off-plan	Rise Residences	https://files.alnair.ae/uploads/2023/11/d7/7b/d77b7b2d9ebbf59305ca2ed79964a21b.png,https://files.alnair.ae/uploads/2023/11/8f/4a/8f4a248a8bffb4c899bfdcf53887cfac.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06913069	55.20858873	Off-plan property: Rise Residences by S&S Developments	4b4be146-17ea-4781-ac9d-a76499af62d8	272000.00	1	1	1	2	63.08	63.08	\N	\N	\N	\N	\N	2025-11-02 21:43:07.051207	2025-11-02 21:43:07.051207
8d6c00ca-d525-47c2-94a1-eb27351af8a5	off-plan	Mada'in Tower	https://files.alnair.ae/uploads/2024/12/ef/14/ef14888244cb41fd01dac018f98e7b09.png,https://files.alnair.ae/uploads/2023/11/48/a6/48a608ee81e0b5fbe2b82485b739c5b2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08978300	55.14922394	Off-plan property: Mada'in Tower by Mada'in	c4c61e8a-fb15-41ce-8ae9-68fe535bfd61	567468.70	1	5	1	5	80.09	421.87	\N	\N	\N	\N	\N	2025-11-02 21:43:07.054101	2025-11-02 21:43:07.054101
9c9e6bb7-dec1-4631-8339-bd44a0a82351	off-plan	Vela Viento	https://files.alnair.ae/uploads/2024/12/e6/37/e6378efcc726b4df7696d6fca195fc73.jpg,https://files.alnair.ae/uploads/2023/11/a7/26/a72635a7cf76be3739a6c5e1963bfea2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19094964	55.28966859	Off-plan property: Vela Viento by Omniyat	6e10dff0-abd2-49b5-9c98-71ec8f1b446f	4896000.00	2	4	2	4	0.00	358.79	\N	\N	\N	\N	\N	2025-11-02 21:43:07.055597	2025-11-02 21:43:07.055597
f81179b2-4e92-4d44-94d7-1c2d9b25cf4e	off-plan	Lumina Vista	https://files.alnair.ae/uploads/2024/5/cb/e1/cbe101d51d92d3496e903011a219e788.png,https://files.alnair.ae/uploads/2024/5/ad/bf/adbf868ec5c1327403e173e2e909b76f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05412821	55.20436432	Off-plan property: Lumina Vista by ARIB Developments	2fdc703a-9a4e-4dc7-9ff4-61f71970b5e9	408000.00	1	2	1	2	91.96	182.49	\N	\N	\N	\N	\N	2025-11-02 21:43:07.057153	2025-11-02 21:43:07.057153
10f605dd-5ed2-445d-8e2c-9adffb77696b	off-plan	Maya 5	https://files.alnair.ae/uploads/2023/11/fd/f7/fdf79f9c29528953338210a667b7f0e5.jpg,https://files.alnair.ae/uploads/2023/11/8b/a9/8ba93dea0315f0ed312ea0970b30ff24.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03608644	55.17571360	Off-plan property: Maya 5 by London Gate	4b47b8ee-6457-403f-81cf-12bbbf751d23	299200.00	1	3	1	3	68.44	169.10	\N	\N	\N	\N	\N	2025-11-02 21:43:07.05868	2025-11-02 21:43:07.05868
618bbd41-1deb-49de-8505-850b09e39d7f	off-plan	Maison Elysee I & II	https://files.alnair.ae/uploads/2024/12/ae/92/ae92cde818f8334d774ec7c3eea62f9b.png,https://files.alnair.ae/uploads/2024/10/d9/ce/d9ce4dd05b1561987de625318fa721cc.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05105799	55.21566175	Off-plan property: Maison Elysee I & II by Pantheon	a8c243a7-ac10-4ed9-a660-d05ee9b7ca60	135972.80	0	2	1	2	34.37	83.06	\N	\N	\N	\N	\N	2025-11-02 21:43:07.060144	2025-11-02 21:43:07.060144
27b4cf0c-4687-43ee-a6bd-7825322e6112	off-plan	OZONE1	https://files.alnair.ae/uploads/2023/11/6e/46/6e46f59bbeed004c3681fb00548fedf5.jpg,https://files.alnair.ae/uploads/2025/3/f3/67/f3677dbe9cad6ab1396ff8bffbc196da.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05019361	55.21534046	Off-plan property: OZONE1 by Object One	9d128f32-1c6c-474d-b911-61803444decc	257040.00	1	1	1	2	69.40	69.40	\N	\N	\N	\N	\N	2025-11-02 21:43:07.061632	2025-11-02 21:43:07.061632
e699656e-e27b-4b2a-bbc6-e8f9db1e03af	off-plan	25H Heimat	https://files.alnair.ae/uploads/2023/11/eb/c5/ebc5bd14d7ba2d05cf58333c0a8f2b0c.jpg,https://files.alnair.ae/uploads/2023/11/f6/5a/f65a6653a3e7ab38f1575cf1a5249477.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19069965	55.27029635	Off-plan property: 25H Heimat by East & West Properties	68607746-dd6d-42bf-8ebb-36d8a9d7bba7	5132878.54	3	3	3	3	286.72	298.68	\N	\N	\N	\N	\N	2025-11-02 21:43:07.063284	2025-11-02 21:43:07.063284
91694471-d809-4a2e-94e4-e845039d41c4	off-plan	Nad Al Sheba Gardens Phase 4	https://files.alnair.ae/uploads/2023/11/d2/64/d264df2c8124b679ebd281828412fd7a.jpg,https://files.alnair.ae/uploads/2023/11/24/65/2465d8daf1069cf2be66c867e93c50fc.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.15466376	55.29962305	Off-plan property: Nad Al Sheba Gardens Phase 4 by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	3807999.73	1	3	1	3	4.74	9.49	\N	\N	\N	\N	\N	2025-11-02 21:43:07.064759	2025-11-02 21:43:07.064759
fa80c8de-c160-42f1-a677-7878c1f1f3a2	off-plan	Riviera 61	https://files.alnair.ae/uploads/2024/1/7b/4c/7b4c03587a5c2ac8dc03c127a5b4b198.jpg,https://files.alnair.ae/uploads/2024/1/fb/d7/fbd778ae4cd8b92b6a8093b30c8b3ba9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17418316	55.31440457	Off-plan property: Riviera 61 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	1770992.00	1	3	1	3	86.03	100.24	\N	\N	\N	\N	\N	2025-11-02 21:43:07.065479	2025-11-02 21:43:07.065479
edcc5aa2-ed73-4ce4-9008-7b18cc02a5b0	off-plan	One River Point	https://files.alnair.ae/uploads/2023/11/33/5a/335a9fd6a3bf2a2d085554cbbbcce5f5.jpg,https://files.alnair.ae/uploads/2023/11/2e/5e/2e5e613d4c0fc28e9f56fede4565f06a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18170318	55.26098371	Off-plan property: One River Point by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	762641.22	1	4	1	4	98.50	518.05	\N	\N	\N	\N	\N	2025-11-02 21:43:07.066839	2025-11-02 21:43:07.066839
b7811d37-6d67-4bdb-916e-1f7121daf287	off-plan	OAK YARD	https://files.alnair.ae/uploads/2024/1/fa/7d/fa7d8eb1715d2eecaeefacb8248145c2.jpg,https://files.alnair.ae/uploads/2023/11/38/6a/386a0fbe779fe461f7672fc522c9b768.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06165918	55.20856350	Off-plan property: OAK YARD by ONE YARD	f7df9890-0677-44aa-9ad3-dd3826a235d3	281329.33	1	3	1	3	60.11	524.44	\N	\N	\N	\N	\N	2025-11-02 21:43:07.069584	2025-11-02 21:43:07.069584
a49a5885-c740-4879-bbc0-07239f804e55	off-plan	Volga Tower	https://files.alnair.ae/uploads/2023/11/bf/cb/bfcbf2f687f6711d42d641bed718e4b9.jpg,https://files.alnair.ae/uploads/2023/11/d9/ce/d9cede54cf6c6bcdb30c3c45b6dab348.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05503646	55.19369928	Off-plan property: Volga Tower by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	464651.07	1	4	1	4	72.80	257.65	\N	\N	\N	\N	\N	2025-11-02 21:43:07.071022	2025-11-02 21:43:07.071022
0a65a5dd-673e-4714-9dc0-5ecafd5be7dd	off-plan	48 Parkside	https://files.alnair.ae/uploads/2023/10/9d/4f/9d4f040488872976558892470ca71aa5.jpg,https://files.alnair.ae/uploads/2023/10/5a/53/5a534539b25c137c9591d02e884f0c87.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05629656	55.23952251	Off-plan property: 48 Parkside by Tabeer	7d0313ac-b8a1-442a-a962-501f92b22c54	340000.00	1	3	1	3	68.66	134.06	\N	\N	\N	\N	\N	2025-11-02 21:43:07.072648	2025-11-02 21:43:07.072648
9d621f5e-f737-4a12-8eac-86ee67a014a4	off-plan	310 Riverside Crescent	https://files.alnair.ae/uploads/2023/10/d9/47/d947401f6f3fd8f65cc25fc0caec5851.jpg,https://files.alnair.ae/uploads/2023/10/49/5c/495c3733a265cb5cab2fa06818d92dc3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17127263	55.32519981	Off-plan property: 310 Riverside Crescent by Sobha	5f637246-907f-4e44-9b90-7c3065602155	930194.30	2	2	2	2	132.38	136.34	\N	\N	\N	\N	\N	2025-11-02 21:43:07.074092	2025-11-02 21:43:07.074092
f017f1c4-c509-4b90-863d-fe04b1cab58c	off-plan	The Central Downtown	https://files.alnair.ae/uploads/2023/12/91/93/91930fb319b8c4a780e9cc1ef8779218.jpg,https://files.alnair.ae/uploads/2023/11/84/d2/84d2e0a40a51383b95be85359e160334.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06506248	55.23734808	Off-plan property: The Central Downtown by Aqua	be42958b-d8c4-401b-8619-0b0cedcdd5c5	203728.00	0	3	1	3	40.90	583.43	\N	\N	\N	\N	\N	2025-11-02 21:43:07.075531	2025-11-02 21:43:07.075531
636d5723-5653-4f84-92ef-a8ac8db6b274	off-plan	Haven Living	https://files.alnair.ae/uploads/2023/11/62/1a/621abe019f11942c783a8cefde294fba.jpg,https://files.alnair.ae/uploads/2024/4/98/a8/98a8bfa14c71409a5ca5e88fa28aded8.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.29270755	55.30601366	Off-plan property: Haven Living by Metac Development	7ddbd659-2584-4bec-8e99-def860eaffd2	628864.00	1	2	1	2	87.70	302.59	\N	\N	\N	\N	\N	2025-11-02 21:43:07.077221	2025-11-02 21:43:07.077221
4cc579ea-c184-444e-bfe0-5ac0ab650b30	off-plan	Elara	https://files.alnair.ae/uploads/2024/7/35/76/35763d07e06cba8db93def53b9d9e61a.jpg,https://files.alnair.ae/uploads/2024/7/e9/3d/e93d3046ae6f4f485a1a7b30950b2fd0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13257430	55.19275773	Off-plan property: Elara by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	768944.00	1	1	1	2	79.06	79.06	\N	\N	\N	\N	\N	2025-11-02 21:43:07.078695	2025-11-02 21:43:07.078695
c3d5e555-5597-4c25-90bb-df46f6bff6df	off-plan	Aqua Dimore	https://files.alnair.ae/uploads/2024/12/80/7a/807ac04b82d0f9cc62eea054d270a680.png,https://files.alnair.ae/uploads/2023/10/25/4d/254d99275a8987539959554b8ba21162.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06974412	55.24736320	Off-plan property: Aqua Dimore by Vincitore	3636d588-69e3-4d16-b9a8-725d1bdf8629	271456.00	0	3	1	3	41.51	174.64	\N	\N	\N	\N	\N	2025-11-02 21:43:07.080301	2025-11-02 21:43:07.080301
f70e06be-23c1-40bf-bb02-b0679dad2683	off-plan	Binghatti Azure	https://files.alnair.ae/uploads/2023/10/36/89/3689c26e752072f6c19b3c3b2f40ba5f.jpg,https://files.alnair.ae/uploads/2025/5/6e/e3/6ee3ff5eb1e15179cba37c5315fe671a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06834968	55.21205888	Off-plan property: Binghatti Azure by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	183600.00	0	0	1	2	35.59	35.59	\N	\N	\N	\N	\N	2025-11-02 21:43:07.081825	2025-11-02 21:43:07.081825
8864a300-dd91-4c31-98b4-2485d899f8ca	off-plan	Expo Valley	https://files.alnair.ae/uploads/2023/10/00/6b/006bf298f91817f6c6e63cf05c1d7fe4.jpg,https://files.alnair.ae/uploads/2023/10/84/d2/84d20c957c0cd4b67d5341552b7e4064.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.96394869	55.17031432	Off-plan property: Expo Valley by Expo City	f152c1f4-6ec3-4c04-8438-a8190b3b68de	2094400.00	1	3	1	3	1145.44	2290.88	\N	\N	\N	\N	\N	2025-11-02 21:43:07.08327	2025-11-02 21:43:07.08327
ae13bea3-6135-42b4-bdc6-0b218138f2a2	off-plan	Sapphire 32	https://files.alnair.ae/uploads/2023/10/1a/80/1a8057379faa56c8fc6dcc4322509699.png,https://files.alnair.ae/uploads/2023/11/e3/f9/e3f9dc283eb7e7453694a9c1bbdf829c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05524275	55.20997748	Off-plan property: Sapphire 32 by Dar Al Karama	d9f29021-91e5-4324-843d-990cb7733f9c	456392.34	2	3	2	3	107.30	140.75	\N	\N	\N	\N	\N	2025-11-02 21:43:07.084261	2025-11-02 21:43:07.084261
99d6125b-7d03-4fd9-9854-24afc83aac77	off-plan	Symphony	https://files.alnair.ae/uploads/2023/10/55/b4/55b47333de134ba8d2d26377fb90c48d.jpg,https://files.alnair.ae/uploads/2023/10/14/b1/14b11c55cf7836320e38c07d6bc1aabb.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00723717	55.29062290	Off-plan property: Symphony by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	733553.54	3	3	3	3	125.88	125.88	\N	\N	\N	\N	\N	2025-11-02 21:43:07.085689	2025-11-02 21:43:07.085689
397f3ede-2bcc-4d61-9b24-959e00f1e6b8	off-plan	Mama Residence	https://files.alnair.ae/uploads/2024/1/8d/05/8d05f5b148284ba721874ebc03274c81.jpg,https://files.alnair.ae/uploads/2023/10/9d/39/9d399819de7760d7ff9d5486ef914e29.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18020796	55.27204312	Off-plan property: Mama Residence by Kappa Acca Real Estate Development	e96f8225-8f64-4d77-9f6c-5a53d89dd69d	340000.00	0	1	1	2	40.78	60.85	\N	\N	\N	\N	\N	2025-11-02 21:43:07.087502	2025-11-02 21:43:07.087502
aac97762-a5d2-4dd2-91e3-1bdb1cc3043a	off-plan	Olivia Residences	https://files.alnair.ae/uploads/2024/12/7a/50/7a50f46898e0aca9a2f4f057c5fa1b2c.jpg,https://files.alnair.ae/uploads/2023/10/cf/7d/cf7dd6f11729cfd5b34703ebc609b4c2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.99780011	55.16921137	Off-plan property: Olivia Residences by Karma Development	38bcb8fc-3257-4311-90fa-8a5712e8ec0a	220320.00	1	1	1	2	69.21	131.55	\N	\N	\N	\N	\N	2025-11-02 21:43:07.08898	2025-11-02 21:43:07.08898
0e47e635-b927-4206-ba40-95fa658dc55b	off-plan	Binghatti Tulip	https://files.alnair.ae/uploads/2023/10/04/11/0411ba99c25d6a0a07bb1b6f542d70b1.png,https://files.alnair.ae/uploads/2023/10/75/07/75077e2cee91cf1c63b30dbf0c262a42.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05924216	55.21367691	Off-plan property: Binghatti Tulip by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	189040.00	0	1	1	2	28.34	58.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.090596	2025-11-02 21:43:07.090596
ac4f7993-200f-40fa-b134-1b30f9dd187e	off-plan	Trussardi Residences	https://files.alnair.ae/uploads/2023/10/cd/53/cd53551b9b4fb9df59e68f9f82d5f049.jpg,https://files.alnair.ae/uploads/2025/2/4d/45/4d45089dc26e15f59ba7729ff6524296.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03519435	55.14325015	Off-plan property: Trussardi Residences by Mira Developments	b99a2707-a8ba-4b3f-a4d2-ed2cf388a8a9	882050.03	2	2	2	2	172.24	184.58	\N	\N	\N	\N	\N	2025-11-02 21:43:07.091966	2025-11-02 21:43:07.091966
81926e60-9801-4a10-97a4-6f52d956a9ca	off-plan	Floating Seahorse Villas	https://files.alnair.ae/uploads/2023/10/c8/24/c824eaba7f6779684a37a36e6200a479.png,https://files.alnair.ae/uploads/2024/7/3f/87/3f87295d22e5d49c61e750386ec273be.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22361686	55.16383441	Off-plan property: Floating Seahorse Villas by The Heart of Europe	de44570c-141e-4809-a5a9-9dbc9556999c	5984000.00	1	3	1	3	6.44	12.88	\N	\N	\N	\N	\N	2025-11-02 21:43:07.093302	2025-11-02 21:43:07.093302
36466891-925f-495d-bd7e-681ac2a6d6a9	off-plan	Laya Courtyard	https://files.alnair.ae/uploads/2025/1/8c/27/8c2713e83a8926031580561b0fed8427.jpg,https://files.alnair.ae/uploads/2024/1/0d/b9/0db9c95055e9e52d13aee9edb421390f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03378543	55.23499937	Off-plan property: Laya Courtyard by Laya Developers	42e7ce4f-1170-4048-a329-a2deca8e8155	192009.70	0	1	1	2	41.06	89.19	\N	\N	\N	\N	\N	2025-11-02 21:43:07.095139	2025-11-02 21:43:07.095139
3150815f-d3c9-46d6-95ab-e9dd0e1b36a7	off-plan	Equiti Gate	https://files.alnair.ae/uploads/2023/10/47/d5/47d5acb2f536b00496d40aaa6df9176c.jpg,https://files.alnair.ae/uploads/2025/2/f0/29/f029e148f7d655a05429b260d7926ab1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.95018004	55.07268327	Off-plan property: Equiti Gate by B N H Real Estate Developer	9ece548a-5211-4966-b1e1-e45c7943fa4f	195380.86	0	1	1	2	33.63	188.22	\N	\N	\N	\N	\N	2025-11-02 21:43:07.097011	2025-11-02 21:43:07.097011
3df4f198-df26-472f-b45c-031fe9b456c7	off-plan	350 Riverside Crescent	https://files.alnair.ae/uploads/2023/10/20/d1/20d1621078bd88149112cabea9d31ffd.jpg,https://files.alnair.ae/uploads/2024/8/0d/68/0d6843ce91f78bb486e1ba07b94e106a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17374015	55.32418049	Off-plan property: 350 Riverside Crescent by Sobha	5f637246-907f-4e44-9b90-7c3065602155	337280.00	1	2	1	2	48.87	109.60	\N	\N	\N	\N	\N	2025-11-02 21:43:07.098406	2025-11-02 21:43:07.098406
345bc4a0-1071-46f2-8035-a2772d1f9ea9	off-plan	Samana Manhattan	https://files.alnair.ae/uploads/2023/10/86/78/86780ce18a2e37274f7b172c05a52959.jpg,https://files.alnair.ae/uploads/2023/10/af/b6/afb637b5c18b21b03eef95f80094b04b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04646034	55.20823792	Off-plan property: Samana Manhattan by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	299200.00	1	2	1	2	57.00	121.24	\N	\N	\N	\N	\N	2025-11-02 21:43:07.099806	2025-11-02 21:43:07.099806
97f8c4fb-c0b8-4cf3-afba-5a9f237d8b05	off-plan	Azizi Venice	https://files.alnair.ae/uploads/2023/12/3b/ce/3bce3fcd5f2a0c8d4de605f6195daf4e.jpg,https://files.alnair.ae/uploads/2023/10/55/26/5526bed5d9dcfd79ce05da40665a0a78.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.84714900	55.13883600	Off-plan property: Azizi Venice by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	168640.00	0	3	1	3	30.84	539.77	\N	\N	\N	\N	\N	2025-11-02 21:43:07.101233	2025-11-02 21:43:07.101233
8b6891a3-ecd2-462a-9175-7b92223b2bf8	off-plan	MARRIOTT JVC	https://files.alnair.ae/uploads/2024/1/13/15/1315c0082fe8f170e99767f78e16d9a5.jpg,https://files.alnair.ae/uploads/2024/1/80/dd/80dd7464b6f9d8baabe35f949ee1d951.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06020980	55.21933973	Off-plan property: MARRIOTT JVC by Kappa Acca Real Estate Development	e96f8225-8f64-4d77-9f6c-5a53d89dd69d	3876068.00	1	3	1	3	259.66	799.62	\N	\N	\N	\N	\N	2025-11-02 21:43:07.102735	2025-11-02 21:43:07.102735
0caccfd7-a508-49c7-b716-e0c1b8e91267	off-plan	Monaco Mansions	https://files.alnair.ae/uploads/2024/11/88/12/881250cc4a1085c2d004c3270944c750.png,https://files.alnair.ae/uploads/2024/11/74/c0/74c09bfa7086a30d3964f78924305635.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.84699821	55.12302164	Off-plan property: Monaco Mansions by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	12373280.00	1	3	1	3	1407.68	2815.37	\N	\N	\N	\N	\N	2025-11-02 21:43:07.104003	2025-11-02 21:43:07.104003
9af94c55-3eae-42f6-8da4-447c954254b2	off-plan	Nima The Valley	https://files.alnair.ae/uploads/2023/9/2b/56/2b567906c4136b7d346a35ac64bdf607.jpg,https://files.alnair.ae/uploads/2025/3/50/52/5052fa5762aa90fa5910c9f7798d997a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00303619	55.45402765	Off-plan property: Nima The Valley by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	788800.00	1	3	1	3	1284.43	2568.86	\N	\N	\N	\N	\N	2025-11-02 21:43:07.104688	2025-11-02 21:43:07.104688
1af04296-a88b-452a-b018-168ca9947a52	off-plan	ARIA	https://files.alnair.ae/uploads/2023/9/d8/60/d860fce28f35af6c906cb4c27e6d0b25.png,https://files.alnair.ae/uploads/2023/9/b6/e3/b6e38cb340d66836896dbc0ea77bae55.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00724446	55.28964955	Off-plan property: ARIA by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	312800.00	1	1	1	2	67.00	67.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.105372	2025-11-02 21:43:07.105372
72102b5f-2a43-4d27-b965-acac64be4b1f	off-plan	Nautica Towers	https://files.alnair.ae/uploads/2023/9/72/c9/72c96ed6df6191265d44acbfe053514d.jpg,https://files.alnair.ae/uploads/2025/3/7f/3b/7f3beb2f5ea15a587f02f4102a91a193.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.26432857	55.27014058	Off-plan property: Nautica Towers by Select Group	e5e2dd29-98f2-4191-8f60-5eb6dc3cad47	448800.00	1	1	1	2	57.13	734.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.107089	2025-11-02 21:43:07.107089
6611f726-7298-49b3-b792-86d9921603c8	off-plan	izzzi.life Mint	https://files.alnair.ae/uploads/2025/4/cc/f6/ccf656b164fc47ca22ac60b761a9714e.jpg,https://files.alnair.ae/uploads/2024/6/aa/78/aa78c58366debd86a20c3644297062de.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04691350	55.20072350	Off-plan property: izzzi.life Mint by Orange.Life!	bacd3d97-a234-40e2-ba5b-8676e52b60da	244803.26	0	2	1	2	43.41	170.74	\N	\N	\N	\N	\N	2025-11-02 21:43:07.110331	2025-11-02 21:43:07.110331
401277ee-afa8-4a18-a90f-113887dbf5db	off-plan	Palm Jebel Ali	https://files.alnair.ae/uploads/2023/9/06/4d/064dc5f965e64cd86aea2ed42093cf30.png,https://files.alnair.ae/uploads/2023/9/1a/62/1a624ab34cbcf68e7959983a2bb58467.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.99885502	54.97677678	Off-plan property: Palm Jebel Ali by Nakheel	d190bf02-5336-42e6-bba1-91ee1ab4b2d5	11016000.00	1	3	1	3	6084.82	12169.65	\N	\N	\N	\N	\N	2025-11-02 21:43:07.111775	2025-11-02 21:43:07.111775
51d2dcea-f5c1-4bf3-9980-8793a1d84a61	off-plan	340 Riverside Crescent	https://files.alnair.ae/uploads/2023/9/72/59/7259f127bc679e279c62c86da5e6729c.jpg,https://files.alnair.ae/uploads/2023/9/6a/d9/6ad9857cd43b2df7b6bcd042144ffec5.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17294147	55.32442734	Off-plan property: 340 Riverside Crescent by Sobha	5f637246-907f-4e44-9b90-7c3065602155	530757.14	1	1	1	2	78.34	83.09	\N	\N	\N	\N	\N	2025-11-02 21:43:07.112636	2025-11-02 21:43:07.112636
ddf44329-65fd-44bd-b50e-a51ce0d8c4a7	off-plan	Floarea Residence	https://files.alnair.ae/uploads/2023/9/bd/ee/bdeed17fc21661534442b02039673481.jpg,https://files.alnair.ae/uploads/2023/9/4c/8e/4c8e3eaf9e97f0e19fb7ab5717ba358a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06450667	55.23140833	Off-plan property: Floarea Residence by Mashriq Elite Real Estate Development	087f0279-b93a-4dc1-aab3-0735b577e84e	225760.00	1	1	1	2	72.09	72.09	\N	\N	\N	\N	\N	2025-11-02 21:43:07.114064	2025-11-02 21:43:07.114064
018e39c0-a1d3-41b6-809f-5ab497768438	off-plan	ORLA Infinity	https://files.alnair.ae/uploads/2024/12/47/31/4731bdbea88202c7ae582f511c8d77b9.jpg,https://files.alnair.ae/uploads/2023/9/02/a5/02a5ecad322d59efc2f7ad0ba5f409e0.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12184946	55.11152297	Off-plan property: ORLA Infinity by Omniyat	6e10dff0-abd2-49b5-9c98-71ec8f1b446f	26479200.00	4	4	4	4	793.67	793.67	\N	\N	\N	\N	\N	2025-11-02 21:43:07.11543	2025-11-02 21:43:07.11543
e0c6cfd1-6cbb-43fd-a527-0f529daaf6ef	off-plan	Volta	https://files.alnair.ae/uploads/2023/9/4c/c3/4cc3ade44256e4dec4efb7056c095ca9.jpg,https://files.alnair.ae/uploads/2023/9/e2/43/e2431fb8b253d1e00da385dd8ac46cc4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19728700	55.26732389	Off-plan property: Volta by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	678912.00	1	4	1	4	95.69	220.19	\N	\N	\N	\N	\N	2025-11-02 21:43:07.116899	2025-11-02 21:43:07.116899
f4f59611-1a69-412e-bbfc-addd83a97589	off-plan	Weybridge Gardens	https://files.alnair.ae/uploads/2023/9/36/1a/361a9d769e5696e8081ffcedcfbebc80.png,https://files.alnair.ae/uploads/2023/9/c2/47/c247321922e268cd0890944ec43c4d76.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08947586	55.38451016	Off-plan property: Weybridge Gardens by Leos Development	8f713edb-84d7-465d-8744-965901f5d7e7	149600.00	0	0	1	2	55.90	55.90	\N	\N	\N	\N	\N	2025-11-02 21:43:07.118586	2025-11-02 21:43:07.118586
ba263212-c742-4a61-8320-0f67eedc3e26	off-plan	Trillionaire Residences	https://files.alnair.ae/uploads/2023/9/58/49/5849c533972b71885b1762de81b73052.png,https://files.alnair.ae/uploads/2025/5/f3/52/f352627c32b86bdc1484ed9de2dc1723.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18381310	55.27990800	Off-plan property: Trillionaire Residences by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	544000.00	1	1	1	2	59.00	59.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.119947	2025-11-02 21:43:07.119947
448f6b17-0669-44c7-9036-b5e8114dfe3e	off-plan	Lilium Tower	https://files.alnair.ae/uploads/2023/9/4a/0e/4a0ea67fcdf02406c81f472cd0a0e7d4.jpg,https://files.alnair.ae/uploads/2023/9/f4/52/f4527a6d33d3937a9130a45cb4258a82.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03920848	55.18109813	Off-plan property: Lilium Tower by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	258400.00	1	2	1	2	62.84	102.33	\N	\N	\N	\N	\N	2025-11-02 21:43:07.121295	2025-11-02 21:43:07.121295
c1ea064e-2012-4779-ac55-d78c6dee0871	off-plan	Oceanz	https://files.alnair.ae/uploads/2023/10/d8/c1/d8c183d2f866615f3cb16193baeed9a1.jpg,https://files.alnair.ae/uploads/2023/9/4b/8a/4b8a6c3af2a4613ad24146da4a2fcb62.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.27338289	55.26735115	Off-plan property: Oceanz by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	326400.00	0	3	1	3	37.19	1184.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.12302	2025-11-02 21:43:07.12302
6d75046b-1bf4-4c20-bac7-7d227cd76b06	off-plan	Adeba Azizi Residence	https://files.alnair.ae/uploads/2023/8/80/4d/804da03a6c8e4fb3eecf9574d953abe9.png,https://files.alnair.ae/uploads/2023/8/58/66/5866ac42ee668c2e7df1ef2f081245c1.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21362601	55.31966103	Off-plan property: Adeba Azizi Residence by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	326400.00	1	3	1	3	67.54	261.49	\N	\N	\N	\N	\N	2025-11-02 21:43:07.124491	2025-11-02 21:43:07.124491
b4120133-3bdf-43d8-ac2a-261bc4ef9901	off-plan	VYB	https://files.alnair.ae/uploads/2024/4/5f/7e/5f7e0d0e8c72015f9fdc9241dac5de80.jpg,https://files.alnair.ae/uploads/2025/3/73/68/73684c84e5a049d283685399a135d189.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17764589	55.27362898	Off-plan property: VYB by Ginco Properties	506e86f8-e9a6-4cf0-87d2-a7db97ac97b9	448800.00	1	1	1	2	76.93	78.01	\N	\N	\N	\N	\N	2025-11-02 21:43:07.125936	2025-11-02 21:43:07.125936
0e980ff3-fab5-4f94-a090-fb478e97dad1	off-plan	Eywa	https://files.alnair.ae/uploads/2023/8/19/e1/19e1eb3820e5506584da2ff0f46e5777.jpg,https://files.alnair.ae/uploads/2023/8/40/0d/400d047f73ddea0da462251df44951a2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18311052	55.27323738	Off-plan property: Eywa by Rvl Real Estate	336d541b-8383-44f1-8e00-15f663df4b51	3396355.20	2	5	2	5	276.20	825.72	\N	\N	\N	\N	\N	2025-11-02 21:43:07.12738	2025-11-02 21:43:07.12738
58e7afb8-6795-4654-b613-48ef83437f86	off-plan	Rove Home Downtown	https://files.alnair.ae/uploads/2023/9/50/09/500982d3d6d94a04fcd65a7484e8a3cb.jpg,https://files.alnair.ae/uploads/2023/9/aa/af/aaafb1146d8c0cd7438ba788c51ca0bd.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19008902	55.27128334	Off-plan property: Rove Home Downtown by Irth Development	f62d2c43-fdd2-42ca-a285-58271ad51d03	407456.00	0	1	1	2	38.68	54.60	\N	\N	\N	\N	\N	2025-11-02 21:43:07.128857	2025-11-02 21:43:07.128857
bd641e6d-f4c8-4580-a35f-1c0af7cc0e17	off-plan	The Mayfair	https://files.alnair.ae/uploads/2023/8/1b/5d/1b5d58175499a2f6f58843e9c830586b.png,https://files.alnair.ae/uploads/2023/8/c3/23/c323cb36df343b64f0aa00b8a8587882.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.99868736	55.29880017	Off-plan property: The Mayfair by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	224400.00	1	1	1	2	60.39	60.47	\N	\N	\N	\N	\N	2025-11-02 21:43:07.130548	2025-11-02 21:43:07.130548
a9817da7-4769-48bc-b3e8-2f5f62147d9c	off-plan	Samana Golf Views	https://files.alnair.ae/uploads/2023/8/4c/34/4c34f093baa6800850f4b9625ebf9c27.jpg,https://files.alnair.ae/uploads/2023/8/2a/af/2aafdfee0a0a1d96014230aa0f59dc93.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04090735	55.21626176	Off-plan property: Samana Golf Views by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	214880.00	0	0	1	2	37.89	37.89	\N	\N	\N	\N	\N	2025-11-02 21:43:07.132053	2025-11-02 21:43:07.132053
b7cafe3a-7b48-4794-9f59-a737f42522d3	off-plan	Coral Reef	https://files.alnair.ae/uploads/2023/8/31/35/3135e602bf063d0eae20155cd302a6f8.png,https://files.alnair.ae/uploads/2023/8/2e/f7/2ef7a646f444f7e060ab600bcfa5d7be.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.26914150	55.27022150	Off-plan property: Coral Reef by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	938400.00	2	2	2	2	130.00	130.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.133473	2025-11-02 21:43:07.133473
f2effd7d-6637-49eb-b717-669b512c6681	off-plan	Elitz 3	https://files.alnair.ae/uploads/2023/8/96/3b/963bfa57cdbd04b82c65026ffdcdbe0e.jpg,https://files.alnair.ae/uploads/2023/8/a2/60/a2600aee1251bbcdc6a1d63e0ce01602.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04602288	55.20659800	Off-plan property: Elitz 3 by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	509456.00	2	2	2	2	102.47	118.87	\N	\N	\N	\N	\N	2025-11-02 21:43:07.135041	2025-11-02 21:43:07.135041
c9329163-6f4b-45b1-a8ea-bef77b9c02ad	off-plan	Binghatti Orchid	https://files.alnair.ae/uploads/2023/9/9d/79/9d795564263b34e21e34411a202ec78b.png,https://files.alnair.ae/uploads/2025/5/af/29/af29cc195b33c099879eabd5a02137fc.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06126672	55.20277910	Off-plan property: Binghatti Orchid by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	456960.00	2	2	2	2	112.35	116.16	\N	\N	\N	\N	\N	2025-11-02 21:43:07.136405	2025-11-02 21:43:07.136405
1ec17e0f-c2bb-4c5c-9d69-44f17d813b9f	off-plan	Riviera 65	https://files.alnair.ae/uploads/2023/8/8d/1a/8d1a9f148ef7084d2e45309a92fcef94.jpg,https://files.alnair.ae/uploads/2023/8/09/e2/09e23b008634ac22db62fdd33224b771.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17316850	55.31457022	Off-plan property: Riviera 65 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	365840.00	0	1	1	2	35.86	94.58	\N	\N	\N	\N	\N	2025-11-02 21:43:07.137774	2025-11-02 21:43:07.137774
fb4c5f04-d790-4075-a06a-61944889d085	off-plan	Parkside Views	https://files.alnair.ae/uploads/2023/10/be/de/bede15f3368a1aaeb03d066c26911684.jpg,https://files.alnair.ae/uploads/2025/2/94/f2/94f25c45e689c08ca1fd3ee050eee703.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10595884	55.24161940	Off-plan property: Parkside Views by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	470560.00	1	1	1	2	65.03	91.23	\N	\N	\N	\N	\N	2025-11-02 21:43:07.139478	2025-11-02 21:43:07.139478
85568b58-1fed-4f1e-9278-cec45ddeace0	off-plan	Greenside Residence	https://files.alnair.ae/uploads/2023/9/74/ac/74ac04a8e7d0de0f9fa3cd8db3edda31.png,https://files.alnair.ae/uploads/2023/9/de/27/de27c8441374efe4232eb56a8296bd60.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12071011	55.25831228	Off-plan property: Greenside Residence by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	407969.54	1	3	1	3	67.35	130.62	\N	\N	\N	\N	\N	2025-11-02 21:43:07.142745	2025-11-02 21:43:07.142745
bcc168a9-9a72-41a5-8fed-ab31d606d474	off-plan	The Haven	https://files.alnair.ae/uploads/2023/9/da/a1/daa1ec38f9b87c67031eaf017b58ddef.png,https://files.alnair.ae/uploads/2025/3/9d/9e/9d9eaf3126cfa87009b3ef0c7437b844.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09255109	55.31200469	Off-plan property: The Haven by Meraki Developers	33c35d4c-3611-42e4-9043-c83f202fedeb	202640.00	1	2	1	2	68.73	156.82	\N	\N	\N	\N	\N	2025-11-02 21:43:07.14419	2025-11-02 21:43:07.14419
f7ab4ef9-deee-4720-8f01-2ca7c8860a44	off-plan	Gateway By Premier Choice	https://files.alnair.ae/uploads/2023/10/c4/03/c40360782eac61e8df8c0e6c9e2c2408.png,https://files.alnair.ae/uploads/2025/2/73/25/73257baddc52965f9bd6afa4185bf264.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06051400	55.20366482	Off-plan property: Gateway By Premier Choice by Premier Choice	0d9fe3ae-dfe1-4e55-a775-c00afb116de3	315661.98	1	3	1	3	71.26	218.51	\N	\N	\N	\N	\N	2025-11-02 21:43:07.146122	2025-11-02 21:43:07.146122
e37b96ce-1d20-4dab-9fe4-e489859cd053	off-plan	Anwa Aria	https://files.alnair.ae/uploads/2024/12/e5/f9/e5f95a3b0c06237d8443f1d6f40965ae.jpg,https://files.alnair.ae/uploads/2023/7/55/bc/55bcc93dc5c989e7c0f50f15bb3c677b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.26961493	55.27001336	Off-plan property: Anwa Aria by Beyond	7b5842d5-1b0f-4c98-900e-f6d8112df185	1195984.00	2	2	2	2	134.86	156.11	\N	\N	\N	\N	\N	2025-11-02 21:43:07.147673	2025-11-02 21:43:07.147673
602b3a30-fb88-4772-ad15-d1ada6a5e68c	off-plan	Keturah Reserve Apartments	https://files.alnair.ae/uploads/2024/1/78/28/7828e04da7ce56bf7b18a0deeab14577.jpg,https://files.alnair.ae/uploads/2025/2/17/86/1786379b236cee6179e75e809df74ff3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.14783158	55.28406484	Off-plan property: Keturah Reserve Apartments by MAG Property Development	d5dfad6f-2582-4be3-89ae-c5625e33a996	1090992.00	1	4	1	4	108.48	467.64	\N	\N	\N	\N	\N	2025-11-02 21:43:07.149178	2025-11-02 21:43:07.149178
2ac14bcf-15a6-4dfe-bb23-dfa443475462	off-plan	Serenity Mansions	https://files.alnair.ae/uploads/2023/10/38/51/38518dd0e2cc56a5cc8190d2c9c74a7e.jpg,https://files.alnair.ae/uploads/2025/2/1b/b7/1bb7030d6d8991950891196ee470ad09.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02134650	55.21773550	Off-plan property: Serenity Mansions by Majid Al Futtaim	4e3d71dd-2644-44ab-b07f-17f13ee73227	8865568.00	1	3	1	3	880.87	1761.75	\N	\N	\N	\N	\N	2025-11-02 21:43:07.150649	2025-11-02 21:43:07.150649
3e83d6e3-d5b6-4050-a933-ccc56091c6bf	off-plan	Samana California	https://files.alnair.ae/uploads/2023/7/d9/54/d9542bfae7bd49635887ba3bdd33a077.jpg,https://files.alnair.ae/uploads/2023/7/01/16/0116f72c247c525d29f597b494f43e86.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03763689	55.14248103	Off-plan property: Samana California by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	243440.00	0	0	1	2	37.81	37.81	\N	\N	\N	\N	\N	2025-11-02 21:43:07.151373	2025-11-02 21:43:07.151373
bbf39092-07a2-4b26-83b9-10a053e023c7	off-plan	Pearl House II	https://files.alnair.ae/uploads/2023/7/22/73/227353bbf42b7596ccc47e431c28af64.jpg,https://files.alnair.ae/uploads/2023/7/05/15/0515352309b8ef3fa194c1b8e5480ec4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05295200	55.21326638	Off-plan property: Pearl House II by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	271184.00	1	1	1	2	65.37	65.37	\N	\N	\N	\N	\N	2025-11-02 21:43:07.152705	2025-11-02 21:43:07.152705
a08fcc9e-8977-4bdf-a418-9f175ccd64c1	off-plan	Mudon Al Ranim 8	https://files.alnair.ae/uploads/2023/8/77/24/772424944b967839f4aed83b44f281fe.jpg,https://files.alnair.ae/uploads/2023/7/ec/9c/ec9cddccb0df18fd0a9df81cd0cd438a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01642976	55.26584515	Off-plan property: Mudon Al Ranim 8 by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	63802287.65	1	3	1	3	19.58	39.17	\N	\N	\N	\N	\N	2025-11-02 21:43:07.154028	2025-11-02 21:43:07.154028
872bc4d8-1cd1-4de4-abb8-047866609d99	off-plan	Sobha Reserve	https://files.alnair.ae/uploads/2023/7/63/cb/63cbce69ea456aadd2e327e6551a73ab.jpg,https://files.alnair.ae/uploads/2023/7/e8/22/e822ea6674eaddcb3f904ab2d57f6055.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08594850	55.33801670	Off-plan property: Sobha Reserve by Sobha	5f637246-907f-4e44-9b90-7c3065602155	1890400.00	1	3	1	3	1264.02	2528.03	\N	\N	\N	\N	\N	2025-11-02 21:43:07.15473	2025-11-02 21:43:07.15473
ccdda552-8542-4124-a6fa-06440010e803	off-plan	320 Riverside Crescent	https://files.alnair.ae/uploads/2024/12/d4/08/d4088428f08c92a88604754b406198aa.jpg,https://files.alnair.ae/uploads/2023/7/ad/d4/add42bccb8950e9fa3bede98084388ac.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17133420	55.32682214	Off-plan property: 320 Riverside Crescent by Sobha	5f637246-907f-4e44-9b90-7c3065602155	613926.30	1	3	1	3	91.17	165.92	\N	\N	\N	\N	\N	2025-11-02 21:43:07.155619	2025-11-02 21:43:07.155619
cd12ff61-40ed-4b65-907c-43adf655e384	off-plan	The Ritz-Carlton Residences	https://files.alnair.ae/uploads/2023/7/2b/3c/2b3cdfd500365c2b1d6af0d3ed448178.jpg,https://files.alnair.ae/uploads/2023/7/cd/14/cd14167ae94a511cbff8750a08283e19.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18489454	55.28543447	Off-plan property: The Ritz-Carlton Residences by Khamas Group	7e7cb721-5edf-428b-8097-ed48a0e32fb9	5032000.00	2	3	2	3	272.48	357.40	\N	\N	\N	\N	\N	2025-11-02 21:43:07.157455	2025-11-02 21:43:07.157455
e49be3ed-032a-4635-a103-a70a31835bd0	off-plan	The Ritz-Carlton Residences	https://files.alnair.ae/uploads/2024/1/65/a9/65a97158cb406726939a2ff8cf06bb8b.jpg,https://files.alnair.ae/uploads/2024/1/10/40/1040f44a40a104e0a41ffcb916411c97.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20702850	55.31920400	Off-plan property: The Ritz-Carlton Residences by MAG Property Development	d5dfad6f-2582-4be3-89ae-c5625e33a996	1881696.00	1	3	1	3	123.98	391.87	\N	\N	\N	\N	\N	2025-11-02 21:43:07.158961	2025-11-02 21:43:07.158961
aea0f147-a0fc-4992-9e94-a38b8f9d85ee	off-plan	Verdana Residence 2	https://files.alnair.ae/uploads/2024/12/39/57/39576e0447b455c172b6d762e56f96d5.jpg,https://files.alnair.ae/uploads/2025/5/4a/5c/4a5c5320be7a751847d7e2084ddd499e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98995514	55.17905082	Off-plan property: Verdana Residence 2 by Reportage	f810a543-a616-442d-b964-99e9d3cb8e11	257158.05	1	1	1	2	55.83	82.87	\N	\N	\N	\N	\N	2025-11-02 21:43:07.160457	2025-11-02 21:43:07.160457
ae580e2e-990d-47ed-bbbd-15ee1d6aa66f	off-plan	Luma Park Views	https://files.alnair.ae/uploads/2024/12/0d/30/0d30a54a4344ed99aab2552247cbbacc.jpg,https://files.alnair.ae/uploads/2023/7/2d/79/2d791c372f265578721bbfa6a9cdcc6c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05485000	55.20560213	Off-plan property: Luma Park Views by TownX	95773061-50af-429b-ab24-d3b738a4e758	379984.00	1	3	1	3	74.09	158.99	\N	\N	\N	\N	\N	2025-11-02 21:43:07.161773	2025-11-02 21:43:07.161773
21443a8a-817a-4963-b54f-40720e577c1c	off-plan	Golf Greens	https://files.alnair.ae/uploads/2023/6/0d/01/0d01b3f1c07e5deec38d0fec741c5437.jpg,https://files.alnair.ae/uploads/2023/7/26/f9/26f9aa5246cc2b45b2af6e2879291ec7.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01370475	55.25307387	Off-plan property: Golf Greens by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	469744.00	1	3	1	3	90.90	445.07	\N	\N	\N	\N	\N	2025-11-02 21:43:07.163419	2025-11-02 21:43:07.163419
da534cb0-40f1-4eed-ad88-2937f77e5d2b	off-plan	Pantheon Boulevard	https://files.alnair.ae/uploads/2023/6/2a/9b/2a9beb5e2923e5e362729cbdbc2cdc04.jpg,https://files.alnair.ae/uploads/2023/6/95/d5/95d588415bf7a092ed1fed84a877ca7f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05086062	55.21385059	Off-plan property: Pantheon Boulevard by Pantheon	a8c243a7-ac10-4ed9-a660-d05ee9b7ca60	217600.00	0	0	1	2	51.00	51.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.16495	2025-11-02 21:43:07.16495
e5fac7de-6b78-4433-815e-3a89a8f41ba8	off-plan	Baccarat	https://files.alnair.ae/uploads/2023/6/b6/e3/b6e3d6b8224fc217981c5dd9f9f70c00.jpg,https://files.alnair.ae/uploads/2023/6/a8/40/a8405e6251f9b371985c6aadbe4794f1.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18935137	55.27929113	Off-plan property: Baccarat by H&H Development	b9e3db1f-eda1-44b1-8332-62be8b825be8	9520000.00	3	4	3	4	349.78	476.96	\N	\N	\N	\N	\N	2025-11-02 21:43:07.166399	2025-11-02 21:43:07.166399
cfb80d4a-19ce-446c-804b-a49924f4dd1d	off-plan	Casa Canal	https://files.alnair.ae/uploads/2023/6/28/36/283648e9302fdb25e0b5a43dcc0cf2ac.jpg,https://files.alnair.ae/uploads/2025/3/f4/45/f4451f90bdfa6efe4a78b6d8a0ab8634.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18858560	55.24376526	Off-plan property: Casa Canal by AHS Properties	b634bdb5-0543-4401-bc7a-d5a9dbf181a7	6120000.00	3	5	3	5	431.72	1150.98	\N	\N	\N	\N	\N	2025-11-02 21:43:07.167732	2025-11-02 21:43:07.167732
99f396e1-1f71-49a3-a9f4-def9d5603569	off-plan	Grove	https://files.alnair.ae/uploads/2023/6/90/a8/90a880d4a7e20847ab44aec0e707206f.jpg,https://files.alnair.ae/uploads/2023/6/9c/4b/9c4b09ab16326824455bfee1b6f8f23c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20421552	55.34978896	Off-plan property: Grove by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1278400.00	3	3	3	3	3064.00	3064.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.171727	2025-11-02 21:43:07.171727
69347719-4904-49e0-be59-30452b735e62	off-plan	Rosewater	https://files.alnair.ae/uploads/2024/12/9e/8d/9e8dbc8c048df49f6fded7a26abf8958.jpg,https://files.alnair.ae/uploads/2024/12/15/52/1552df2dd90851a1f5c65ad1f5fd921a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20437570	55.34969375	Off-plan property: Rosewater by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	666400.00	2	2	2	2	100.43	100.43	\N	\N	\N	\N	\N	2025-11-02 21:43:07.173165	2025-11-02 21:43:07.173165
9d1688b6-89bd-4223-948c-fe2df20b1bda	off-plan	SO/ Uptown Dubai Residences	https://files.alnair.ae/uploads/2023/6/1a/40/1a40c75164bd7764c5bd1878ffdf4f7b.jpg,https://files.alnair.ae/uploads/2023/6/03/db/03db3aee299670e61d5b039958243235.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06067027	55.14163902	Off-plan property: SO/ Uptown Dubai Residences by DMCC	ab652251-7fa5-453d-b5f6-58b781fce89b	748000.00	1	1	1	2	72.09	72.09	\N	\N	\N	\N	\N	2025-11-02 21:43:07.175689	2025-11-02 21:43:07.175689
7edc0b05-46ce-43d8-b07a-a6d2640b8660	off-plan	Elitz 2	https://files.alnair.ae/uploads/2024/12/2b/6f/2b6f34864c4f5789b493fd05c2684f60.jpg,https://files.alnair.ae/uploads/2023/6/a7/98/a798f1215b8d83e1a069f4d32705d69a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06939264	55.20573825	Off-plan property: Elitz 2 by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	204000.00	0	3	1	3	35.92	138.91	\N	\N	\N	\N	\N	2025-11-02 21:43:07.177024	2025-11-02 21:43:07.177024
cc04b742-b1e1-4bae-9c19-95e14b414887	off-plan	Aras Heights	https://files.alnair.ae/uploads/2023/11/2a/93/2a935563c9dddac48a0294eb6c3e0152.jpg,https://files.alnair.ae/uploads/2023/11/47/3f/473fed6e4459169b001ca569b3f7c4f4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08946310	55.31666969	Off-plan property: Aras Heights by Aras Development	48b7c726-9e46-4ca6-a33a-3fbdac7f59df	421600.00	2	2	2	2	113.60	114.07	\N	\N	\N	\N	\N	2025-11-02 21:43:07.180389	2025-11-02 21:43:07.180389
f47ea7e0-e524-4ad0-9ef8-ac724bbd2a50	off-plan	Sunridge	https://files.alnair.ae/uploads/2023/6/80/94/8094af3746744641d3405d844dd45028.jpg,https://files.alnair.ae/uploads/2023/6/91/3d/913dcd500f65ba5a714467253dede449.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.25623253	55.27878150	Off-plan property: Sunridge by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	489600.00	1	1	1	2	60.48	60.48	\N	\N	\N	\N	\N	2025-11-02 21:43:07.181796	2025-11-02 21:43:07.181796
8580c8d6-a20c-4a8a-9585-7512e57d3d38	off-plan	Binghatti Amber	https://files.alnair.ae/uploads/2023/6/aa/b4/aab4449494b92e63ca5e69fc5a40cf85.jpg,https://files.alnair.ae/uploads/2023/6/60/07/6007e626f824e516c8007e033d7e0f38.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06245362	55.20971060	Off-plan property: Binghatti Amber by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	269280.00	1	1	1	2	62.80	62.80	\N	\N	\N	\N	\N	2025-11-02 21:43:07.183158	2025-11-02 21:43:07.183158
2e933300-83ac-408f-8eb7-22b22f1e98c2	off-plan	Arbor View	https://files.alnair.ae/uploads/2023/6/56/44/5644b881ba581c1e0625889882ef3e24.jpg,https://files.alnair.ae/uploads/2023/6/20/5c/205cc60caff6bdbf1be9f5de5208b766.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06403775	55.23005247	Off-plan property: Arbor View by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	244800.00	0	0	1	2	41.81	41.81	\N	\N	\N	\N	\N	2025-11-02 21:43:07.184642	2025-11-02 21:43:07.184642
ef4b3e0c-1226-469e-b4e4-ea24f9d8f09d	off-plan	Q Gardens Lofts	https://files.alnair.ae/uploads/2024/6/c9/ba/c9ba6a7d8deafddd31cb54ced0ef1a53.jpg,https://files.alnair.ae/uploads/2024/6/80/c1/80c1bc7f881d33bcbfc76de6792677f9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05361715	55.20825885	Off-plan property: Q Gardens Lofts by AYS Property Development	3323282f-72a8-48b7-a6c2-8d6380bb0973	131748.37	0	4	1	4	39.13	550.62	\N	\N	\N	\N	\N	2025-11-02 21:43:07.186008	2025-11-02 21:43:07.186008
7ad898f2-445b-48f8-9b67-4f354bb9b0ac	off-plan	Pearl House	https://files.alnair.ae/uploads/2023/6/82/59/8259e742cdaa7aed61e157f42a3c19e6.jpg,https://files.alnair.ae/uploads/2023/6/6e/32/6e32a683bee8fd3f3458ae857119712d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05366376	55.21104300	Off-plan property: Pearl House by Imtiaz	7c08726a-4e53-4d93-a5a1-5b8df7b407da	163200.00	0	0	1	2	37.60	38.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.187521	2025-11-02 21:43:07.187521
351daca5-8ec8-4b66-abff-2e90d17cc82b	off-plan	Vela	https://files.alnair.ae/uploads/2024/12/25/e7/25e738f95b9e8a4ca53490ae5d83296f.jpg,https://files.alnair.ae/uploads/2023/6/f2/42/f242587d91b9c1e7401cf9b7d06db9f7.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19005874	55.28909319	Off-plan property: Vela by Omniyat	6e10dff0-abd2-49b5-9c98-71ec8f1b446f	11696000.00	3	4	3	4	322.84	565.78	\N	\N	\N	\N	\N	2025-11-02 21:43:07.188919	2025-11-02 21:43:07.188919
2c75392e-98f3-4689-b5ee-97cd7085aa99	off-plan	North 43	https://files.alnair.ae/uploads/2023/5/40/42/4042edbbbeadd778ec119d5d821456f3.jpg,https://files.alnair.ae/uploads/2023/5/5a/52/5a52af85292e7191c6cafbc15f4afde3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05964085	55.20344663	Off-plan property: North 43 by Naseeb Group	46244c19-1223-4c52-9da6-55149c5e3538	155040.00	0	1	1	2	33.54	64.52	\N	\N	\N	\N	\N	2025-11-02 21:43:07.190597	2025-11-02 21:43:07.190597
15ed6c7b-e724-47c0-91ff-21aac0b054bd	off-plan	Society House	https://files.alnair.ae/uploads/2023/6/07/ea/07ea0fa5894dcfb43b9fe76e63449b20.png,https://files.alnair.ae/uploads/2025/3/ab/17/ab17aea25621372965a28b85476cbe0f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19427616	55.28685100	Off-plan property: Society House by IGO	67f5aab0-438f-4003-be9f-1ae5d83638f4	388960.00	0	0	1	2	35.78	35.78	\N	\N	\N	\N	\N	2025-11-02 21:43:07.19234	2025-11-02 21:43:07.19234
bba28692-2fd3-4d7a-9ec3-0353d7248750	off-plan	Riviera 63	https://files.alnair.ae/uploads/2023/5/a3/53/a3538782c71eacb010bc5955d38b74c9.jpg,https://files.alnair.ae/uploads/2023/5/48/d3/48d3cdbd9567af011fba47b702d8c2fa.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17350775	55.31436034	Off-plan property: Riviera 63 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	1574880.00	1	3	1	3	79.25	139.08	\N	\N	\N	\N	\N	2025-11-02 21:43:07.193748	2025-11-02 21:43:07.193748
b9a465ba-08e1-42a0-9bc2-08001d0fdb22	off-plan	Bugatti Residences	https://files.alnair.ae/uploads/2023/10/31/b9/31b9e23876bfed8b376873f137b98cba.jpg,https://files.alnair.ae/uploads/2025/3/41/e4/41e4cd3a50ee0b896e318398b5ffea35.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18796739	55.26550591	Off-plan property: Bugatti Residences by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	5276800.00	2	4	2	4	188.41	1215.73	\N	\N	\N	\N	\N	2025-11-02 21:43:07.196524	2025-11-02 21:43:07.196524
83a74ccc-70e7-4d0f-b095-7f38dde6dc94	off-plan	Kempinski Residences	https://files.alnair.ae/uploads/2023/5/dd/8a/dd8aeb4d094922bfcbbb05a4faaed52c.png,https://files.alnair.ae/uploads/2023/5/60/33/6033c21ef5028a236ea46252db8f158a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20703550	55.32249194	Off-plan property: Kempinski Residences by Swiss Property	97eb81d9-3fdf-41e7-a755-8edd7dd452d4	775200.00	0	0	1	2	74.66	74.66	\N	\N	\N	\N	\N	2025-11-02 21:43:07.199102	2025-11-02 21:43:07.199102
0927ca9d-48a5-4d2a-b07b-0f318581485a	off-plan	Armani Beach Residences	https://files.alnair.ae/uploads/2024/1/69/50/69509e3c38da9aa34c8bd90ca02abd8a.jpg,https://files.alnair.ae/uploads/2024/1/6c/53/6c53888e7e82637b443e30bbb9758621.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13834973	55.14626272	Off-plan property: Armani Beach Residences by ARADA	7d6bd1e9-574b-4682-b1b0-f6ef56f1dcae	6256000.00	2	5	2	5	243.68	2943.17	\N	\N	\N	\N	\N	2025-11-02 21:43:07.200444	2025-11-02 21:43:07.200444
f4125cdb-0d29-4453-9bda-6d5ee85c5b3e	off-plan	V1TER	https://files.alnair.ae/uploads/2023/5/cc/21/cc21e12069c963333d6ecc039fe19f38.jpg,https://files.alnair.ae/uploads/2023/5/9b/a0/9ba03d4e96935bd8b3db531b6ddb5662.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05741411	55.22031339	Off-plan property: V1TER by Object One	9d128f32-1c6c-474d-b911-61803444decc	165185.60	0	1	1	2	36.05	69.86	\N	\N	\N	\N	\N	2025-11-02 21:43:07.201982	2025-11-02 21:43:07.201982
ea91ed03-4ddc-4440-81b4-5cf9740996f6	off-plan	Binghatti House	https://files.alnair.ae/uploads/2023/10/5f/ce/5fce2800e6be8682828c795f58c5c629.jpg,https://files.alnair.ae/uploads/2025/5/fa/5b/fa5b43aec6d397e5d3151ce236f7643a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06265650	55.20110350	Off-plan property: Binghatti House by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	184960.00	0	2	1	2	28.89	103.22	\N	\N	\N	\N	\N	2025-11-02 21:43:07.20335	2025-11-02 21:43:07.20335
637fba71-ceb7-495e-872c-74d347fb552b	off-plan	Burj Binghatti-Jacob&Co Residences	https://files.alnair.ae/uploads/2023/10/50/98/50987a7d7db69bb7e5f48557e8b7ce05.jpg,https://files.alnair.ae/uploads/2025/2/ec/56/ec564ac57f8aa7842ba94eadf87f290a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18689386	55.29289864	Off-plan property: Burj Binghatti-Jacob&Co Residences by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	2358240.00	2	5	2	5	303.22	1095.94	\N	\N	\N	\N	\N	2025-11-02 21:43:07.204805	2025-11-02 21:43:07.204805
309586e4-8109-431c-8a20-368aa58328a3	off-plan	Thyme	https://files.alnair.ae/uploads/2023/5/90/3d/903dede41d2d24846ed785a35457b2e2.jpg,https://files.alnair.ae/uploads/2023/5/3a/16/3a16a685d2868faafee1ebd0057ba481.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20473150	55.25932900	Off-plan property: Thyme by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	639200.00	1	1	1	2	70.89	70.89	\N	\N	\N	\N	\N	2025-11-02 21:43:07.206225	2025-11-02 21:43:07.206225
360da4eb-1107-4d04-9796-4f8bb00ce364	off-plan	Alef Noon Residence	https://files.alnair.ae/uploads/2024/5/47/6b/476b46da77d8032f95185f5b9501f2e9.jpg,https://files.alnair.ae/uploads/2024/5/0e/fd/0efd130ba8722001fec722cbe4ab41c2.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06903836	55.20897366	Off-plan property: Alef Noon Residence by Albait Al Duwaliy Real Estate Development	987b03aa-8763-4914-b617-14db66cc1a0d	398480.00	1	2	1	2	111.86	129.85	\N	\N	\N	\N	\N	2025-11-02 21:43:07.208639	2025-11-02 21:43:07.208639
69b93858-03d9-48a8-9fe6-f9968e7b992f	off-plan	Hartland II Villas	https://files.alnair.ae/uploads/2023/7/2c/c1/2cc1f46da8f0b27d063014f186514347.jpg,https://files.alnair.ae/uploads/2024/7/ba/b8/bab8017fc71a93c7f3a2225d06f3e562.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17559900	55.33009850	Off-plan property: Hartland II Villas by Sobha	5f637246-907f-4e44-9b90-7c3065602155	16494066.40	1	3	1	3	436.73	873.46	\N	\N	\N	\N	\N	2025-11-02 21:43:07.20998	2025-11-02 21:43:07.20998
5b472437-8ae7-4658-9e8f-da56ae2fe271	off-plan	IVY GARDENS	https://files.alnair.ae/uploads/2023/5/29/d9/29d92baade28423462782a04748f31b0.jpg,https://files.alnair.ae/uploads/2023/5/f3/21/f321202ec19dc0ff383f7b3e95a530a8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09201250	55.38158932	Off-plan property: IVY GARDENS by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	413228.11	1	3	1	3	85.54	187.10	\N	\N	\N	\N	\N	2025-11-02 21:43:07.210672	2025-11-02 21:43:07.210672
944883a2-54c7-425f-b9c4-12931a0b7764	off-plan	Oxford Gardens	https://files.alnair.ae/uploads/2023/5/f0/45/f0459999bd8d80b5be7f01485e81d888.png,https://files.alnair.ae/uploads/2025/4/e5/ad/e5ad2d10dfcd92769692d49c1c69c7f5.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06535661	55.24761150	Off-plan property: Oxford Gardens by Iman Developers	6ad5348a-4fe7-4ee9-b98b-aa545a89e019	421600.00	2	2	2	2	127.00	127.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.212024	2025-11-02 21:43:07.212024
0883815e-773e-4a12-bbe9-05b04a8a7898	off-plan	Creek Waters 2	https://files.alnair.ae/uploads/2024/12/a3/e8/a3e865179c8156cfa987413d89bb9eec.jpg,https://files.alnair.ae/uploads/2023/5/d0/19/d01943fae39d1737d77070c4a3e5d0b1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20722843	55.34839019	Off-plan property: Creek Waters 2 by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	648961.54	2	2	2	2	112.70	112.70	\N	\N	\N	\N	\N	2025-11-02 21:43:07.213572	2025-11-02 21:43:07.213572
40113f05-0efd-45ff-a357-65458460d2e5	off-plan	Bayview	https://files.alnair.ae/uploads/2023/6/e7/b3/e7b3fcb1f932221763613c9a1da155f5.jpg,https://files.alnair.ae/uploads/2025/2/71/6e/716ea5f9bf68f95c17bc18214a72d9fd.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09611438	55.13749270	Off-plan property: Bayview by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1527521.54	2	2	2	2	128.49	128.49	\N	\N	\N	\N	\N	2025-11-02 21:43:07.215232	2025-11-02 21:43:07.215232
ad5e731d-a09e-4d64-8244-36576396c6eb	off-plan	Riviera 59	https://files.alnair.ae/uploads/2024/12/da/66/da66ecf804d0585ba15ba26b754fc3b1.png,https://files.alnair.ae/uploads/2023/5/a5/bf/a5bf1e0e62673634d0af30c13b4ce06a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17466696	55.31439856	Off-plan property: Riviera 59 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	394400.00	1	2	1	2	49.75	81.10	\N	\N	\N	\N	\N	2025-11-02 21:43:07.21689	2025-11-02 21:43:07.21689
6e427985-4d49-4777-9977-642452dc6e6d	off-plan	330 Riverside Crescent	https://files.alnair.ae/uploads/2023/5/44/62/446246362014341af75fbc7ca8cc9c8b.jpg,https://files.alnair.ae/uploads/2023/5/0f/01/0f01268f844e37cb0544ee993f599491.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17163740	55.32599519	Off-plan property: 330 Riverside Crescent by Sobha	5f637246-907f-4e44-9b90-7c3065602155	378080.00	1	2	1	2	46.60	105.35	\N	\N	\N	\N	\N	2025-11-02 21:43:07.21831	2025-11-02 21:43:07.21831
16810fe1-8b47-4b24-90ca-87d06d631bbf	off-plan	Design Quarter	https://files.alnair.ae/uploads/2023/5/18/e8/18e84d65da7282ed383230dad970a8cd.jpg,https://files.alnair.ae/uploads/2025/2/86/ed/86ed732523cb9183058d88db1bcf12f2.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18589388	55.29603521	Off-plan property: Design Quarter by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	567702.08	1	3	1	3	75.00	307.04	\N	\N	\N	\N	\N	2025-11-02 21:43:07.219813	2025-11-02 21:43:07.219813
7bfcd560-87d4-419c-a02b-10603b704c09	off-plan	Canal Crown	https://files.alnair.ae/uploads/2024/12/a8/da/a8da07d5b0da3cbd4a2259dc1e4a39ef.jpg,https://files.alnair.ae/uploads/2023/5/d3/47/d347847df11efb6c7a968b0083f5bfe0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18201969	55.28018841	Off-plan property: Canal Crown by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	299200.00	0	3	1	3	37.81	408.36	\N	\N	\N	\N	\N	2025-11-02 21:43:07.222765	2025-11-02 21:43:07.222765
65e5e9b5-9dfb-4780-bb5a-b42d0ef42e80	off-plan	Damac Hills - Golf Gate 2	https://files.alnair.ae/uploads/2023/5/59/2e/592e5623488f02c85dc902c0bbbb5814.jpg,https://files.alnair.ae/uploads/2024/1/21/85/2185f7425d24d3057b1213205947b4b1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02138410	55.24355877	Off-plan property: Damac Hills - Golf Gate 2 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	614176.00	2	2	2	2	105.13	105.13	\N	\N	\N	\N	\N	2025-11-02 21:43:07.224198	2025-11-02 21:43:07.224198
8902ba38-0c70-499c-83ed-998267ca9fad	off-plan	Azizi Vista	https://files.alnair.ae/uploads/2023/6/9b/df/9bdf59e382de6d9f3a323f87175caf77.jpg,https://files.alnair.ae/uploads/2025/6/a5/9d/a59ddef99d34b8aa4c8d1c99adaccc09.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03488348	55.23419984	Off-plan property: Azizi Vista by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	317696.00	1	1	1	2	78.69	84.16	\N	\N	\N	\N	\N	2025-11-02 21:43:07.225543	2025-11-02 21:43:07.225543
f8bda7a3-be22-4503-b63b-d2b63440145b	off-plan	Como Residences	https://files.alnair.ae/uploads/2023/5/d3/04/d3047fd2026ce107a98442abfbb8239b.jpg,https://files.alnair.ae/uploads/2023/5/94/c4/94c4d09fa333ba41303b67334942875e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11113088	55.14550388	Off-plan property: Como Residences by Nakheel	d190bf02-5336-42e6-bba1-91ee1ab4b2d5	14394457.60	3	4	3	4	877.75	956.81	\N	\N	\N	\N	\N	2025-11-02 21:43:07.226892	2025-11-02 21:43:07.226892
2b5c5c10-f45d-46e3-a936-25bc4cd715ce	off-plan	ALTAI Tower	https://files.alnair.ae/uploads/2024/12/89/65/89651a02935026a0dbbb0de15ffc8892.jpg,https://files.alnair.ae/uploads/2023/5/6b/16/6b16b8117c1d05d1029c4851b889d39e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03314100	55.17363776	Off-plan property: ALTAI Tower by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	269280.00	1	1	1	2	57.98	57.98	\N	\N	\N	\N	\N	2025-11-02 21:43:07.228334	2025-11-02 21:43:07.228334
bb2ab590-5abc-4035-810a-747e4ad84fc4	off-plan	Portofino	https://files.alnair.ae/uploads/2024/1/64/03/64032a1e63400c1d34e39f976bc12a63.jpg,https://files.alnair.ae/uploads/2023/4/fa/e9/fae9b906820fe1f1698616ffd2f307fb.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.23212995	55.16233122	Off-plan property: Portofino by The Heart of Europe	de44570c-141e-4809-a5a9-9dbc9556999c	888781.76	0	0	1	2	78.22	640.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.229952	2025-11-02 21:43:07.229952
34b7b282-11ba-4a31-8353-5a386b7ab715	off-plan	Damac Bay 2	https://files.alnair.ae/uploads/2023/4/a3/6c/a36cd1bf8e9a7b6c847ce12c5734e863.jpg,https://files.alnair.ae/uploads/2023/4/d7/b7/d7b76ae3e05f5e57d25151b11a714779.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09119713	55.14556326	Off-plan property: Damac Bay 2 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	1003680.00	1	5	1	5	73.50	711.22	\N	\N	\N	\N	\N	2025-11-02 21:43:07.231654	2025-11-02 21:43:07.231654
9fa4b0d6-92b4-4b7d-8549-689fa1675f3e	off-plan	Côte d’Azur	https://files.alnair.ae/uploads/2024/1/72/4b/724b37ce0e1bf1ebf096a9206d616c9d.jpg,https://files.alnair.ae/uploads/2023/4/fe/05/fe05db6881ec2bdf0920d02f3ed86df3.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.23004176	55.15984301	Off-plan property: Côte d’Azur by The Heart of Europe	de44570c-141e-4809-a5a9-9dbc9556999c	340000.00	0	0	1	2	37.63	145.77	\N	\N	\N	\N	\N	2025-11-02 21:43:07.233138	2025-11-02 21:43:07.233138
6f66d05c-7876-4662-89d9-743a1c86b0e1	off-plan	DG1	https://files.alnair.ae/uploads/2023/10/31/74/3174a66e9568802a595a1e2517d2623f.jpg,https://files.alnair.ae/uploads/2023/6/1d/ee/1dee8a2d9b14078472f981a66ac7a146.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18121409	55.26408702	Off-plan property: DG1 by DarGlobal	4b39b795-8d4c-4141-b0e7-2d6e9a8ba72f	450300.08	0	2	1	2	45.34	160.26	\N	\N	\N	\N	\N	2025-11-02 21:43:07.234529	2025-11-02 21:43:07.234529
149d14f2-3f4a-4558-bae9-d67fefb71a12	off-plan	The Crestmark	https://files.alnair.ae/uploads/2024/12/db/1b/db1ba96fa80c3d9a86515bdcae8d65dc.jpg,https://files.alnair.ae/uploads/2025/2/c2/89/c2899403696a7c164ab967fb0975ea2d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18704165	55.28398480	Off-plan property: The Crestmark by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	579360.00	1	2	1	2	69.40	130.62	\N	\N	\N	\N	\N	2025-11-02 21:43:07.235943	2025-11-02 21:43:07.235943
8b738a02-54e9-44d4-b76c-71e77fcdb359	off-plan	Fashionz	https://files.alnair.ae/uploads/2024/12/ca/91/ca91125d3ed8ec6a244ff709b63602d3.jpg,https://files.alnair.ae/uploads/2023/4/15/50/1550025d538acc41be81a583f1a37fec.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04216850	55.18873571	Off-plan property: Fashionz by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	326400.00	1	2	1	2	70.49	109.39	\N	\N	\N	\N	\N	2025-11-02 21:43:07.237403	2025-11-02 21:43:07.237403
be56202f-fbd1-4726-a6c7-6eeb75ef644d	off-plan	Seapoint	https://files.alnair.ae/uploads/2024/4/c7/e5/c7e5774e2914656b057ffe50ac06980f.jpg,https://files.alnair.ae/uploads/2023/4/75/c8/75c86cb2c5f707529421216d303fc758.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09737757	55.13870716	Off-plan property: Seapoint by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1371393.54	2	2	2	2	102.29	128.49	\N	\N	\N	\N	\N	2025-11-02 21:43:07.238799	2025-11-02 21:43:07.238799
c5cf1818-4341-4b30-8316-d98b36972215	off-plan	The Quayside	https://files.alnair.ae/uploads/2023/11/aa/d2/aad2eced31e7bb882ef06f7173637a3f.jpg,https://files.alnair.ae/uploads/2023/11/4b/ae/4bae0df773e4d95038a47d841aa15551.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18090582	55.26548915	Off-plan property: The Quayside by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	999009.22	2	2	2	2	132.00	132.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.240359	2025-11-02 21:43:07.240359
7650161f-7e15-46c6-aaf6-8b329ad83089	off-plan	The Diplomat Residences	https://files.alnair.ae/uploads/2023/4/c0/20/c020f8ef0bb609f3555fe2b218ecaa8e.jpg,https://files.alnair.ae/uploads/2023/4/49/46/4946659e785b0e4f4583dd6bc1130c22.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00019460	55.29708791	Off-plan property: The Diplomat Residences by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	212160.00	1	1	1	2	57.00	59.84	\N	\N	\N	\N	\N	2025-11-02 21:43:07.242573	2025-11-02 21:43:07.242573
6a6dcd6d-f2ee-44e9-b69d-3ebb6e55b2da	off-plan	The Community Motor City	https://files.alnair.ae/uploads/2023/7/f3/39/f33954c1a7ee8be8218a4507dbb0f908.png,https://files.alnair.ae/uploads/2023/7/23/3d/233d740f39a68881c92e97061030b78d.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04597949	55.23658206	Off-plan property: The Community Motor City by Aqua	be42958b-d8c4-401b-8619-0b0cedcdd5c5	180984.72	0	3	1	3	38.81	302.59	\N	\N	\N	\N	\N	2025-11-02 21:43:07.244491	2025-11-02 21:43:07.244491
6d8cf74e-6dbc-4b91-994c-27d2d66797df	off-plan	Sobha Creek Vistas	https://files.alnair.ae/uploads/2024/7/b9/f5/b9f5723db40439c9683a1ff531763ae2.jpg,https://files.alnair.ae/uploads/2024/7/d4/cc/d4cce3efdada8d277704c617ece36b06.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17982566	55.30537695	Off-plan property: Sobha Creek Vistas by Sobha	5f637246-907f-4e44-9b90-7c3065602155	472031.79	1	2	1	2	72.08	117.71	\N	\N	\N	\N	\N	2025-11-02 21:43:07.246138	2025-11-02 21:43:07.246138
f51749d9-54ed-4d89-8229-ae6c82cdf26d	off-plan	Jomana	https://files.alnair.ae/uploads/2023/4/89/05/8905f64768a8a589ccb485a0c6b46853.jpg,https://files.alnair.ae/uploads/2023/4/43/fc/43fc4b55d207d90e3b0fc6af5cbc2342.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13267200	55.19221649	Off-plan property: Jomana by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	701488.00	1	3	1	3	74.23	203.20	\N	\N	\N	\N	\N	2025-11-02 21:43:07.247662	2025-11-02 21:43:07.247662
5e4a8e19-8fd4-48a8-b172-8c4da2ca5677	off-plan	Harbour Lights	https://files.alnair.ae/uploads/2023/7/fd/06/fd06c65f37a5959aedf29c092b6e5dfb.jpg,https://files.alnair.ae/uploads/2023/7/36/09/360993da70137a5f63bfc96cc70f4f43.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.27188718	55.26844019	Off-plan property: Harbour Lights by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	1813152.00	2	2	2	2	190.55	190.55	\N	\N	\N	\N	\N	2025-11-02 21:43:07.249008	2025-11-02 21:43:07.249008
ac799b7f-cb51-459f-9413-ca6b998bb3be	off-plan	Hadley Heights	https://files.alnair.ae/uploads/2023/5/f7/6d/f76dfa2cc956051d53857cc61dad01e4.jpg,https://files.alnair.ae/uploads/2023/5/98/a2/98a2ec027436a657089d0fd9450f6c2c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05865276	55.21120994	Off-plan property: Hadley Heights by Leos Development	8f713edb-84d7-465d-8744-965901f5d7e7	201280.00	0	1	1	2	42.63	970.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.250601	2025-11-02 21:43:07.250601
a5d246a5-60d4-4e46-baff-60b076c978a8	off-plan	Erin	https://files.alnair.ae/uploads/2024/12/01/a1/01a1618f0e67f6835e59506852f301cc.png,https://files.alnair.ae/uploads/2023/5/79/f3/79f3ac86831c3a034260ba18ae461446.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20326300	55.25886569	Off-plan property: Erin by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	677280.00	1	3	1	3	75.60	220.55	\N	\N	\N	\N	\N	2025-11-02 21:43:07.251999	2025-11-02 21:43:07.251999
27a56b3a-43db-4f55-a261-09cf17591142	off-plan	Palace Residences North	https://files.alnair.ae/uploads/2025/1/64/f0/64f0a2f816f26ea88ec821648daa6a94.jpg,https://files.alnair.ae/uploads/2025/1/2d/85/2d85c84beb4db130ab1d9bccac7e3d51.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20558062	55.34809247	Off-plan property: Palace Residences North by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	516800.00	1	3	1	3	59.64	153.63	\N	\N	\N	\N	\N	2025-11-02 21:43:07.253416	2025-11-02 21:43:07.253416
002f74c5-e3fc-40f5-b090-e7026be4310b	off-plan	One Crescent	https://files.alnair.ae/uploads/2023/7/0c/de/0cde1b0d8dc046a1876809ccfdd3a834.jpg,https://files.alnair.ae/uploads/2025/3/3e/88/3e885813bd5ec64c74f61032aed9926d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13999374	55.14253180	Off-plan property: One Crescent by AHS Properties	b634bdb5-0543-4401-bc7a-d5a9dbf181a7	50320000.00	1	3	1	3	2090.32	2090.32	\N	\N	\N	\N	\N	2025-11-02 21:43:07.254836	2025-11-02 21:43:07.254836
a3bdccd8-c932-4c62-99bb-b11c9e0533c5	off-plan	Oakley Square Residences	https://files.alnair.ae/uploads/2023/4/45/45/4545c2e7c98ee0ce0d6d438050b2c232.jpg,https://files.alnair.ae/uploads/2023/7/f5/af/f5af38dd523ac01d6c4278046c65b6d5.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06000449	55.21210904	Off-plan property: Oakley Square Residences by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	421600.00	1	1	1	2	75.00	75.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.256235	2025-11-02 21:43:07.256235
4d1191fd-6692-4006-8664-3e27f2c9c466	off-plan	Binghatti Corner	https://files.alnair.ae/uploads/2023/4/96/f2/96f2f5a453cd2da8388f79243d83c49c.jpg,https://files.alnair.ae/uploads/2023/4/70/45/7045cf61af6bdb3dc013b736f0aedcfe.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06396486	55.20154059	Off-plan property: Binghatti Corner by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	225760.00	1	1	1	2	61.59	61.59	\N	\N	\N	\N	\N	2025-11-02 21:43:07.257671	2025-11-02 21:43:07.257671
67943fed-1b97-4b6a-a4b6-78bb579a0a88	off-plan	Biltmore Sufouh	https://files.alnair.ae/uploads/2024/9/88/1a/881af12890a21aded930124ca6d701e6.jpg,https://files.alnair.ae/uploads/2024/9/c8/9a/c89ade3c625b269db1312437cb50ff5b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10904457	55.18016635	Off-plan property: Biltmore Sufouh by GJ Properties	e2a13819-82db-42ef-8e4a-7f032f505483	750176.00	2	2	2	2	95.29	123.32	\N	\N	\N	\N	\N	2025-11-02 21:43:07.260103	2025-11-02 21:43:07.260103
f102ac5a-c7b9-4b2c-b251-ba810ea7e503	off-plan	Seslia Tower	https://files.alnair.ae/uploads/2024/1/12/53/1253e91972adcbe13d15a95017c46337.jpg,https://files.alnair.ae/uploads/2023/6/f8/19/f819e3bcbffc08db25d0dc37fe3934c9.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04378322	55.19487058	Off-plan property: Seslia Tower by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	163200.00	0	1	1	2	65.19	394.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.261683	2025-11-02 21:43:07.261683
9897322a-9afb-4408-8e33-3be7bfdd0ead	off-plan	Mykonos Signature	https://files.alnair.ae/uploads/2023/5/8c/3b/8c3b020f92a651e43fc6fc74bd0997e2.png,https://files.alnair.ae/uploads/2023/5/f0/a1/f0a186573599e472f5e3065888219178.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06185700	55.23674081	Off-plan property: Mykonos Signature by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	195840.00	0	0	1	2	38.58	38.58	\N	\N	\N	\N	\N	2025-11-02 21:43:07.263383	2025-11-02 21:43:07.263383
1f768ecd-0a3e-4406-8897-d34365465aeb	off-plan	ME DO RE	https://files.alnair.ae/uploads/2023/9/ee/d3/eed3905cba4717c3970449c5f3b45ac5.png,https://files.alnair.ae/uploads/2023/5/92/3f/923f83a3404f0b56ac93de82ea41d569.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06485957	55.13954913	Off-plan property: ME DO RE by Me Do Re	5ef5c942-6e90-430d-b8ba-eb466d332c4d	340000.00	0	4	1	4	41.58	542.09	\N	\N	\N	\N	\N	2025-11-02 21:43:07.264794	2025-11-02 21:43:07.264794
f2fb9ba9-7382-4d24-a3a0-3ebce598c90b	off-plan	Mar Casa	https://files.alnair.ae/uploads/2023/4/62/72/6272078a1b2babce2d11de01d6495605.jpg,https://files.alnair.ae/uploads/2023/4/09/31/09317c1ccaaa33040a42df4bd9603e5c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.27042253	55.26933190	Off-plan property: Mar Casa by Deyaar	562c648e-bd2d-453f-83dc-6595824a64d8	293760.00	0	1	1	2	35.56	71.54	\N	\N	\N	\N	\N	2025-11-02 21:43:07.266225	2025-11-02 21:43:07.266225
5c4f64c1-f842-47fd-98c2-55e7fc7e2b6e	off-plan	LIV LUX	https://files.alnair.ae/uploads/2023/5/df/e1/dfe126579ae53f012b138b379067efdf.jpg,https://files.alnair.ae/uploads/2023/5/3c/a4/3ca491fff5b61f4eaedaa9eb0cb6f88e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08330514	55.14167716	Off-plan property: LIV LUX by LIV	8c05fb6a-02a5-434a-a584-09ab3ac7d67c	3263877.06	4	5	4	5	307.14	1418.63	\N	\N	\N	\N	\N	2025-11-02 21:43:07.267597	2025-11-02 21:43:07.267597
1f474edf-21ab-44ba-8bc2-7d41ad927147	off-plan	Canal Heights 2	https://files.alnair.ae/uploads/2023/4/d6/c4/d6c41bb05c2869cefa8f08d9414fd77b.jpg,https://files.alnair.ae/uploads/2023/4/ec/36/ec3644c2f3a8ec0753b4221693293924.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18379950	55.27983940	Off-plan property: Canal Heights 2 by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	571200.00	1	3	1	3	68.44	380.05	\N	\N	\N	\N	\N	2025-11-02 21:43:07.268951	2025-11-02 21:43:07.268951
d8a3f48b-e69a-4f24-87a7-89cb677fbc5f	off-plan	Canal Heights	https://files.alnair.ae/uploads/2024/12/05/f5/05f54ca8eee54b4c941fec90986451a9.jpg,https://files.alnair.ae/uploads/2023/4/35/7e/357ed67724274fad05a3c80c65894400.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18359486	55.27863018	Off-plan property: Canal Heights by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	326400.00	0	2	1	2	42.27	148.34	\N	\N	\N	\N	\N	2025-11-02 21:43:07.270342	2025-11-02 21:43:07.270342
a6beac06-f685-421a-aa8e-656d8e00717d	off-plan	Bluewaters Bay	https://files.alnair.ae/uploads/2023/7/f6/08/f60846cfdd795aba03bb9809274aca2a.jpg,https://files.alnair.ae/uploads/2023/7/e7/4d/e74d5884f065cabb67ff83f657bbe29c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07361220	55.12413321	Off-plan property: Bluewaters Bay by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	816000.00	1	4	1	4	74.04	268.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.272411	2025-11-02 21:43:07.272411
249e78ab-2c9d-4589-916d-1e5b1147d9a8	off-plan	399 Hills Park	https://files.alnair.ae/uploads/2024/9/b3/aa/b3aa325a4b11ad56fefc16838ea8138e.jpg,https://files.alnair.ae/uploads/2024/9/a4/8f/a48f00accb53670a879eae2bb19cf261.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11823706	55.25779992	Off-plan property: 399 Hills Park by National Properties	e7a986d2-b373-4dc8-9e18-2773bb89196a	519520.00	1	1	1	2	84.91	84.91	\N	\N	\N	\N	\N	2025-11-02 21:43:07.274999	2025-11-02 21:43:07.274999
885b3c83-154a-49c1-adbd-616b46f7b678	off-plan	Golf Grand	https://files.alnair.ae/uploads/2023/4/aa/62/aa626d7a5c510524bf6be1d5ec0c526c.jpg,https://files.alnair.ae/uploads/2023/4/ac/a4/aca422d1ee52fd70b371afae18a8a2d3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12253650	55.25979527	Off-plan property: Golf Grand by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	788800.00	2	2	2	2	153.75	153.75	\N	\N	\N	\N	\N	2025-11-02 21:43:07.276381	2025-11-02 21:43:07.276381
98460df4-2727-4b19-bb52-a328440fd037	off-plan	Hotel Edge by Rotana (Navitas)	https://files.alnair.ae/uploads/2023/4/5f/f4/5ff4401bcd00102ce289d1eae67178b2.jpg,https://files.alnair.ae/uploads/2023/4/6f/5a/6f5a2e4f4061f923cf1566ba552a0b5d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.98382113	55.39267791	Off-plan property: Hotel Edge by Rotana (Navitas) by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	144799.20	0	1	1	2	32.11	73.19	\N	\N	\N	\N	\N	2025-11-02 21:43:07.277741	2025-11-02 21:43:07.277741
f569ef1d-3e4e-40de-9e72-6b7bfb8330ae	off-plan	Damac Bay	https://files.alnair.ae/uploads/2023/4/fe/fc/fefc9f6d5a64c7935809910760877f86.jpg,https://files.alnair.ae/uploads/2023/4/94/3b/943be0c6d785e5eed920219e414ce537.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09273328	55.14371930	Off-plan property: Damac Bay by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	856528.00	1	5	1	5	77.06	1222.11	\N	\N	\N	\N	\N	2025-11-02 21:43:07.279099	2025-11-02 21:43:07.279099
0418e37e-af34-4adf-b121-b3a10e12ee97	off-plan	Upside	https://files.alnair.ae/uploads/2023/3/f9/0f/f90fc0e0ce5085234efb8b2a66b34965.jpg,https://files.alnair.ae/uploads/2023/3/b6/81/b6818b2a2d9b651eac42f7411900edaf.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18503340	55.28959215	Off-plan property: Upside by SRG	c238e765-c565-4254-bdaa-cfc6436228d1	430001.54	0	1	1	2	43.71	61.23	\N	\N	\N	\N	\N	2025-11-02 21:43:07.282048	2025-11-02 21:43:07.282048
5800bdf3-9cbe-4514-8e91-35236503681e	off-plan	Seascape	https://files.alnair.ae/uploads/2023/3/ec/fb/ecfbd289b5e0de89a62ea830e89644c6.jpg,https://files.alnair.ae/uploads/2023/3/2c/98/2c980a9670195fdb257ad136bbb69ea4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.25747554	55.27744959	Off-plan property: Seascape by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	462400.00	1	1	1	2	72.09	72.09	\N	\N	\N	\N	\N	2025-11-02 21:43:07.284108	2025-11-02 21:43:07.284108
c4d086d1-66eb-4681-885e-c83dc542b555	off-plan	Savanna	https://files.alnair.ae/uploads/2024/12/95/e6/95e642bd5b55277dd044fa06971dd1b0.jpg,https://files.alnair.ae/uploads/2023/3/ec/93/ec93ef29fe3ef70178152af4452ec92c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20439650	55.35089400	Off-plan property: Savanna by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1133121.54	3	3	3	3	158.03	158.03	\N	\N	\N	\N	\N	2025-11-02 21:43:07.285459	2025-11-02 21:43:07.285459
e7fb78a2-7491-42bf-8d70-25844bf6da15	off-plan	Cedar	https://files.alnair.ae/uploads/2024/12/15/77/1577eed93abd3039b52a1da2e587f6e3.jpg,https://files.alnair.ae/uploads/2023/3/a6/84/a6849e0d5b4975c627dcd6e2585a8743.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20348261	55.35120785	Off-plan property: Cedar by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1128769.54	3	3	3	3	157.10	157.10	\N	\N	\N	\N	\N	2025-11-02 21:43:07.286886	2025-11-02 21:43:07.286886
17901d59-37d1-4b9d-9495-63b97403d116	off-plan	The Edge	https://files.alnair.ae/uploads/2023/3/16/a6/16a6011e83e72e128eec48dc58ae5e30.jpg,https://files.alnair.ae/uploads/2025/5/00/90/00900075f1d3576e7356b2710660dbca.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18882935	55.26859529	Off-plan property: The Edge by Select Group	e5e2dd29-98f2-4191-8f60-5eb6dc3cad47	367200.00	1	2	1	2	58.04	674.57	\N	\N	\N	\N	\N	2025-11-02 21:43:07.288314	2025-11-02 21:43:07.288314
52b17edc-8fc0-4714-9d32-37d10ffcf3f6	off-plan	Azizi Grand	https://files.alnair.ae/uploads/2024/12/d7/64/d7648c403ecd0e36de776b3eafa97cc0.png,https://files.alnair.ae/uploads/2024/2/5e/6b/5e6b2fa992d3d87da6dbfac6c8349aa2.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03750086	55.20433255	Off-plan property: Azizi Grand by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	323680.00	1	2	1	2	74.69	109.90	\N	\N	\N	\N	\N	2025-11-02 21:43:07.28968	2025-11-02 21:43:07.28968
e26efd42-4b7c-4d03-82ce-daadd21bd5e1	off-plan	Elvira	https://files.alnair.ae/uploads/2024/12/dd/e6/dde6cec30c1003e6c9e2501e0226b9f4.jpg,https://files.alnair.ae/uploads/2025/3/35/1a/351a5a620043ae24e18c47967a0c799a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10738950	55.24288150	Off-plan property: Elvira by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	448800.00	1	2	1	2	65.40	106.10	\N	\N	\N	\N	\N	2025-11-02 21:43:07.291206	2025-11-02 21:43:07.291206
3f5ec8c3-a9df-48ab-9db6-31179d47c85a	off-plan	Elevate	https://files.alnair.ae/uploads/2023/3/af/ed/afed8b390b2a4c5af95ff807b8f75939.jpg,https://files.alnair.ae/uploads/2023/3/d1/94/d194b5192a65a8a63250d112fd51ee1d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06494997	55.24709192	Off-plan property: Elevate by Prescott Development	b1781062-53b7-4448-a786-f2bab2542727	156400.00	0	1	1	2	39.48	88.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.292748	2025-11-02 21:43:07.292748
8841e765-98e1-4c17-b506-d4a54d1e8d59	off-plan	House IV	https://files.alnair.ae/uploads/2023/11/59/63/59630152de5bec246909c4ef00e95c36.jpg,https://files.alnair.ae/uploads/2023/3/bf/0f/bf0f0383ddfd0f92341b9e5268435b33.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11614127	55.25797293	Off-plan property: House IV by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	557600.00	1	1	1	2	75.90	75.90	\N	\N	\N	\N	\N	2025-11-02 21:43:07.294195	2025-11-02 21:43:07.294195
383399aa-a28f-43df-bdac-347e398865a7	off-plan	RA1N	https://files.alnair.ae/uploads/2023/3/f6/b1/f6b1f228c0406ceeae85d3abdad627f1.jpg,https://files.alnair.ae/uploads/2023/12/73/9f/739fc2e710f4f2a1882c303a2348c78f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05502164	55.22028454	Off-plan property: RA1N by Object One	9d128f32-1c6c-474d-b911-61803444decc	280179.58	1	1	1	2	64.00	83.15	\N	\N	\N	\N	\N	2025-11-02 21:43:07.295617	2025-11-02 21:43:07.295617
44baac96-0782-4555-a2c2-4aece0a70c96	off-plan	Verde	https://files.alnair.ae/uploads/2023/4/1f/a0/1fa054a92baae4fbf72503e26760e201.jpg,https://files.alnair.ae/uploads/2023/4/99/2f/992fab9769e3d56e61044acc7ad368b7.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07003900	55.14678745	Off-plan property: Verde by Sobha	5f637246-907f-4e44-9b90-7c3065602155	433024.00	1	2	1	2	72.00	99.16	\N	\N	\N	\N	\N	2025-11-02 21:43:07.297166	2025-11-02 21:43:07.297166
108aa867-e7c0-4dc8-9632-f9aa5d186e21	off-plan	Binghatti Onyx	https://files.alnair.ae/uploads/2023/3/a4/84/a484a2c5edf9bfc96e7e78adbb8f35cf.jpg,https://files.alnair.ae/uploads/2024/8/cf/31/cf31a11fe7a07c25670d1e308a941d5f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06158379	55.19878207	Off-plan property: Binghatti Onyx by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	312800.00	1	1	1	2	62.00	65.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.298581	2025-11-02 21:43:07.298581
5ac34360-74a5-4547-a1a5-339f3682d642	off-plan	Luma22	https://files.alnair.ae/uploads/2023/3/14/f6/14f6e9dde1b73f228fed5f0385bfbed0.jpg,https://files.alnair.ae/uploads/2023/3/65/78/65781d9508921d8466c6c62b22315c7c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06685853	55.20627468	Off-plan property: Luma22 by TownX	95773061-50af-429b-ab24-d3b738a4e758	217790.40	0	3	1	3	38.46	105.72	\N	\N	\N	\N	\N	2025-11-02 21:43:07.300003	2025-11-02 21:43:07.300003
838d8893-c298-498b-be86-086e5ecaa58e	off-plan	Neva Residences	https://files.alnair.ae/uploads/2023/2/f5/d2/f5d2142bfd27498571b4695b92eb6a81.jpg,https://files.alnair.ae/uploads/2023/2/49/07/4907f16e9e58fc17c5ae99d624834fc1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06867342	55.21485373	Off-plan property: Neva Residences by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	271728.00	1	1	1	2	881.35	881.35	\N	\N	\N	\N	\N	2025-11-02 21:43:07.302912	2025-11-02 21:43:07.302912
06672797-ced6-4e6f-b2fc-a41cf90ee67f	off-plan	Seahaven	https://files.alnair.ae/uploads/2023/2/c5/89/c589dbd8d64e28d786d3461d289ab0fb.jpg,https://files.alnair.ae/uploads/2025/3/68/78/6878b4bf8beaeb3c1170c46ab9cc4df9.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08998362	55.14428616	Off-plan property: Seahaven by Sobha	5f637246-907f-4e44-9b90-7c3065602155	992054.72	1	5	1	5	78.80	2266.70	\N	\N	\N	\N	\N	2025-11-02 21:43:07.304401	2025-11-02 21:43:07.304401
2375329f-5c0d-4088-ab48-6682f4ebeadd	off-plan	Riviera Azure	https://files.alnair.ae/uploads/2024/1/74/73/74730e4f36e54462276586e8764f3e38.jpg,https://files.alnair.ae/uploads/2024/1/d7/cb/d7cb66fd7055b0effae142b49d983a27.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17521468	55.31384375	Off-plan property: Riviera Azure by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	671296.00	1	3	1	3	65.87	718.33	\N	\N	\N	\N	\N	2025-11-02 21:43:07.306074	2025-11-02 21:43:07.306074
b6c47b3d-7138-4db7-8572-763fcb76358d	off-plan	Beach Oasis	https://files.alnair.ae/uploads/2024/9/32/91/329113e7d6cb38e7b4ca4110459e4478.jpg,https://files.alnair.ae/uploads/2024/9/39/fa/39fa931ed658151fc12b338d15cc3653.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03669700	55.23809400	Off-plan property: Beach Oasis by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	144160.00	0	0	1	2	51.19	323.67	\N	\N	\N	\N	\N	2025-11-02 21:43:07.307529	2025-11-02 21:43:07.307529
c87ae554-3568-48e0-82aa-c84a35e9ccf7	off-plan	Viewz	https://files.alnair.ae/uploads/2023/2/ca/b8/cab824468f247d40c84737aeddd2fc95.jpg,https://files.alnair.ae/uploads/2023/2/b5/6c/b56c31b4fdf7cf8a35a4843b0b72dcd8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06588669	55.14116943	Off-plan property: Viewz by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	271728.00	0	5	1	5	37.44	535.61	\N	\N	\N	\N	\N	2025-11-02 21:43:07.308864	2025-11-02 21:43:07.308864
51fd77d8-befb-4035-a927-b800ea7cc9be	off-plan	MAG 330	https://files.alnair.ae/uploads/2023/2/e2/ea/e2eabce029a8475c3c29968c6f77e521.jpg,https://files.alnair.ae/uploads/2023/2/9a/65/9a652b76e13698ce3e032d3b97084b7a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08993762	55.32786727	Off-plan property: MAG 330 by MAG Property Development	d5dfad6f-2582-4be3-89ae-c5625e33a996	209440.00	0	2	1	2	47.38	140.82	\N	\N	\N	\N	\N	2025-11-02 21:43:07.31037	2025-11-02 21:43:07.31037
43c2b54b-92d2-458d-8481-8a8bfe663658	off-plan	UH	https://files.alnair.ae/uploads/2023/2/2c/39/2c395760ec8381431ffa0f106136c8c5.jpg,https://files.alnair.ae/uploads/2023/2/b4/39/b43933f201799b7c4ee4b9ecdaf41fe7.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06640253	55.14436930	Off-plan property: UH by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	435200.00	1	2	1	2	76.55	130.30	\N	\N	\N	\N	\N	2025-11-02 21:43:07.311849	2025-11-02 21:43:07.311849
8e9c034b-8471-4ec2-868e-894359935978	off-plan	Elitz	https://files.alnair.ae/uploads/2023/1/41/bf/41bffd81b8f332ba4fdc744cd6302d63.jpg,https://files.alnair.ae/uploads/2023/3/73/3b/733b9dd770ba5f5998dcae76fd21add7.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06432566	55.21791256	Off-plan property: Elitz by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	220320.00	0	2	1	2	57.69	98.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.313345	2025-11-02 21:43:07.313345
01f86b90-1f59-4c42-8f42-dd73cde92f86	off-plan	The Highbury	https://files.alnair.ae/uploads/2023/1/d2/09/d209e72e11dd3520257a293c8c9805c1.jpg,https://files.alnair.ae/uploads/2023/1/a8/46/a846f0a954e06a9d7391815535e85dc0.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17982742	55.30667723	Off-plan property: The Highbury by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	298384.00	0	3	1	3	39.05	1350.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.31493	2025-11-02 21:43:07.31493
62df81b8-3642-404c-bc42-06691d838a84	off-plan	Ocean House	https://files.alnair.ae/uploads/2025/2/7d/71/7d71c6431b2feff62b955912eec28a1e.jpg,https://files.alnair.ae/uploads/2025/2/fb/42/fb42f022503a848108199124016b89ea.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13336959	55.15183872	Off-plan property: Ocean House by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	2475200.00	2	4	2	4	151.95	924.06	\N	\N	\N	\N	\N	2025-11-02 21:43:07.31636	2025-11-02 21:43:07.31636
fe77a9ad-902c-4ff5-b53c-6995d93d9a82	off-plan	Waves Opulence	https://files.alnair.ae/uploads/2023/4/bc/c3/bcc34cbf62166456f1939c53b419534f.jpg,https://files.alnair.ae/uploads/2023/4/ea/bc/eabc380ce48d8514186748d8fbb7e050.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17542032	55.31035513	Off-plan property: Waves Opulence by Sobha	5f637246-907f-4e44-9b90-7c3065602155	409360.00	1	2	1	2	70.78	150.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.318022	2025-11-02 21:43:07.318022
29bd3b7f-b18a-477c-a63e-a527e072306b	off-plan	Sobha One	https://files.alnair.ae/uploads/2024/12/25/34/253465a0a332ac26e21505effa857bae.png,https://files.alnair.ae/uploads/2022/12/a7/96/a796a83c317cc3b6ad0da6f9e99224ce.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18302483	55.33676148	Off-plan property: Sobha One by Sobha	5f637246-907f-4e44-9b90-7c3065602155	380800.00	1	2	1	2	51.19	538.73	\N	\N	\N	\N	\N	2025-11-02 21:43:07.319503	2025-11-02 21:43:07.319503
6d077e14-bdc5-4694-a154-8974a8cc99d7	off-plan	Zumurud Tower	https://files.alnair.ae/uploads/2025/2/58/70/58702c053fce3d906494db7808d6dcb0.jpg,https://files.alnair.ae/uploads/2025/2/ab/6a/ab6aa66ea7562d0a7905c0cbc3f80a8e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07028480	55.13383694	Off-plan property: Zumurud Tower by Zumurud Real Estate - Sole Proprietorship	b9d1bc58-eb15-408d-ad99-96b1e4c32090	1088000.00	2	2	2	2	100.00	100.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.321209	2025-11-02 21:43:07.321209
e05249ec-eca3-4d29-a295-f9d2f16a3a37	off-plan	W Residences Dubai The Palm	https://files.alnair.ae/uploads/2022/12/fe/26/fe26c25d704276e1de8139adbfd582dc.jpg,https://files.alnair.ae/uploads/2022/12/6b/bc/6bbc2e04d83c61ab571cc14efc1c2e9d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10659761	55.11177376	Off-plan property: W Residences Dubai The Palm by A S I Real Estate Development	613fbfee-a324-4dcc-9171-4250d1bdd082	13328000.00	3	4	3	4	501.58	696.68	\N	\N	\N	\N	\N	2025-11-02 21:43:07.323036	2025-11-02 21:43:07.323036
82418342-ba93-4590-befc-661bd439d04c	off-plan	The Cove Ll	https://files.alnair.ae/uploads/2023/3/7d/7d/7d7d890b5bb12521b8e257282b0791e4.jpg,https://files.alnair.ae/uploads/2023/3/9a/81/9a810b782e08d2e0190e9e8c9d149411.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20171488	55.34486812	Off-plan property: The Cove Ll by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	484160.00	1	1	1	2	74.79	74.79	\N	\N	\N	\N	\N	2025-11-02 21:43:07.324498	2025-11-02 21:43:07.324498
c03745a7-3cd9-4289-9ec4-761d6d99aa72	off-plan	The Community	https://files.alnair.ae/uploads/2023/7/c1/f6/c1f61331a75261f1255523ec6d57ec6c.png,https://files.alnair.ae/uploads/2022/12/f4/2f/f42fa67e4921ac42ed1791d45d1a4783.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04098095	55.18556249	Off-plan property: The Community by Aqua	be42958b-d8c4-401b-8619-0b0cedcdd5c5	149600.00	0	2	1	2	30.00	748.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.325879	2025-11-02 21:43:07.325879
99425d04-683b-483b-9d8f-2e87496bb320	off-plan	Urban Oasis	https://files.alnair.ae/uploads/2023/2/66/dd/66ddf9c1cd190743140df37fa2b56ea9.jpg,https://files.alnair.ae/uploads/2023/7/f3/80/f380cf69ba90820fdeeaacfd99977645.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18437926	55.25932074	Off-plan property: Urban Oasis by DarGlobal	4b39b795-8d4c-4141-b0e7-2d6e9a8ba72f	476000.00	1	2	1	2	70.98	109.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.327375	2025-11-02 21:43:07.327375
86319fbe-c92d-4202-ba22-be51cd3680dd	off-plan	UniEstate Supreme Residence	https://files.alnair.ae/uploads/2023/12/71/2a/712ab6109995bf4be48de8e21b9934a4.jpg,https://files.alnair.ae/uploads/2023/11/92/20/9220ee00dfe048a3216609c64c494071.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06413707	55.23333055	Off-plan property: UniEstate Supreme Residence by UniEstate Properties	a5117555-5abc-43cb-b185-2bbaea11e442	163200.00	0	0	1	2	41.06	41.06	\N	\N	\N	\N	\N	2025-11-02 21:43:07.330254	2025-11-02 21:43:07.330254
3779ba2a-e60f-4d70-8df0-317880f89af2	off-plan	UniEstate Prime Tower	https://files.alnair.ae/uploads/2023/12/79/d5/79d55b814f04a9902ed3e9d3d0ed2b48.jpg,https://files.alnair.ae/uploads/2023/10/26/0c/260c8685de16093efa6bcbec5d83ec3f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06502416	55.20933870	Off-plan property: UniEstate Prime Tower by UniEstate Properties	a5117555-5abc-43cb-b185-2bbaea11e442	616896.00	1	2	1	2	175.59	276.11	\N	\N	\N	\N	\N	2025-11-02 21:43:07.331735	2025-11-02 21:43:07.331735
769a61b0-4827-486a-b442-33ae5ff1d588	off-plan	UniEstate Millennium Tower	https://files.alnair.ae/uploads/2023/10/e0/cc/e0cccb99d66db42ef157cf44ce1db1c2.png,https://files.alnair.ae/uploads/2024/6/fa/51/fa51ddc99ab370aa3aa018232dab2c22.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12124600	55.37277230	Off-plan property: UniEstate Millennium Tower by UniEstate Properties	a5117555-5abc-43cb-b185-2bbaea11e442	288903.17	1	1	1	2	109.63	109.63	\N	\N	\N	\N	\N	2025-11-02 21:43:07.333185	2025-11-02 21:43:07.333185
2db6dfbe-133b-4c56-92d1-b5c0564f139d	off-plan	The Paragon	https://files.alnair.ae/uploads/2024/1/89/4b/894be3533095436f8d7812859d533547.jpg,https://files.alnair.ae/uploads/2023/2/a3/5e/a35e6418a463c19b9844baa36793f3ae.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18021956	55.27421179	Off-plan property: The Paragon by IGO	67f5aab0-438f-4003-be9f-1ae5d83638f4	299200.00	0	1	1	2	40.41	64.02	\N	\N	\N	\N	\N	2025-11-02 21:43:07.334644	2025-11-02 21:43:07.334644
168dff19-de72-435e-80d9-a0f9e66cb4e4	off-plan	The Pad	https://files.alnair.ae/uploads/2025/5/6e/6b/6e6bce0e353782ec25486384c32dba33.png,https://files.alnair.ae/uploads/2025/5/02/54/0254e677f275868854706c3963ba8886.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18475746	55.28204721	Off-plan property: The Pad by Beyond	7b5842d5-1b0f-4c98-900e-f6d8112df185	626688.00	1	2	1	2	87.79	149.47	\N	\N	\N	\N	\N	2025-11-02 21:43:07.336022	2025-11-02 21:43:07.336022
7263a409-63a0-4b65-bfa6-3fe569135e38	off-plan	The Opus	https://files.alnair.ae/uploads/2023/1/26/a9/26a94800c2f3cf9ab80b13b0d99bf810.jpg,https://files.alnair.ae/uploads/2022/12/96/6c/966c1f87dd4f578e000bb948c4905c60.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18870210	55.26689731	Off-plan property: The Opus by Omniyat	6e10dff0-abd2-49b5-9c98-71ec8f1b446f	1169600.00	1	4	1	4	0.00	0.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.337598	2025-11-02 21:43:07.337598
6f1ffd6e-3ed6-4033-965d-5926d48146ba	off-plan	Majestique Residence 2	https://files.alnair.ae/uploads/2024/12/2a/80/2a80b65e2a60006beccd09101fe90e07.jpg,https://files.alnair.ae/uploads/2024/9/b3/1b/b31b23da0c916ac5089b9ebf9f081b22.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	24.94528337	55.20952553	Off-plan property: Majestique Residence 2 by Credo Investments	fe699655-b30d-4690-b8f7-bb62ac05dadf	339982.05	2	2	2	2	87.31	104.05	\N	\N	\N	\N	\N	2025-11-02 21:43:07.33834	2025-11-02 21:43:07.33834
73d401c3-c80e-4d92-b892-579c49db3fbe	off-plan	Majestine	https://files.alnair.ae/uploads/2023/2/ac/cb/accbf88f3b8153c874ee5a2bad0f49c8.jpg,https://files.alnair.ae/uploads/2023/2/7a/4b/7a4bd95995d90bd73cefcd64b5e2b4d1.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18652400	55.28205955	Off-plan property: Majestine by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	466208.00	1	2	1	2	84.08	150.50	\N	\N	\N	\N	\N	2025-11-02 21:43:07.339765	2025-11-02 21:43:07.339765
9f005675-3a04-4ae3-bef8-89b48b97f08c	off-plan	Maimoon Gardens	https://files.alnair.ae/uploads/2025/8/91/7f/917fd24a0f363baef7db03fae10f2111.jpg,https://files.alnair.ae/uploads/2025/8/9e/e1/9ee1d4cbe282a927b0a64484fa4ece4c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06707051	55.21696195	Off-plan property: Maimoon Gardens by Fakhruddin Properties	7aa8d80f-f1da-438b-a8ac-a57d0b201cd8	429760.00	1	1	1	2	73.73	257.80	\N	\N	\N	\N	\N	2025-11-02 21:43:07.341133	2025-11-02 21:43:07.341133
2e4e1bca-0606-422e-83bb-59eb73ad0069	off-plan	Viridian	https://files.alnair.ae/uploads/2024/7/f6/24/f62407049f769d9db7516a8be7b38b35.jpg,https://files.alnair.ae/uploads/2024/7/b9/dc/b9dcdb858779b8b038095dae8aa28d27.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20492416	55.26127901	Off-plan property: Viridian by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	1047200.00	2	2	2	2	101.73	101.73	\N	\N	\N	\N	\N	2025-11-02 21:43:07.342646	2025-11-02 21:43:07.342646
f27ee6c5-0af0-41ca-865c-805e82080120	off-plan	Volare	https://files.alnair.ae/uploads/2023/3/f3/f5/f3f5a68e69a2070b085e83465cbdabbb.jpg,https://files.alnair.ae/uploads/2023/3/bb/41/bb41911c31e7f41fd3d414a50f64340a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06371203	55.24051543	Off-plan property: Volare by Vincitore	3636d588-69e3-4d16-b9a8-725d1bdf8629	209440.00	0	1	1	2	44.60	64.49	\N	\N	\N	\N	\N	2025-11-02 21:43:07.344374	2025-11-02 21:43:07.344374
af070710-bf6b-47b1-8279-211ea1f12f40	off-plan	Vida Dubai Marina	https://files.alnair.ae/uploads/2023/3/af/2e/af2ed176b6dab444ffe29280c23c02a8.jpg,https://files.alnair.ae/uploads/2023/3/f1/1a/f11a35c5b3f1660302a8b7f5fb1bcedd.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07232937	55.13627529	Off-plan property: Vida Dubai Marina by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1942865.54	2	2	2	2	146.51	147.81	\N	\N	\N	\N	\N	2025-11-02 21:43:07.346043	2025-11-02 21:43:07.346043
9d134e3e-11a8-4481-bdc6-1693928e15dd	off-plan	Vida Dubai Mall	https://files.alnair.ae/uploads/2024/7/2a/95/2a9581ffa44fa4d026a0f4165cef2a00.png,https://files.alnair.ae/uploads/2024/7/1c/9b/1c9bb443b0a2d72133feb6eb51428da6.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19696995	55.28420426	Off-plan property: Vida Dubai Mall by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	748000.00	1	1	1	2	63.02	63.02	\N	\N	\N	\N	\N	2025-11-02 21:43:07.347499	2025-11-02 21:43:07.347499
dfd87bf2-bbab-4bef-b5bc-f34de4e197c8	off-plan	Tria	https://files.alnair.ae/uploads/2024/12/36/74/3674a1760970d4fe3e21df4ebc7e7446.jpg,https://files.alnair.ae/uploads/2022/12/c7/80/c7808678ddf4a885f521f0f60dbcd802.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12525300	55.37367543	Off-plan property: Tria by Deyaar	562c648e-bd2d-453f-83dc-6595824a64d8	168640.00	0	1	1	2	44.89	74.85	\N	\N	\N	\N	\N	2025-11-02 21:43:07.348907	2025-11-02 21:43:07.348907
215df368-2544-4a81-89d3-6030028d4f5e	off-plan	Jenna And Warda Apartments	https://files.alnair.ae/uploads/2024/10/2b/2f/2b2fb812fc7a974d6a15a69ff4ca2199.jpg,https://files.alnair.ae/uploads/2024/10/6a/6a/6a6a691879f5887eb74e31b4f6cf8b84.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.00450433	55.29372633	Off-plan property: Jenna And Warda Apartments by Nshama	3a546c29-2c56-4a6b-bfdc-7a95cecd8dc8	380256.00	2	2	2	2	87.70	87.70	\N	\N	\N	\N	\N	2025-11-02 21:43:07.350353	2025-11-02 21:43:07.350353
87fc0a56-278e-43e5-9b00-bb36272b036d	off-plan	Torino	https://files.alnair.ae/uploads/2023/4/09/58/0958ba037111bd50a2d745a009a64bb9.jpg,https://files.alnair.ae/uploads/2023/4/a3/c4/a3c40d032dcb1518f61abe1b1f4f3700.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06582501	55.23214855	Off-plan property: Torino by Oro 24	b959b878-b6ea-49ed-be77-fe3cf58e4ac1	230928.00	1	1	1	2	57.95	57.95	\N	\N	\N	\N	\N	2025-11-02 21:43:07.352003	2025-11-02 21:43:07.352003
f329e459-531d-4663-ae84-40940e818fda	off-plan	The Sterling	https://files.alnair.ae/uploads/2023/3/09/aa/09aa4593b65aebcdede1d50be5e1a5e8.jpg,https://files.alnair.ae/uploads/2023/3/00/15/001596c223ab8a7dd2765ec8fffdc781.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18891691	55.28199345	Off-plan property: The Sterling by Beyond	7b5842d5-1b0f-4c98-900e-f6d8112df185	518160.00	1	4	1	4	65.41	277.77	\N	\N	\N	\N	\N	2025-11-02 21:43:07.353317	2025-11-02 21:43:07.353317
e1fac8c6-8dc6-4f33-be50-5812a38918ac	off-plan	The Residences At Marina Gate 1	https://files.alnair.ae/uploads/2023/2/b5/72/b572f96202da3546015f9bc8ff0266ad.jpg,https://files.alnair.ae/uploads/2023/6/e1/aa/e1aa709c5878b9e1bb6ca40c6e2343ac.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08671247	55.14799097	Off-plan property: The Residences At Marina Gate 1 by Select Group	e5e2dd29-98f2-4191-8f60-5eb6dc3cad47	870400.00	2	2	2	2	123.07	123.07	\N	\N	\N	\N	\N	2025-11-02 21:43:07.354724	2025-11-02 21:43:07.354724
3f6deca2-42c7-4855-a5c6-a056bfae7192	off-plan	The Residence | Burj Khalifa	https://files.alnair.ae/uploads/2024/12/c8/65/c865daaff7312fcc2b9fa559dd172a7e.jpg,https://files.alnair.ae/uploads/2024/12/80/94/80945988871c93019edf01d8f3197e07.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19620841	55.27401634	Off-plan property: The Residence | Burj Khalifa by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1686400.00	2	3	2	3	532.80	2038.04	\N	\N	\N	\N	\N	2025-11-02 21:43:07.357185	2025-11-02 21:43:07.357185
c49210be-0e6a-4b29-a8db-b58b7fb3c07b	off-plan	The Nook	https://files.alnair.ae/uploads/2024/12/11/eb/11eba49772afebf70d343be1f048a06d.jpg,https://files.alnair.ae/uploads/2023/7/66/38/6638a67dc3c86d16d7b9befacacabcc3.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02526309	55.10349134	Off-plan property: The Nook by Wasl	e0b7a2e8-0ba5-44cc-8ae0-f2450afb524a	296480.00	2	2	2	2	72.20	72.20	\N	\N	\N	\N	\N	2025-11-02 21:43:07.358681	2025-11-02 21:43:07.358681
cabf0b04-b982-48bf-907b-8a1ab74e5822	off-plan	The Grand	https://files.alnair.ae/uploads/2023/6/8f/ee/8fee219635d3f9fe8d05dcdddc18294e.jpg,https://files.alnair.ae/uploads/2023/10/f4/80/f4804ff8c799e2ccf1ddad742b6b086b.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20739500	55.34262355	Off-plan property: The Grand by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	660960.00	1	3	1	3	211.54	804.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.360157	2025-11-02 21:43:07.360157
f72fb721-5a55-473e-8585-fd7051771940	off-plan	The Address - The Blvd	https://files.alnair.ae/uploads/2023/10/4a/60/4a60c1d44b6b9fe7b6737dc1daf7ce85.jpg,https://files.alnair.ae/uploads/2023/10/b4/ea/b4eae4cbfb16f462e3b1bef5d06ee997.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20117467	55.27615415	Off-plan property: The Address - The Blvd by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1768000.00	2	2	2	2	118.08	118.08	\N	\N	\N	\N	\N	2025-11-02 21:43:07.361609	2025-11-02 21:43:07.361609
a78b4d3d-5f18-4424-a9da-a432efd64ee4	off-plan	Marina Star	https://files.alnair.ae/uploads/2023/4/9f/55/9f55e2878e5ad1bb021d3bd7c1769d22.jpg,https://files.alnair.ae/uploads/2023/7/7a/a8/7aa8b126a9de11340653e1f22a17a9fa.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06862436	55.13148893	Off-plan property: Marina Star by Condor	552c1026-d364-4ea2-95ff-65710cce5b5d	456031.12	0	4	1	4	47.20	562.39	\N	\N	\N	\N	\N	2025-11-02 21:43:07.363138	2025-11-02 21:43:07.363138
97631918-a0a0-42f1-8d6c-a5492a13bee5	off-plan	Marina Shores	https://files.alnair.ae/uploads/2023/6/ea/6e/ea6e0065ca57c80a9cbbb40ddb84d8e9.jpg,https://files.alnair.ae/uploads/2022/12/ae/43/ae4346e7d188094287efa68259647c2f.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08279224	55.14345010	Off-plan property: Marina Shores by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1088000.00	2	2	2	2	112.88	112.88	\N	\N	\N	\N	\N	2025-11-02 21:43:07.364845	2025-11-02 21:43:07.364845
02aefe3b-7ad6-4f3e-8ba5-618819b13e69	off-plan	Madinat Jumeriah Living	https://files.alnair.ae/uploads/2024/2/fb/3d/fb3d7729b38adb3d463ce16bee597272.jpg,https://files.alnair.ae/uploads/2024/2/53/d3/53d3d59cfe838b2ced45ce197128456e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13607961	55.18919572	Off-plan property: Madinat Jumeriah Living by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	1387200.00	2	2	2	2	124.68	371.08	\N	\N	\N	\N	\N	2025-11-02 21:43:07.366141	2025-11-02 21:43:07.366141
eb711164-d540-4985-a591-3ab870cb86c0	off-plan	LIV Residence	https://files.alnair.ae/uploads/2023/10/c6/f7/c6f745af4cc34f054105657d16a24bc8.jpg,https://files.alnair.ae/uploads/2023/8/5d/fe/5dfef249e14db40d5d9db921f20ca4a6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08093818	55.14072217	Off-plan property: LIV Residence by LIV	8c05fb6a-02a5-434a-a584-09ab3ac7d67c	1087877.06	2	2	2	2	122.73	122.73	\N	\N	\N	\N	\N	2025-11-02 21:43:07.367449	2025-11-02 21:43:07.367449
7eb596ce-7130-4162-b88b-f566025dbfaf	off-plan	LIV Marina	https://files.alnair.ae/uploads/2023/10/08/21/08214eab5e2bdd0bffaad0433833af3a.jpg,https://files.alnair.ae/uploads/2025/2/7c/55/7c55e67facf0c0637636c38c85abf4b5.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08491925	55.14457323	Off-plan property: LIV Marina by LIV	8c05fb6a-02a5-434a-a584-09ab3ac7d67c	1264677.06	1	4	1	4	75.88	847.65	\N	\N	\N	\N	\N	2025-11-02 21:43:07.368861	2025-11-02 21:43:07.368861
72428705-80c9-4bd0-a0d4-94d6232a0747	off-plan	The 8	https://files.alnair.ae/uploads/2024/12/81/8e/818ece76b352a7737b425a8ee75a67f5.png,https://files.alnair.ae/uploads/2023/10/b6/c2/b6c25173e132d5309fec4eaa716edb47.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11781315	55.10987712	Off-plan property: The 8 by C Fourteen	01165192-e54e-4462-a26a-1d25fb43ef67	1767999.73	2	4	2	4	122.26	464.79	\N	\N	\N	\N	\N	2025-11-02 21:43:07.370553	2025-11-02 21:43:07.370553
82f81557-8780-4f88-8fce-d3586635706a	off-plan	Tfg One Hotel	https://files.alnair.ae/uploads/2023/10/7b/5c/7b5c9a9b5fbf61579f05bbf471d7225a.png,https://files.alnair.ae/uploads/2023/10/1d/b1/1db1ec861f269d856493f7d1bc98edaf.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07113284	55.13637265	Off-plan property: Tfg One Hotel by The First Group	2b26e7a0-973d-4322-a459-9a15ca2bf683	244800.00	0	0	1	2	32.61	32.61	\N	\N	\N	\N	\N	2025-11-02 21:43:07.372185	2025-11-02 21:43:07.372185
2fee53ac-cb7d-49ee-8437-7c0c219f2982	off-plan	Tamani Arts Offices	https://files.alnair.ae/uploads/2024/10/be/6e/be6e3a2d3a53d8683605a67c2b8d09e0.jpg,https://files.alnair.ae/uploads/2024/10/95/de/95deee4fb9ef88d931a7ad3ceb1c65b8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18727493	55.28082937	Off-plan property: Tamani Arts Offices by The Developer Properties	d85b9fd0-43cf-4fc6-b55c-be404a13216d	299200.00	0	0	1	2	40.00	40.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.374885	2025-11-02 21:43:07.374885
38bb72d6-ced1-4410-b201-f232ec66c83a	off-plan	Sunrise Bay	https://files.alnair.ae/uploads/2023/6/ba/f7/baf7e7734ae1f058851b270e92d3b9b0.jpg,https://files.alnair.ae/uploads/2023/6/ce/2c/ce2cc4880ae645bdd0961847523f33d8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09741352	55.13999484	Off-plan property: Sunrise Bay by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1033600.00	2	2	2	2	119.19	129.55	\N	\N	\N	\N	\N	2025-11-02 21:43:07.376515	2025-11-02 21:43:07.376515
11cf1966-6cac-421d-99bc-0a7ab63c8777	off-plan	Sun Point Dubai	https://files.alnair.ae/uploads/2023/5/5e/66/5e6686b50464cd1694608a38f0ef35dc.png,https://files.alnair.ae/uploads/2023/5/d9/7b/d97b698ae2f1cc16a970a59dc180c37e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02577591	55.19115508	Off-plan property: Sun Point Dubai by SOL Properties (managed by You&Co)	088d080f-1e60-46e1-933b-30b62400b221	254808.24	2	3	2	3	59.54	134.92	\N	\N	\N	\N	\N	2025-11-02 21:43:07.378445	2025-11-02 21:43:07.378445
9b8bcf41-74e8-4af8-b113-4c2111a110ba	off-plan	Studio One	https://files.alnair.ae/uploads/2023/6/a9/aa/a9aa55746270e5cc280ddc92aef74a4e.jpg,https://files.alnair.ae/uploads/2023/6/d2/80/d280095a2797bc862a0625dcbc235b46.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06886881	55.12883959	Off-plan property: Studio One by Select Group	e5e2dd29-98f2-4191-8f60-5eb6dc3cad47	388960.00	1	1	1	2	55.00	55.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.380453	2025-11-02 21:43:07.380453
a8581e8c-0025-4005-b298-36263a9de59e	off-plan	Sparkle Towers	https://files.alnair.ae/uploads/2024/9/08/c6/08c6fa1490ace0309691171551d092a5.jpg,https://files.alnair.ae/uploads/2024/9/05/44/0544161a7cbec99b5661f8052e59d813.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07167348	55.13182797	Off-plan property: Sparkle Towers by Tebyan Real Estate Development Enterprises	9c2c1f0d-f2cc-4b8a-8805-b8342818550c	544000.00	1	1	1	2	963.26	963.26	\N	\N	\N	\N	\N	2025-11-02 21:43:07.383761	2025-11-02 21:43:07.383761
9475f76d-b664-461e-8052-72f8b2adbc97	off-plan	Sol Bay	https://files.alnair.ae/uploads/2025/1/ac/9d/ac9d4a0803779a36114cad73d1a42a14.jpg,https://files.alnair.ae/uploads/2025/1/48/76/48766a978af7f1ea20c35303c188e3c4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17928436	55.27321592	Off-plan property: Sol Bay by SOL Properties	da59d484-2f29-4f4b-849b-6f69819597ac	544000.00	1	1	1	2	78.93	225.74	\N	\N	\N	\N	\N	2025-11-02 21:43:07.385218	2025-11-02 21:43:07.385218
da5b1346-0f7f-4c7a-aa9a-71ffafc956c7	off-plan	Waves Grande	https://files.alnair.ae/uploads/2023/6/73/12/7312fb48a3124618465c2bd3b37f2159.jpg,https://files.alnair.ae/uploads/2023/5/41/0f/410f4fc18d2810256ea2c6f1cad7ee4a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17516798	55.30915762	Off-plan property: Waves Grande by Sobha	5f637246-907f-4e44-9b90-7c3065602155	612000.00	2	2	2	2	10.22	10.22	\N	\N	\N	\N	\N	2025-11-02 21:43:07.386641	2025-11-02 21:43:07.386641
709de45c-8af9-46a0-8bfc-1109f3b9e144	off-plan	Sobha Hartland Waves	https://files.alnair.ae/uploads/2024/7/b6/cf/b6cf6800305326a94b7a8796fca35965.jpg,https://files.alnair.ae/uploads/2024/7/77/d9/77d911f2ec126606125c5ae6b0a8e913.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17503986	55.30954806	Off-plan property: Sobha Hartland Waves by Sobha	5f637246-907f-4e44-9b90-7c3065602155	380800.00	1	1	1	2	48.68	48.68	\N	\N	\N	\N	\N	2025-11-02 21:43:07.388059	2025-11-02 21:43:07.388059
2cbc9d87-4493-48ce-9abe-3f38935d5ff9	off-plan	The Crest	https://files.alnair.ae/uploads/2024/12/e4/1f/e41f39bf4ca2c36ff67ac6c244bcabca.jpg,https://files.alnair.ae/uploads/2023/2/7e/d3/7ed3e562dd139d93d97704015e4a02d3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17701760	55.31432901	Off-plan property: The Crest by Sobha	5f637246-907f-4e44-9b90-7c3065602155	326400.00	1	2	1	2	47.75	513.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.390467	2025-11-02 21:43:07.390467
b90b17f4-1575-4c4b-a0eb-64f12cf581dd	off-plan	One Park Avenue	https://files.alnair.ae/uploads/2023/6/0c/ed/0cedb9ae3223e04948514b39e24d2a76.jpg,https://files.alnair.ae/uploads/2023/6/00/61/0061ab81949a78366bde0aabb32455f1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17850923	55.30894891	Off-plan property: One Park Avenue by Sobha	5f637246-907f-4e44-9b90-7c3065602155	707200.00	2	2	2	2	108.56	108.56	\N	\N	\N	\N	\N	2025-11-02 21:43:07.391956	2025-11-02 21:43:07.391956
ca434548-bd03-4f14-ba37-c4ae9ea26e50	off-plan	Hartland Greens Phase III	https://files.alnair.ae/uploads/2024/7/76/29/7629bc1cb5d066e96544424616760dbe.png,https://files.alnair.ae/uploads/2024/7/6b/33/6b33233985e29b890a6e6d7ab95e0fff.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17792082	55.30877461	Off-plan property: Hartland Greens Phase III by Sobha	5f637246-907f-4e44-9b90-7c3065602155	255680.00	0	0	1	2	44.95	44.95	\N	\N	\N	\N	\N	2025-11-02 21:43:07.393361	2025-11-02 21:43:07.393361
7eeb2ced-a9b2-4d96-b3db-0387d16feb01	off-plan	Crest Grande	https://files.alnair.ae/uploads/2023/1/64/9e/649e78b1193ca89417fbf9bf5c47025a.jpg,https://files.alnair.ae/uploads/2023/1/c9/33/c933ca45f1b449857971f528db27e42e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17623850	55.31265950	Off-plan property: Crest Grande by Sobha	5f637246-907f-4e44-9b90-7c3065602155	402560.00	1	2	1	2	69.49	123.56	\N	\N	\N	\N	\N	2025-11-02 21:43:07.394672	2025-11-02 21:43:07.394672
1c11e9b6-2a76-4298-a9d8-ed1a310fc070	off-plan	Creek Vistas Reserve	https://files.alnair.ae/uploads/2024/12/4b/21/4b21bac6de2c8b1a40136125ae643acd.png,https://files.alnair.ae/uploads/2024/5/c6/36/c636f70b6a57ea27401b79ef95719de5.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17976012	55.30429199	Off-plan property: Creek Vistas Reserve by Sobha	5f637246-907f-4e44-9b90-7c3065602155	348160.00	1	1	1	2	50.67	50.67	\N	\N	\N	\N	\N	2025-11-02 21:43:07.396317	2025-11-02 21:43:07.396317
814e075f-e81c-443b-9d9b-1aebfc67b45e	off-plan	Creek Vistas Heights	https://files.alnair.ae/uploads/2023/3/4c/68/4c680c9ec84bb4ed9bc2540759207080.jpg,https://files.alnair.ae/uploads/2023/4/80/59/8059a677c69e8066998306cd910c948b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17911996	55.30138191	Off-plan property: Creek Vistas Heights by Sobha	5f637246-907f-4e44-9b90-7c3065602155	394400.00	1	2	1	2	60.20	611.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.397733	2025-11-02 21:43:07.397733
6917c729-e5ae-4926-a8d3-3438b23a8a69	off-plan	Skyz By Danube	https://files.alnair.ae/uploads/2023/6/ac/5e/ac5e29b0a9c11c66ae64413185efe1d8.jpg,https://files.alnair.ae/uploads/2023/6/3e/9a/3e9aeab2640856e9473544bd7321d1ed.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05634345	55.24076253	Off-plan property: Skyz By Danube by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	188659.20	0	0	1	2	33.72	33.72	\N	\N	\N	\N	\N	2025-11-02 21:43:07.399086	2025-11-02 21:43:07.399086
8a8ca2d4-fa7c-4e82-8138-57125825efe3	off-plan	Six Senses Residences	https://files.alnair.ae/uploads/2023/3/9d/e9/9de9cdb3cccb379a27746f94c908522a.jpg,https://files.alnair.ae/uploads/2023/1/20/c3/20c35fdf6b6509b770f76a7a979739ec.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10123401	55.11656016	Off-plan property: Six Senses Residences by Select Group	e5e2dd29-98f2-4191-8f60-5eb6dc3cad47	4896000.00	2	4	2	4	184.13	2440.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.401479	2025-11-02 21:43:07.401479
5de448df-978f-4ddc-8c8f-480072e6c97c	off-plan	Seven Hotel And Apartments The Palm	https://files.alnair.ae/uploads/2024/7/8c/46/8c46e97ac65eac7ca5072279010fcaad.jpg,https://files.alnair.ae/uploads/2024/7/3f/f3/3ff36ccd2927192e7962a91a7bbdd8f4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11152008	55.13863206	Off-plan property: Seven Hotel And Apartments The Palm by Seven Tides	f605b496-c28f-452d-b005-c5f1a77748fc	416160.00	0	3	1	3	38.46	155.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.402896	2025-11-02 21:43:07.402896
bada2f6b-307e-4692-885e-32f4db327aa6	off-plan	Golf Views Seven City	https://files.alnair.ae/uploads/2023/7/8f/cf/8fcfdfaa81170969ce95b18138e3965e.jpg,https://files.alnair.ae/uploads/2023/5/2a/67/2a67b4fe851a8895c4f557ec91be2559.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07924645	55.15420819	Off-plan property: Golf Views Seven City by Seven Tides	f605b496-c28f-452d-b005-c5f1a77748fc	176800.00	0	3	1	3	35.86	1517.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.404241	2025-11-02 21:43:07.404241
a3de5ac6-38a1-4531-9a6f-349219094109	off-plan	Serenia Residences The Palm	https://files.alnair.ae/uploads/2024/9/09/a5/09a5b26eb12cfb54e1de7310020556f5.jpg,https://files.alnair.ae/uploads/2024/9/7a/fa/7afab48dc677d74eee1cb51cc3511e6b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13206330	55.15197212	Off-plan property: Serenia Residences The Palm by Palma Development	83505ce5-4591-436e-9a41-2c69c0108b0f	6745600.00	3	3	3	3	512.81	512.81	\N	\N	\N	\N	\N	2025-11-02 21:43:07.405654	2025-11-02 21:43:07.405654
91f18bb3-cc6d-4e24-a841-f985969a4b24	off-plan	Serenia Living	https://files.alnair.ae/uploads/2024/9/c9/1f/c91f8dad81a65eb3e55073a8290ecebf.jpg,https://files.alnair.ae/uploads/2024/9/e7/a5/e7a57421ff1238f90cf9be586c9053b6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12418568	55.11224880	Off-plan property: Serenia Living by Palma Development	83505ce5-4591-436e-9a41-2c69c0108b0f	13600000.00	4	4	4	4	607.31	607.31	\N	\N	\N	\N	\N	2025-11-02 21:43:07.407014	2025-11-02 21:43:07.407014
08c1ace8-58b3-440b-9f76-b9527509f325	off-plan	Samana Park Views	https://files.alnair.ae/uploads/2023/10/f8/1f/f81f8cfe22e69d41618b5a80bb8482bc.jpg,https://files.alnair.ae/uploads/2022/12/19/80/19808a7f518022cb1c1c1be1bbce470c.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06658554	55.24822766	Off-plan property: Samana Park Views by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	516800.00	2	2	2	2	102.66	102.66	\N	\N	\N	\N	\N	2025-11-02 21:43:07.408352	2025-11-02 21:43:07.408352
bb8c74c9-84b6-4037-87e3-c320e756b37a	off-plan	Samana Hills	https://files.alnair.ae/uploads/2024/12/79/40/7940efd6001872d9d3206cdc4e29e864.jpg,https://files.alnair.ae/uploads/2022/12/bd/0b/bd0b8cb2fa346780ed86070dd4ee45ee.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06770867	55.24783861	Off-plan property: Samana Hills by Samana	a42c2981-0130-49cb-b00d-dc732e2d88c0	233920.00	2	2	2	2	55.00	55.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.409731	2025-11-02 21:43:07.409731
b1447e6f-4866-40ce-9a5d-4f1ba9f39329	off-plan	Reva Residences	https://files.alnair.ae/uploads/2022/12/d3/d4/d3d49e9f882527b572893002d4d6d525.jpg,https://files.alnair.ae/uploads/2022/12/99/a9/99a938c5ba5b2fea680e2e95d7659736.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18780812	55.28306698	Off-plan property: Reva Residences by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	326400.00	1	1	1	2	43.80	43.80	\N	\N	\N	\N	\N	2025-11-02 21:43:07.411323	2025-11-02 21:43:07.411323
2b89a573-c3ca-4344-b789-6667e845eab0	off-plan	Regalia	https://files.alnair.ae/uploads/2024/12/b3/b6/b3b64b7dd4cf821a7254560d7ab9ec33.jpg,https://files.alnair.ae/uploads/2024/12/b5/d3/b5d32a004c380d855be45117ad00a2f0.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18488406	55.29283580	Off-plan property: Regalia by Deyaar	562c648e-bd2d-453f-83dc-6595824a64d8	269280.00	0	2	1	2	41.34	202.99	\N	\N	\N	\N	\N	2025-11-02 21:43:07.412826	2025-11-02 21:43:07.412826
e011fac7-a55e-46a8-9348-4ca2d0c96d4b	off-plan	Prime Residency 3	https://files.alnair.ae/uploads/2024/12/ab/7f/ab7fe71fa9571557a9570e4e0a08e1af.png,https://files.alnair.ae/uploads/2022/12/51/59/51597d1d9c562c52010c8ef9b6e07ad1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01939535	55.14539344	Off-plan property: Prime Residency 3 by Prescott Development	b1781062-53b7-4448-a786-f2bab2542727	149600.00	0	0	1	2	37.33	40.13	\N	\N	\N	\N	\N	2025-11-02 21:43:07.414279	2025-11-02 21:43:07.414279
4329c50f-d095-4511-a2f4-0652e52b1ada	off-plan	Peninsula Two	https://files.alnair.ae/uploads/2024/12/48/90/489097978bc9d0e0a21d23403e3af4fa.jpg,https://files.alnair.ae/uploads/2024/12/e5/4c/e54c208c01b18c842cd503b97495463b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18558729	55.26686902	Off-plan property: Peninsula Two by Select Group	e5e2dd29-98f2-4191-8f60-5eb6dc3cad47	307360.00	0	0	1	2	36.37	38.01	\N	\N	\N	\N	\N	2025-11-02 21:43:07.415618	2025-11-02 21:43:07.415618
44a55ccf-94c7-4361-9f9e-64ec550015d2	off-plan	Peninsula Four	https://files.alnair.ae/uploads/2023/3/c5/bd/c5bd85e51661bacf22c93cfc11ac1a8b.jpg,https://files.alnair.ae/uploads/2025/5/3b/1f/3b1ff65d816c15cb714f3d100463d09d.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18432100	55.26773483	Off-plan property: Peninsula Four by Select Group	e5e2dd29-98f2-4191-8f60-5eb6dc3cad47	340000.00	0	2	1	2	46.45	135.08	\N	\N	\N	\N	\N	2025-11-02 21:43:07.416944	2025-11-02 21:43:07.416944
938b16aa-d36f-4e2f-a731-52b6f88f6223	off-plan	Pearlz	https://files.alnair.ae/uploads/2023/3/94/2d/942d3af118e7275a88aef20f275a2aff.jpg,https://files.alnair.ae/uploads/2022/12/b7/d5/b7d5754138f071e341eed91107f1c4a2.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02755952	55.15506327	Off-plan property: Pearlz by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	350880.00	1	1	1	2	97.18	97.18	\N	\N	\N	\N	\N	2025-11-02 21:43:07.418412	2025-11-02 21:43:07.418412
670a72c6-99cd-4a3b-b1bf-a3b51de388b0	off-plan	Park Point	https://files.alnair.ae/uploads/2023/6/a0/af/a0af99ade6719af992165702fd90d021.jpg,https://files.alnair.ae/uploads/2023/6/b8/fe/b8fec53ea9253a26fdcaeec285ab15f4.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.11113937	55.24412619	Off-plan property: Park Point by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	924800.00	3	3	3	3	146.00	146.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.419792	2025-11-02 21:43:07.419792
52824e6f-4975-4843-bb0a-55d37baaf30e	off-plan	Paramount Tower Hotel & Residences	https://files.alnair.ae/uploads/2024/12/07/31/07317f11af4b3b3883ef2d8505143f88.png,https://files.alnair.ae/uploads/2023/4/83/56/8356a60cdce593e8687f78dbff951fe3.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19335978	55.26529575	Off-plan property: Paramount Tower Hotel & Residences by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	217600.00	0	1	1	2	44.69	97.49	\N	\N	\N	\N	\N	2025-11-02 21:43:07.421188	2025-11-02 21:43:07.421188
3fd1ab36-28d7-46d3-90cd-2f1d1399976b	off-plan	Palm Beach Towers	https://files.alnair.ae/uploads/2023/3/54/6a/546a088b7a58ca992c7ded95af3bbb93.jpg,https://files.alnair.ae/uploads/2023/3/f5/76/f576a0bf318313167652338955a75277.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10068401	55.15509311	Off-plan property: Palm Beach Towers by Nakheel	d190bf02-5336-42e6-bba1-91ee1ab4b2d5	952000.00	1	4	1	4	88.77	1412.31	\N	\N	\N	\N	\N	2025-11-02 21:43:07.422688	2025-11-02 21:43:07.422688
74435ce9-04e6-48cd-a709-8d8c14982aca	off-plan	Orla	https://files.alnair.ae/uploads/2023/1/78/39/7839b890dc40d01dd8869b2e78c5d1fd.jpg,https://files.alnair.ae/uploads/2023/5/45/c0/45c0f563e27ab3e3efdc13bd42d1a9d0.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12366356	55.11230083	Off-plan property: Orla by Omniyat	6e10dff0-abd2-49b5-9c98-71ec8f1b446f	14144000.00	3	4	3	4	683.02	977.99	\N	\N	\N	\N	\N	2025-11-02 21:43:07.425474	2025-11-02 21:43:07.425474
713286cc-4bc9-465d-84f1-33c115b6c41f	off-plan	Opalz	https://files.alnair.ae/uploads/2022/12/7f/6d/7f6d9a025d114b43c201ef0d6627713e.jpg,https://files.alnair.ae/uploads/2023/3/87/92/8792cff0b6018df2be34b3960db63e3f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06942473	55.24662190	Off-plan property: Opalz by Danube	c59901e7-ae45-4aec-a968-46bd2e627a3e	195111.04	0	0	1	2	42.20	43.30	\N	\N	\N	\N	\N	2025-11-02 21:43:07.426942	2025-11-02 21:43:07.426942
0dccdd31-fc25-4044-9b00-d7d77ff6f823	off-plan	One Za'abeel	https://files.alnair.ae/uploads/2024/9/0e/b5/0eb522699ae4e4fa0c7ab7a1b6642491.jpg,https://files.alnair.ae/uploads/2024/9/35/02/3502ccbadaef82966f05044f658a1fa7.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.22725387	55.29207587	Off-plan property: One Za'abeel by Ithra Dubai	a7f8b821-2ea7-47e5-8816-9e0faa539e24	1604800.00	0	2	1	2	79.43	205.10	\N	\N	\N	\N	\N	2025-11-02 21:43:07.429522	2025-11-02 21:43:07.429522
b41a5875-1dd3-4a12-b7b3-219c05d1f0a9	off-plan	One Canal	https://files.alnair.ae/uploads/2023/7/93/ed/93ed084d09a034133fb01a647b163cd8.jpg,https://files.alnair.ae/uploads/2025/2/d9/ab/d9ab39165ada8f9346d4bbe3eca69f30.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18806333	55.24498811	Off-plan property: One Canal by AHS Properties	b634bdb5-0543-4401-bc7a-d5a9dbf181a7	8840000.00	4	4	4	4	464.79	464.79	\N	\N	\N	\N	\N	2025-11-02 21:43:07.431123	2025-11-02 21:43:07.431123
8a62e849-eaae-4345-a285-9a5a7446761f	off-plan	O10	https://files.alnair.ae/uploads/2023/7/d6/a2/d6a2b0687724d81bc96796fbe1ac9309.jpg,https://files.alnair.ae/uploads/2022/12/e4/97/e4979bd6a4b4bfd1f563807e70704904.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.21129566	55.31435832	Off-plan property: O10 by Aqua	be42958b-d8c4-401b-8619-0b0cedcdd5c5	225760.00	0	0	1	2	41.68	41.75	\N	\N	\N	\N	\N	2025-11-02 21:43:07.432705	2025-11-02 21:43:07.432705
23e0868e-e635-4297-9b2b-7209b4db9d5e	off-plan	Nobles Tower	https://files.alnair.ae/uploads/2023/2/e7/d3/e7d3a7d2c2e6e737185021ccb3e7c2fb.jpg,https://files.alnair.ae/uploads/2023/2/8a/e9/8ae9127f0a300af562df7e4fd8dcd448.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18469783	55.29021710	Off-plan property: Nobles Tower by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	455056.00	1	2	1	2	71.00	124.49	\N	\N	\N	\N	\N	2025-11-02 21:43:07.434098	2025-11-02 21:43:07.434098
2761bf02-a02a-4f96-be31-2f3dca138813	off-plan	New Dubai Gate 1	https://files.alnair.ae/uploads/2025/5/a0/83/a08386d0bcfe7db02d81aa9013b94555.png,https://files.alnair.ae/uploads/2025/5/e0/33/e033de3bd2d77df595f6cc8b1f47f5ff.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07624614	55.14623566	Off-plan property: New Dubai Gate 1 by Bonyan International Investment Group	528973c5-b454-4be0-a1f7-eebcabb2a9e9	231200.00	0	0	1	2	34.47	34.47	\N	\N	\N	\N	\N	2025-11-02 21:43:07.436771	2025-11-02 21:43:07.436771
a8e58df9-684f-46cd-ae28-a58e31faf550	off-plan	Muraba Dia	https://files.alnair.ae/uploads/2023/2/f3/92/f392b7896bfdb47e08f2f0e666b86a05.jpg,https://files.alnair.ae/uploads/2023/5/d2/4d/d24d3f5bfc63b43b723e0581af79b260.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12594872	55.15414663	Off-plan property: Muraba Dia by Muraba Properties	7476b6f6-9c5d-44f4-80e2-f254031f4964	7195569.60	4	5	4	5	445.19	626.63	\N	\N	\N	\N	\N	2025-11-02 21:43:07.438103	2025-11-02 21:43:07.438103
7584f284-f239-470b-bee5-fd088df784e5	off-plan	Mudon Views	https://files.alnair.ae/uploads/2024/12/8f/0c/8f0c67ccb24e60d5d7fa9c64021fc21f.png,https://files.alnair.ae/uploads/2023/5/8b/14/8b1466617a5241e5390f4c255ded6879.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.02357552	55.26523755	Off-plan property: Mudon Views by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	1414400.00	4	4	4	4	468.51	468.51	\N	\N	\N	\N	\N	2025-11-02 21:43:07.439468	2025-11-02 21:43:07.439468
502f8214-525b-4c99-8085-ab07f002d7b0	off-plan	Mr. C Residences Jumeirah	https://files.alnair.ae/uploads/2024/9/f7/ad/f7ad4c0d9aeadbbe071f185295b3ec07.jpg,https://files.alnair.ae/uploads/2024/9/e2/96/e2961eeb9602d9afcb2ee591698cec16.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19354998	55.24188310	Off-plan property: Mr. C Residences Jumeirah by Alta Real Estate Development	8f550297-85dc-49ea-b052-09148a7f9709	14960000.00	4	4	4	4	541.00	541.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.441093	2025-11-02 21:43:07.441093
8c4313ee-0d37-48cd-8668-d67e75b21c44	off-plan	Mon Reve	https://files.alnair.ae/uploads/2024/10/a0/b1/a0b18a97ed6aba8f290132d4d0755bf7.jpg,https://files.alnair.ae/uploads/2024/10/51/7a/517adf8f0070ee6ef3f7029fd4d1b286.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19404477	55.28276525	Off-plan property: Mon Reve by Credo Investments	fe699655-b30d-4690-b8f7-bb62ac05dadf	765151.78	2	4	2	4	167.23	250.84	\N	\N	\N	\N	\N	2025-11-02 21:43:07.442514	2025-11-02 21:43:07.442514
cba7ac68-bde0-4803-88bf-c0543d554ff0	off-plan	Mbl Royal	https://files.alnair.ae/uploads/2023/7/68/be/68be6aeccafffbec2aecb757cfc58ff4.png,https://files.alnair.ae/uploads/2025/3/80/bb/80bb11ea4b5356762a682763e8a0fc51.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06630599	55.13981663	Off-plan property: Mbl Royal by MAG Property Development	d5dfad6f-2582-4be3-89ae-c5625e33a996	1278400.00	3	3	3	3	209.96	209.96	\N	\N	\N	\N	\N	2025-11-02 21:43:07.443888	2025-11-02 21:43:07.443888
c52c82b2-3d68-47ac-82c1-02959100c1ad	off-plan	Marquis Signature	https://files.alnair.ae/uploads/2023/7/27/cf/27cf06520d2d681e352f7efc86e7ccc0.png,https://files.alnair.ae/uploads/2022/12/95/9d/959dc22023b1b1de0710cf3a93a8c461.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06298375	55.23313466	Off-plan property: Marquis Signature by Marquis	ff247dca-88f3-41ab-96c8-84b760a6c768	462400.00	2	2	2	2	121.12	121.12	\N	\N	\N	\N	\N	2025-11-02 21:43:07.445269	2025-11-02 21:43:07.445269
7b602d8e-0eb5-45ae-92a7-2b9d9d4c4fe3	off-plan	Marquise Square Tower	https://files.alnair.ae/uploads/2023/6/88/ee/88ee5780f931e6295b67e0ef31028415.jpg,https://files.alnair.ae/uploads/2025/6/15/ff/15fff8eb7ada9ad0c52783b554d76b64.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18534530	55.27622804	Off-plan property: Marquise Square Tower by SRG	c238e765-c565-4254-bdaa-cfc6436228d1	874993.54	1	3	1	3	85.38	85.38	\N	\N	\N	\N	\N	2025-11-02 21:43:07.446805	2025-11-02 21:43:07.446805
0643ef9a-7a13-4387-82c0-f49a44518b31	off-plan	Marina Vista	https://files.alnair.ae/uploads/2024/12/e0/aa/e0aabcecedd3e691d26dc814eb91c035.jpg,https://files.alnair.ae/uploads/2024/12/94/50/945046873716439e7b363ac5e0657e9c.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09827289	55.14096022	Off-plan property: Marina Vista by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	802400.00	1	3	1	3	80.96	744.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.448177	2025-11-02 21:43:07.448177
b003aad8-1fe2-45d6-acfe-d8e1433a9c4e	off-plan	Lamaa	https://files.alnair.ae/uploads/2024/12/0b/d9/0bd9108bb953c5faffbec1863985ad2a.png,https://files.alnair.ae/uploads/2022/12/46/78/4678e3ac26ba693de44ac6268b834268.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13049695	55.19315177	Off-plan property: Lamaa by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	788800.00	2	4	2	4	109.97	293.02	\N	\N	\N	\N	\N	2025-11-02 21:43:07.449568	2025-11-02 21:43:07.449568
7f6ef1ea-51b9-4e4b-b098-61dcbd6c199a	off-plan	Lake Terrace	https://files.alnair.ae/uploads/2023/7/1a/aa/1aaad9a131cea270ea9873a2fee65cc4.jpg,https://files.alnair.ae/uploads/2023/7/75/58/7558cb804129c8e2b8d7218616518292.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07004368	55.14115602	Off-plan property: Lake Terrace by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	350880.00	1	1	1	2	66.78	66.78	\N	\N	\N	\N	\N	2025-11-02 21:43:07.450882	2025-11-02 21:43:07.450882
996668a5-1990-460b-8599-7adba639eb9a	off-plan	Lake City Tower	https://files.alnair.ae/uploads/2023/2/e8/66/e8661d8aa6bb7509b223a9f03b58292f.jpg,https://files.alnair.ae/uploads/2023/10/3e/84/3e84fe7ec20fa4975f670e1bf6657964.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07054423	55.14077615	Off-plan property: Lake City Tower by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	258400.00	1	1	1	2	67.63	79.88	\N	\N	\N	\N	\N	2025-11-02 21:43:07.452219	2025-11-02 21:43:07.452219
2eea67a6-67ad-4778-a7f3-6e0623542ce0	off-plan	Jumeirah Living Business Bay	https://files.alnair.ae/uploads/2023/3/13/55/1355cf6c56697274c257f54b66417863.jpg,https://files.alnair.ae/uploads/2023/3/9f/73/9f7381876d58bddaed68f7a6b29baf2d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18314402	55.26502203	Off-plan property: Jumeirah Living Business Bay by Select Group	e5e2dd29-98f2-4191-8f60-5eb6dc3cad47	2584000.00	2	2	2	2	189.46	189.46	\N	\N	\N	\N	\N	2025-11-02 21:43:07.453805	2025-11-02 21:43:07.453805
9999f1e2-373b-4491-a5b5-900bd3422dc6	off-plan	Joya Blanca Residences	https://files.alnair.ae/uploads/2024/9/03/48/03482796e8684a4c875f5fd37b47b599.png,https://files.alnair.ae/uploads/2024/9/ca/90/ca9008ea076540908801bc2fadce66fd.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06476339	55.23084238	Off-plan property: Joya Blanca Residences by Green Yard Properties Development	4f6abe53-a3ea-461e-acab-913d3731d66e	350880.00	1	1	1	2	71.96	71.96	\N	\N	\N	\N	\N	2025-11-02 21:43:07.455496	2025-11-02 21:43:07.455496
9165060a-7e27-43fa-8a5b-48d03cc807d5	off-plan	Jadeel	https://files.alnair.ae/uploads/2023/5/39/51/39513c0d733a75d96fc95fa8460501a4.jpg,https://files.alnair.ae/uploads/2023/5/45/cb/45cb2bd7bb3ed6e6461dc067bb011106.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13341304	55.19136213	Off-plan property: Jadeel by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	693600.00	1	2	1	2	70.33	109.35	\N	\N	\N	\N	\N	2025-11-02 21:43:07.45683	2025-11-02 21:43:07.45683
b918590e-d569-4f85-8e64-d74c52981475	off-plan	Hills Park	https://files.alnair.ae/uploads/2023/6/7f/27/7f27987fa6030251745d3ffabbba6b59.jpg,https://files.alnair.ae/uploads/2023/6/2c/f3/2cf311dedb53928c004def1b3e3961bb.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10072869	55.24439062	Off-plan property: Hills Park by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	408000.00	1	1	1	2	62.71	62.71	\N	\N	\N	\N	\N	2025-11-02 21:43:07.458149	2025-11-02 21:43:07.458149
3e78e08e-682a-4c53-b4cb-64e5c9d48801	off-plan	Harbour Views	https://files.alnair.ae/uploads/2024/12/03/9f/039fb33b7793c98fb2bf203bdf32067c.jpg,https://files.alnair.ae/uploads/2023/6/83/eb/83ebfc62c04e2ae727a596dcf81f7a72.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20556575	55.34526462	Off-plan property: Harbour Views by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	516800.00	1	1	1	2	709.00	709.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.459538	2025-11-02 21:43:07.459538
af8d45f0-856a-44bf-8ef5-2ab71cc9aac1	off-plan	Harbour Gate	https://files.alnair.ae/uploads/2024/12/0e/c0/0ec0c19476827e9ff22fb0c070e5350f.jpg,https://files.alnair.ae/uploads/2023/3/77/63/776370214670538d400595e75d2364ec.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20786906	55.34730489	Off-plan property: Harbour Gate by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	775200.00	2	2	2	2	1164.00	1164.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.460804	2025-11-02 21:43:07.460804
313ac1af-3c7d-4bc4-bff7-1c22a49085ec	off-plan	Ghalia	https://files.alnair.ae/uploads/2023/7/09/6c/096ccb8f4fee0cb4726c0183d9b17447.png,https://files.alnair.ae/uploads/2023/7/77/14/7714c0049db6cc66e1075ed17cee80f6.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05308347	55.19908142	Off-plan property: Ghalia by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	244800.00	1	1	1	2	62.68	62.68	\N	\N	\N	\N	\N	2025-11-02 21:43:07.46208	2025-11-02 21:43:07.46208
98fb2117-586c-4f68-973d-bda7fc50ca85	off-plan	Gemini Splendor	https://files.alnair.ae/uploads/2024/9/23/5c/235c8b0f6ad3b11342a0080fc6ee4622.jpg,https://files.alnair.ae/uploads/2024/9/9c/d1/9cd1e866c8966850e0ceb4167d72e2b9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17741225	55.31326203	Off-plan property: Gemini Splendor by Gemini Property Developers	ab7309fe-f4bc-4c87-a6a0-e6d0cf4a4cd6	534480.00	1	2	1	2	112.00	115.27	\N	\N	\N	\N	\N	2025-11-02 21:43:07.46542	2025-11-02 21:43:07.46542
cd2246e8-2c71-41bc-a180-60482a0ec1f7	off-plan	Forte	https://files.alnair.ae/uploads/2022/12/60/b2/60b2cb968b78665e85205e070cedbed4.jpg,https://files.alnair.ae/uploads/2022/12/f9/16/f916c8fdb2d89c0f6396a1015a9f261a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19553715	55.26903704	Off-plan property: Forte by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1305600.00	3	3	3	3	1561.00	1672.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.466808	2025-11-02 21:43:07.466808
98711a64-ab95-441c-96ea-f06197427624	off-plan	The Five JVC	https://files.alnair.ae/uploads/2023/3/fe/80/fe803a5f3fffc3c80c93a7701de5929c.png,https://files.alnair.ae/uploads/2023/3/10/c4/10c493bcbe5cff4427d1af9b26596d1d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05408798	55.20672396	Off-plan property: The Five JVC by Five Holdings	c636e99b-1eeb-4ac6-81f9-4e4277b67681	271999.73	0	0	1	2	44.92	49.06	\N	\N	\N	\N	\N	2025-11-02 21:43:07.469241	2025-11-02 21:43:07.469241
c620da31-9289-48f0-b7e3-c9e29f80f705	off-plan	Fawad	https://files.alnair.ae/uploads/2024/12/b7/b7/b7b79d31fde2db0b24db423f0c6f490e.png,https://files.alnair.ae/uploads/2023/2/62/9f/629ff3515803b4667c275840c66e1b17.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20841876	55.31558610	Off-plan property: Fawad by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	640079.92	1	3	1	3	64.21	155.95	\N	\N	\N	\N	\N	2025-11-02 21:43:07.471725	2025-11-02 21:43:07.471725
8c11ad58-a537-420b-8707-ac4f27fa3f8d	off-plan	Farhad Azizi Residence	https://files.alnair.ae/uploads/2024/12/a0/bc/a0bc5c7ada4b4b282dff9beb4009948c.jpg,https://files.alnair.ae/uploads/2023/12/92/c2/92c23828e93f8acbe5a3a132c0473662.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20881675	55.31510599	Off-plan property: Farhad Azizi Residence by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	311609.46	1	3	1	3	29.89	830.70	\N	\N	\N	\N	\N	2025-11-02 21:43:07.473143	2025-11-02 21:43:07.473143
ed93a3bb-9402-46de-99ea-dd880199b0bd	off-plan	Chic Tower	https://files.alnair.ae/uploads/2023/4/11/47/1147247180f11fbb79b834902bab310b.jpg,https://files.alnair.ae/uploads/2023/4/d6/74/d6743903ba7caaa3855d854705fe8d43.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18354815	55.26142775	Off-plan property: Chic Tower by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	312800.00	0	4	1	4	40.23	772.59	\N	\N	\N	\N	\N	2025-11-02 21:43:07.504117	2025-11-02 21:43:07.504117
75dc2754-4aca-4162-b46b-789d2c5be1ad	off-plan	Escan Marina Tower	https://files.alnair.ae/uploads/2024/10/5c/09/5c09ddc2b0d76a11193c60327498bb3e.jpg,https://files.alnair.ae/uploads/2025/5/ac/9b/ac9bdb9cce8bedb369e33fed681c6737.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06818676	55.13298339	Off-plan property: Escan Marina Tower by Escan Real Estate	6766f261-20e5-4ab5-9ba8-065c34360da0	224400.00	0	0	1	2	33.04	33.04	\N	\N	\N	\N	\N	2025-11-02 21:43:07.474758	2025-11-02 21:43:07.474758
d126c9e5-b270-4bde-aba2-50e2781b2dc0	off-plan	Equiti Arcade	https://files.alnair.ae/uploads/2023/5/7f/fe/7ffe115aa989da836cfc07f111c0a9ba.jpg,https://files.alnair.ae/uploads/2023/5/61/dc/61dc9c347c294d24c16b3278cd2996f6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03310124	55.13964998	Off-plan property: Equiti Arcade by B N H Real Estate Developer	9ece548a-5211-4966-b1e1-e45c7943fa4f	484160.00	2	2	2	2	110.47	110.47	\N	\N	\N	\N	\N	2025-11-02 21:43:07.47608	2025-11-02 21:43:07.47608
8f5104a2-93d8-4fba-a596-f1b2f0d78d16	off-plan	Elysee 3	https://files.alnair.ae/uploads/2023/4/9f/e0/9fe0b214dda770c4206c233ca4da4953.jpg,https://files.alnair.ae/uploads/2023/6/34/6a/346ad7c2608d274c9529c840339e9f0f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05578722	55.19702900	Off-plan property: Elysee 3 by Pantheon	a8c243a7-ac10-4ed9-a660-d05ee9b7ca60	184960.00	0	0	1	2	36.70	38.09	\N	\N	\N	\N	\N	2025-11-02 21:43:07.477679	2025-11-02 21:43:07.477679
b75d2e03-bce2-491d-9694-7a13eff9f0f9	off-plan	Beach House	https://files.alnair.ae/uploads/2023/11/d0/f0/d0f064294b4728734dff4aaf053727b9.jpg,https://files.alnair.ae/uploads/2023/2/14/78/14787f0eed0c050800f20d889e05b3d1.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13982439	55.14112920	Off-plan property: Beach House by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	1521838.64	1	3	1	3	106.00	190.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.479229	2025-11-02 21:43:07.479229
8b625f9f-87e3-46cb-971d-0c62a4b6c949	off-plan	Elite Downtown Residence	https://files.alnair.ae/uploads/2024/6/be/2e/be2e512933fabd9da6af66a0bf5be361.jpg,https://files.alnair.ae/uploads/2024/6/4a/a0/4aa0c083073a9e2ad1b22c364cd4d71d.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18587200	55.27812950	Off-plan property: Elite Downtown Residence by Triplanet Range Developements	43bfecc8-91eb-4c77-9696-ff85ecd40e95	337280.00	0	1	1	2	47.98	93.56	\N	\N	\N	\N	\N	2025-11-02 21:43:07.482105	2025-11-02 21:43:07.482105
c3f6ae6d-37c9-4ebc-97a7-b20f4b553ee4	off-plan	Elegance Tower	https://files.alnair.ae/uploads/2023/2/2a/60/2a60fedb261cd49801b08a03f1b46025.jpg,https://files.alnair.ae/uploads/2023/4/ef/31/ef31a572bef94b0ea8f978baaa3cf90a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19566179	55.28423376	Off-plan property: Elegance Tower by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	598400.00	1	1	1	2	71.34	815.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.483507	2025-11-02 21:43:07.483507
ea95774f-dd5f-43b2-80c7-d48da30253ae	off-plan	Downtown Views 2	https://files.alnair.ae/uploads/2024/12/a6/8f/a68f3acee177c94e381573a86e7b8ab7.jpg,https://files.alnair.ae/uploads/2023/6/9c/64/9c64856de44ad331b1062148ba63117a.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20287757	55.28134767	Off-plan property: Downtown Views 2 by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	897600.00	2	2	2	2	111.21	111.21	\N	\N	\N	\N	\N	2025-11-02 21:43:07.484867	2025-11-02 21:43:07.484867
0e211dc3-13c2-4b55-a9f1-ebae01dffcdf	off-plan	Towers By Paramount	https://files.alnair.ae/uploads/2023/4/84/70/8470c49c3c0e47b59f2b221e2e15c826.jpg,https://files.alnair.ae/uploads/2023/4/74/de/74dee10260a3e8a59f971a709da08052.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18598612	55.29175906	Off-plan property: Towers By Paramount by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	320443.20	0	4	1	4	42.00	260.21	\N	\N	\N	\N	\N	2025-11-02 21:43:07.48619	2025-11-02 21:43:07.48619
249233b1-08e4-4ade-984c-c119a95e3d7b	off-plan	Kiara	https://files.alnair.ae/uploads/2024/12/0f/38/0f38cd90b4952cf6ace435909e687a02.jpg,https://files.alnair.ae/uploads/2023/4/dd/7d/dd7de13f6ef0e640907112e0cb862774.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.01876292	55.24570379	Off-plan property: Kiara by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	248757.60	0	2	1	2	44.41	121.92	\N	\N	\N	\N	\N	2025-11-02 21:43:07.48776	2025-11-02 21:43:07.48776
178acd50-5962-4285-a7d7-28b441b20b8b	off-plan	Safa One	https://files.alnair.ae/uploads/2023/4/39/38/39382ecd0059d3b13c813a540a7acd2e.jpg,https://files.alnair.ae/uploads/2023/4/09/98/0998669248f1d102077f0a9d05547673.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18211575	55.24857606	Off-plan property: Safa One by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	753788.16	2	4	2	4	114.55	552.97	\N	\N	\N	\N	\N	2025-11-02 21:43:07.489179	2025-11-02 21:43:07.489179
54b5c173-66c6-4a87-864c-d96b3962b740	off-plan	Creekside 18	https://files.alnair.ae/uploads/2023/3/7c/27/7c27fa1fa630c21b77107d543f5c34e7.jpg,https://files.alnair.ae/uploads/2023/3/80/16/8016fa414dd9cbcdf13fa5dd9958b756.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20399104	55.34469143	Off-plan property: Creekside 18 by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	953873.54	3	3	3	3	148.27	148.27	\N	\N	\N	\N	\N	2025-11-02 21:43:07.490637	2025-11-02 21:43:07.490637
33245d67-336d-4731-8d11-d20596063507	off-plan	Creek Rise	https://files.alnair.ae/uploads/2023/3/9a/45/9a45b98e8658a4672eff0b0829b27566.jpg,https://files.alnair.ae/uploads/2023/3/c3/3b/c33b40f024cc0dea7a1e9cb92f7e9190.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20867457	55.34596857	Off-plan property: Creek Rise by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	783360.00	2	2	2	2	1107.00	1107.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.491939	2025-11-02 21:43:07.491939
3ee9f2f0-9216-4606-829a-c58f96c5cf96	off-plan	Creek Gate	https://files.alnair.ae/uploads/2022/12/6a/ac/6aac0497583eb3eb85ef3a0a7ce78699.jpg,https://files.alnair.ae/uploads/2022/12/19/fc/19fc272a4f717fb17f30ce248169e1d2.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20597498	55.34680836	Off-plan property: Creek Gate by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1202209.54	3	3	3	3	138.43	138.98	\N	\N	\N	\N	\N	2025-11-02 21:43:07.493231	2025-11-02 21:43:07.493231
5b8d3414-7e51-4f8c-a7e2-8886e20b1bfa	off-plan	Creek Edge	https://files.alnair.ae/uploads/2022/12/3f/ed/3fedb0daaf58570de7e7e942bafff0d3.jpg,https://files.alnair.ae/uploads/2022/12/be/ed/beedfa0b99fdc4c8ac14b78c66f9b43f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20988965	55.34539491	Off-plan property: Creek Edge by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	516800.00	1	1	1	2	65.79	65.79	\N	\N	\N	\N	\N	2025-11-02 21:43:07.494538	2025-11-02 21:43:07.494538
dfee8951-3c4a-4edf-9eb9-c3042ba4573e	off-plan	Creek Crescent	https://files.alnair.ae/uploads/2023/6/dd/74/dd7480b97e5bf49511c5e8ddac1bdb65.png,https://files.alnair.ae/uploads/2023/6/a5/c0/a5c084bafab1cc2802d041400e9cb929.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20977835	55.34668993	Off-plan property: Creek Crescent by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	516800.00	1	2	1	2	63.55	104.93	\N	\N	\N	\N	\N	2025-11-02 21:43:07.497028	2025-11-02 21:43:07.497028
c08dda70-bcce-4b2e-bb19-694009b68d40	off-plan	Cloud Towers	https://files.alnair.ae/uploads/2022/12/49/3b/493bef5154ccecc7f219dab5812dc14c.png,https://files.alnair.ae/uploads/2022/12/d3/b4/d3b4ddcd4e1880a565074263e64ee2c9.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.03852268	55.18038601	Off-plan property: Cloud Towers by Tiger Properties	727f3a59-7a12-4d51-ad65-563e2b9ff558	375734.54	1	3	1	3	69.02	192.71	\N	\N	\N	\N	\N	2025-11-02 21:43:07.498631	2025-11-02 21:43:07.498631
5b5d13ef-bcaa-455d-b5aa-d1bb4729e1a4	off-plan	City Center Residences	https://files.alnair.ae/uploads/2024/9/fb/e5/fbe598c5c0d23b539496b9a17b1937d8.jpg,https://files.alnair.ae/uploads/2022/12/52/0b/520bbf97450845fb024f00bf01396266.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18887719	55.28036284	Off-plan property: City Center Residences by Dar Al Arkan Properties	9fa4bb66-b625-4832-b192-317c10120d60	598400.00	1	3	1	3	70.07	135.92	\N	\N	\N	\N	\N	2025-11-02 21:43:07.501218	2025-11-02 21:43:07.501218
6f2a4322-b100-4a18-ab7c-3beda4bc4da4	off-plan	Churchill Tower	https://files.alnair.ae/uploads/2024/11/32/34/32344a1de6cce79abfbc7406c5779c2b.jpg,https://files.alnair.ae/uploads/2024/11/9c/9c/9c9ca782b389300cde13c9aeac04721e.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18085727	55.26275933	Off-plan property: Churchill Tower by Emirates National Investment	538c3f6b-28d9-4c28-986f-15abbd0a3c9d	338640.00	1	1	1	2	72.65	72.65	\N	\N	\N	\N	\N	2025-11-02 21:43:07.502812	2025-11-02 21:43:07.502812
1d57b29c-0cc0-4ece-af23-4fc653af5bfe	off-plan	Celadon	https://files.alnair.ae/uploads/2024/8/32/42/3242b30d43a808eb4b95a108388f9e06.jpg,https://files.alnair.ae/uploads/2024/8/89/b4/89b431992703f2f4ffc2a0a8ca95f18f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20273546	55.25972262	Off-plan property: Celadon by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	971040.00	2	2	2	2	122.00	122.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.505499	2025-11-02 21:43:07.505499
f64e27b6-acb8-4ee7-885c-c9e7e8af4079	off-plan	Cavalli Couture	https://files.alnair.ae/uploads/2024/12/9d/0e/9d0e419091330c6682de4bf18fd6299d.jpg,https://files.alnair.ae/uploads/2025/5/44/f5/44f5f70c3b0f6ebdf380bcdb16165a35.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18931439	55.24299531	Off-plan property: Cavalli Couture by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	5957888.00	3	5	3	5	364.15	716.34	\N	\N	\N	\N	\N	2025-11-02 21:43:07.507681	2025-11-02 21:43:07.507681
fe0a51ea-2260-49ff-b37b-3b05691821c7	off-plan	Cavalli Tower	https://files.alnair.ae/uploads/2022/12/92/20/9220ee4626343bbd690ae2e1f6a4e207.jpg,https://files.alnair.ae/uploads/2023/4/71/04/710406cd57ba15e94e8ddb131938600f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09135030	55.15084597	Off-plan property: Cavalli Tower by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	859519.73	2	3	2	3	120.23	304.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.50916	2025-11-02 21:43:07.50916
a9a3de60-9b10-40e0-b6da-1fa4d5c3da95	off-plan	Canal Front Residences	https://files.alnair.ae/uploads/2025/7/7a/53/7a53da2fb897d102964eca16656f5a15.jpg,https://files.alnair.ae/uploads/2025/6/8b/16/8b1602d5bfe41de78167efe872391e23.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18854744	55.24702433	Off-plan property: Canal Front Residences by Nakheel	d190bf02-5336-42e6-bba1-91ee1ab4b2d5	707200.00	1	3	1	3	87.14	172.71	\N	\N	\N	\N	\N	2025-11-02 21:43:07.51058	2025-11-02 21:43:07.51058
44880829-324b-40d7-98eb-f140fb28ba75	off-plan	Burj Royale	https://files.alnair.ae/uploads/2024/8/65/57/6557d3ba1fb720971f4a42f74e9448be.jpg,https://files.alnair.ae/uploads/2022/12/5d/7d/5d7d6d4398613ee71c4ae4ae3fc19910.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19149953	55.28037484	Off-plan property: Burj Royale by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	544000.00	1	1	1	2	55.00	55.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.511975	2025-11-02 21:43:07.511975
586f35cd-a740-41a5-8071-c349227dc903	off-plan	Burj Khalifa	https://files.alnair.ae/uploads/2024/12/eb/54/eb54085445b4e3cb5cd8a7393b36a1bb.jpg,https://files.alnair.ae/uploads/2024/8/0f/48/0f48ba35830076243f2e8ff72fa544c8.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.19687893	55.27432501	Off-plan property: Burj Khalifa by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1414400.00	2	2	2	2	146.00	2109.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.513508	2025-11-02 21:43:07.513508
9bb8174d-7748-4074-bd33-9f11635aa7fc	off-plan	Binghatti Nova	https://files.alnair.ae/uploads/2023/5/d3/44/d344c20ab1328b5c9b2eb8b09e8d4c02.jpg,https://files.alnair.ae/uploads/2025/5/bf/8d/bf8d7246d3b01b82e78d48e947bad82f.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05204773	55.21936320	Off-plan property: Binghatti Nova by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	233920.00	1	1	1	2	58.92	58.92	\N	\N	\N	\N	\N	2025-11-02 21:43:07.514879	2025-11-02 21:43:07.514879
e394900c-b033-4a45-b541-cd9332f792c9	off-plan	Binghatti Crest	https://files.alnair.ae/uploads/2023/6/1b/96/1b96a3b9211d90a77c5561c5571965fb.jpg,https://files.alnair.ae/uploads/2025/5/57/42/57420d8b1ffdac892d7c80df91e3e6ff.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.04886008	55.20663344	Off-plan property: Binghatti Crest by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	244800.00	1	1	1	2	58.00	58.79	\N	\N	\N	\N	\N	2025-11-02 21:43:07.51622	2025-11-02 21:43:07.51622
73083f2c-6df6-43ee-845e-b99c75dd1bfa	off-plan	Binghatti Canal	https://files.alnair.ae/uploads/2023/6/72/66/7266dbf53b826941ada870774ffe5f89.jpg,https://files.alnair.ae/uploads/2025/5/d2/95/d29529443ff89a60269aabc2061cb3c3.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18613058	55.28615184	Off-plan property: Binghatti Canal by Binghatti	1aeb7f20-ff15-4fed-a830-8f9e00dfdbb8	333200.00	0	1	1	2	41.81	45.40	\N	\N	\N	\N	\N	2025-11-02 21:43:07.517512	2025-11-02 21:43:07.517512
09f0eebf-366b-492e-a127-e5beda172742	off-plan	Berkeley Place	https://files.alnair.ae/uploads/2024/12/79/9c/799cb11d8db3b1373bd357760a2568af.jpg,https://files.alnair.ae/uploads/2023/2/c2/bc/c2bcfd394c428e4c2b83119eeb86965a.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17865897	55.31130704	Off-plan property: Berkeley Place by Ellington	d5689e4a-18d7-4a2a-87f6-5aa334be13a9	595680.00	1	1	1	2	88.57	88.57	\N	\N	\N	\N	\N	2025-11-02 21:43:07.519052	2025-11-02 21:43:07.519052
d340e31d-0122-464a-a59e-6afa025955c0	off-plan	Beach Vista	https://files.alnair.ae/uploads/2024/12/e6/84/e684e7bd4182335ed9b85c0fc49df826.jpg,https://files.alnair.ae/uploads/2024/12/08/0d/080d882d2c8742f9af1741385a974197.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09844288	55.13972662	Off-plan property: Beach Vista by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	1332800.00	0	0	1	2	105.35	105.35	\N	\N	\N	\N	\N	2025-11-02 21:43:07.5204	2025-11-02 21:43:07.5204
78709f68-c1cf-4c72-8823-3712e2e9ab68	off-plan	Beach Mansion	https://files.alnair.ae/uploads/2023/6/81/7a/817adbe49dac3d4b19b01d3eff0b8ddd.jpg,https://files.alnair.ae/uploads/2022/12/24/24/24241c652bfdce66c6df6df939255c64.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09927702	55.14196600	Off-plan property: Beach Mansion by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	2040000.00	3	3	3	3	148.74	157.01	\N	\N	\N	\N	\N	2025-11-02 21:43:07.521736	2025-11-02 21:43:07.521736
25193a86-3cd8-4b1f-a66c-870275163f2c	off-plan	Beach Isle	https://files.alnair.ae/uploads/2022/12/11/3d/113df2dae63ab6822d47696c7f610fb5.jpg,https://files.alnair.ae/uploads/2022/12/3d/7d/3d7d58ba66ceecacbd3c6c84ec5f5d3b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09941105	55.14068159	Off-plan property: Beach Isle by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	802400.00	1	1	1	2	71.04	71.04	\N	\N	\N	\N	\N	2025-11-02 21:43:07.523073	2025-11-02 21:43:07.523073
2e625f94-bde7-45cd-af6a-31575c1f7a9e	off-plan	Bay Central West & Central Towers	https://files.alnair.ae/uploads/2024/8/47/f5/47f5a2b7e5bbf29be113ed6ddcc4cc1a.jpg,https://files.alnair.ae/uploads/2024/8/6c/8c/6c8cb0914f09fd55124048cbf8a9a0a2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.07860250	55.13791283	Off-plan property: Bay Central West & Central Towers by Select Group	e5e2dd29-98f2-4191-8f60-5eb6dc3cad47	502928.00	1	1	1	2	79.62	79.62	\N	\N	\N	\N	\N	2025-11-02 21:43:07.524377	2025-11-02 21:43:07.524377
3983fef4-3404-4a9f-8172-197684c2d5a0	off-plan	Riviera Reve	https://files.alnair.ae/uploads/2023/2/9d/94/9d945a87a6722842a159742fbdafc6c2.jpg,https://files.alnair.ae/uploads/2024/11/a0/85/a08505e35a299e10bb6e4e8cff42a338.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17483737	55.31346783	Off-plan property: Riviera Reve by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	896784.00	1	4	1	4	73.86	433.02	\N	\N	\N	\N	\N	2025-11-02 21:43:07.527391	2025-11-02 21:43:07.527391
c19318a2-ed28-4d38-9723-13bbf8449fc6	off-plan	Riviera Beachfront	https://files.alnair.ae/uploads/2023/2/4d/a4/4da46add3443fc2a59715cdeaf1a2190.jpg,https://files.alnair.ae/uploads/2023/2/f2/c8/f2c8f277e395ee8cc59eb811cf61a944.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17360490	55.31188931	Off-plan property: Riviera Beachfront by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	236640.00	0	2	1	2	31.12	296.55	\N	\N	\N	\N	\N	2025-11-02 21:43:07.529161	2025-11-02 21:43:07.529161
6dbef49f-7f89-4ae0-a88b-732c4824098d	off-plan	Riviera 41	https://files.alnair.ae/uploads/2023/3/db/bf/dbbf43dcb97426f9413340d0abea9d21.jpg,https://files.alnair.ae/uploads/2023/3/bf/5e/bf5eb7d18bbcc7ce448f7d36c41cc03b.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17324553	55.31137759	Off-plan property: Riviera 41 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	244800.00	0	0	1	2	415.70	415.70	\N	\N	\N	\N	\N	2025-11-02 21:43:07.530872	2025-11-02 21:43:07.530872
1ef36346-f971-465e-b2e6-d03388f7d04b	off-plan	Riviera 36	https://files.alnair.ae/uploads/2023/2/e4/60/e460fb128b84b00364914bfaf84be36d.jpg,https://files.alnair.ae/uploads/2023/2/22/d9/22d927819b9d387e887cb7ef6b7d5f8e.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17284767	55.30813839	Off-plan property: Riviera 36 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	190400.00	0	0	1	2	30.00	31.96	\N	\N	\N	\N	\N	2025-11-02 21:43:07.532193	2025-11-02 21:43:07.532193
1f1b5c73-4911-468a-b825-94e151ac1cbe	off-plan	Riviera 35	https://files.alnair.ae/uploads/2024/12/ae/05/ae0549164478a5b194056f6a448c4158.jpg,https://files.alnair.ae/uploads/2023/2/3a/6f/3a6fdaeaacdd4c78c0e847bc52102064.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17165700	55.30643901	Off-plan property: Riviera 35 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	217600.00	0	0	1	2	34.47	34.47	\N	\N	\N	\N	\N	2025-11-02 21:43:07.533522	2025-11-02 21:43:07.533522
cc72680c-3a69-47b2-802d-70a6507ef2a2	off-plan	Riviera 32	https://files.alnair.ae/uploads/2023/2/2a/27/2a2709e3b0306fbce9d384f388ffcd11.jpg,https://files.alnair.ae/uploads/2023/2/da/b3/dab3f29c25cb0461d6988d882d3375d9.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17112569	55.30502242	Off-plan property: Riviera 32 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	176800.00	0	0	1	2	29.00	29.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.534882	2025-11-02 21:43:07.534882
3095ef0a-93d0-40af-965b-ab90f0de2a7f	off-plan	Riviera 20	https://files.alnair.ae/uploads/2023/2/82/ae/82ae33aee98783754a1f89a38a531c41.jpg,https://files.alnair.ae/uploads/2025/6/99/33/993394b0c563a981f228aa4bd5672451.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.17339611	55.30445293	Off-plan property: Riviera 20 by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	176800.00	0	0	1	2	29.00	29.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.536193	2025-11-02 21:43:07.536193
d90da4db-77f7-4e2e-8632-de6a6af53c5f	off-plan	Mina	https://files.alnair.ae/uploads/2023/11/ab/2a/ab2a55d08ac4368bb9eb8195f62ae8f5.jpg,https://files.alnair.ae/uploads/2023/2/d6/4a/d64a749ac6c4a28064e5cc0581cc1ace.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.12716638	55.15358327	Off-plan property: Mina by Azizi	b638b075-b76f-42d5-8455-ee7474f84d79	1072768.00	1	1	1	2	112.88	112.88	\N	\N	\N	\N	\N	2025-11-02 21:43:07.53753	2025-11-02 21:43:07.53753
a91a6374-6f36-4ae3-a7ee-c231d5bf3876	off-plan	Safa Two	https://files.alnair.ae/uploads/2023/4/86/dd/86ddd56b39ea84f81f462cdadf87f9b4.jpg,https://files.alnair.ae/uploads/2023/4/63/e4/63e46137522bd42e42254ab648e817e6.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18150550	55.25240191	Off-plan property: Safa Two by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	489600.00	1	5	1	5	69.19	1359.36	\N	\N	\N	\N	\N	2025-11-02 21:43:07.538861	2025-11-02 21:43:07.538861
4a8f9d0d-efba-4e63-86c5-7277d39a770a	off-plan	Aykon City	https://files.alnair.ae/uploads/2024/7/f1/7d/f17df53e515f9f9055c2ccbf116f89a0.jpg,https://files.alnair.ae/uploads/2024/7/75/e9/75e9a952fb6532131bdbaf94d5bb19db.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.18107549	55.25266088	Off-plan property: Aykon City by Damac	285a7ae6-0f94-40a8-8ec3-4c2c3e38e365	217600.00	0	1	1	2	40.00	76.55	\N	\N	\N	\N	\N	2025-11-02 21:43:07.540496	2025-11-02 21:43:07.540496
391c4ea4-8da5-4a48-9185-20f603875239	off-plan	Avanos	https://files.alnair.ae/uploads/2024/9/a9/8e/a98e4d31d3cd797b245ad7ef161af60f.jpg,https://files.alnair.ae/uploads/2022/12/70/1b/701b23bcb170aedd365fa49342a01a22.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06710635	55.20840988	Off-plan property: Avanos by Myra Properties	a26fdd28-bae5-458a-bcfc-6a45d9e2d2d4	367200.00	2	2	2	2	100.41	100.41	\N	\N	\N	\N	\N	2025-11-02 21:43:07.544323	2025-11-02 21:43:07.544323
338a5bce-974d-468f-b520-c65674dc3c28	off-plan	Aras Residence	https://files.alnair.ae/uploads/2024/6/9b/a2/9ba2615550a4badd883f78aceaf4058d.jpg,https://files.alnair.ae/uploads/2022/12/61/61/6161fad7aa349aa1d3f1c7e1a83275fb.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.09368183	55.31443477	Off-plan property: Aras Residence by Aras Development	48b7c726-9e46-4ca6-a33a-3fbdac7f59df	285600.00	1	1	1	2	71.46	71.46	\N	\N	\N	\N	\N	2025-11-02 21:43:07.545805	2025-11-02 21:43:07.545805
0d604793-e674-493b-bdbf-0ece3c34b3a4	off-plan	Al Jazi	https://files.alnair.ae/uploads/2024/9/d7/11/d7111c10e9b0713506ae05de9985452d.jpg,https://files.alnair.ae/uploads/2024/9/40/78/40780c8be6483d1369c08970a6fb61f5.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.13160921	55.19205048	Off-plan property: Al Jazi by Meraas	16d10862-2d9a-4eae-bb8e-c4cc3c1aab3c	584800.00	1	2	1	2	69.49	110.18	\N	\N	\N	\N	\N	2025-11-02 21:43:07.547592	2025-11-02 21:43:07.547592
b2119d98-f819-4ccf-b2d9-db6e973b391f	off-plan	Alcove	https://files.alnair.ae/uploads/2024/9/75/b6/75b6458aad6bb365f3eee4849d973b71.jpg,https://files.alnair.ae/uploads/2024/9/af/24/af243ea1fcb4ca6d8308f1dc38d27156.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.05945051	55.21287106	Off-plan property: Alcove by Grovy Real Estate Development	11570d4f-1857-4fbe-ad1e-b96b23517513	231200.00	1	1	1	2	83.00	83.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.54902	2025-11-02 21:43:07.54902
b0a66ede-a4c5-405c-a9f2-5ef0e451df43	off-plan	Ag Square	https://files.alnair.ae/uploads/2023/7/d7/d4/d7d46515c6f23c76d69224410b8e3870.jpg,https://files.alnair.ae/uploads/2023/9/31/b5/31b56e0adf48dc63108d650b6e52a047.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.08583991	55.38109052	Off-plan property: Ag Square by Ag Properties	0f7c019a-0553-415e-9c8f-d37bdb0fb1d6	204000.00	1	1	1	2	78.00	78.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.550386	2025-11-02 21:43:07.550386
d51f7e45-1d76-4fe4-950f-b58d69afb023	off-plan	Address The Bay	https://files.alnair.ae/uploads/2024/12/cf/a6/cfa6c3c931b16cad5fb7855bb1547b18.jpg,https://files.alnair.ae/uploads/2022/12/a2/06/a206e802fbcac7e0d124a05e03a8d3e2.png	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.10145090	55.14263391	Off-plan property: Address The Bay by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	870400.00	1	1	1	2	78.04	78.04	\N	\N	\N	\N	\N	2025-11-02 21:43:07.552129	2025-11-02 21:43:07.552129
b734b38a-c98d-495c-81de-db101d2c9b1b	off-plan	Address Harbour Point	https://files.alnair.ae/uploads/2024/12/12/a8/12a8d7093ae9d041ac6b77ddfef8f8f7.jpg,https://files.alnair.ae/uploads/2024/2/0b/a6/0ba6e43d8173a89e0952ee8704804797.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20902400	55.34363900	Off-plan property: Address Harbour Point by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	788800.00	1	1	1	2	61.00	780.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.553435	2025-11-02 21:43:07.553435
97c4b05d-65e4-4c5d-9201-a54eca43dc7a	off-plan	Aces Chateau	https://files.alnair.ae/uploads/2024/9/ad/98/ad984bc8a7da4c2624b402f4532e6310.jpg,https://files.alnair.ae/uploads/2024/9/81/8b/818b18ac4c2fb120feba2a7547e71ea2.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.06715130	55.21116436	Off-plan property: Aces Chateau by Aces Property Development L.L.C	fc46aaf9-7bd6-4149-bdae-d6ae3414f690	212704.00	1	1	1	2	87.04	126.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.556019	2025-11-02 21:43:07.556019
56dced7f-ca06-4432-9e26-f9eb770ec21e	off-plan	1 Residences	https://files.alnair.ae/uploads/2023/6/8e/d6/8ed6ad121324c2b9267195461f51a07d.png,https://files.alnair.ae/uploads/2025/2/17/d6/17d6a38c2a39f1727e4594dc8938b192.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.23212313	55.29538021	Off-plan property: 1 Residences by Wasl	e0b7a2e8-0ba5-44cc-8ae0-f2450afb524a	584800.00	1	3	1	3	87.00	160.63	\N	\N	\N	\N	\N	2025-11-02 21:43:07.557387	2025-11-02 21:43:07.557387
4d8168f2-b2a8-45bd-98e8-d308319ddfb9	off-plan	17 Icon Bay	https://files.alnair.ae/uploads/2022/12/b6/11/b611cc2f17df94147d89f4f44f19df83.jpg,https://files.alnair.ae/uploads/2022/12/cf/50/cf5053f1743d681da92301ec4fabbcd4.jpg	d0a1af5f-94e0-4ee9-886a-689d2f77d9b9	93d991f3-2468-4506-8417-f117f42a5b5b	24211934-94ef-4d71-aa94-900825858a4c	25.20363551	55.34557924	Off-plan property: 17 Icon Bay by Emaar Properties	b52fa283-ff1a-4047-b20e-92537a522889	462400.00	1	1	1	2	67.29	736.00	\N	\N	\N	\N	\N	2025-11-02 21:43:07.558751	2025-11-02 21:43:07.558751
\.


--
-- Data for Name: properties_facilities_facilities; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.properties_facilities_facilities ("propertiesId", "facilitiesId") FROM stdin;
\.


--
-- Data for Name: property_units; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.property_units (id, "propertyId", "unitId", type, "planImage", "totalSize", "balconySize", price) FROM stdin;
de058e68-bcdf-4824-affc-df0196332f04	cd431336-7ee0-45dc-a834-e6bf230f0602	2814-111-1	apartment	\N	87.89	\N	311712.00
75690a67-0b59-4005-87f9-7835b9728755	cd431336-7ee0-45dc-a834-e6bf230f0602	2814-112-2	apartment	\N	112.04	\N	451520.00
44f9538a-a817-45c5-966b-15bae2c69268	cd431336-7ee0-45dc-a834-e6bf230f0602	2814-164-3	penthouse	\N	390.29	\N	933776.00
e5bb214d-479a-435a-a055-002db726b67b	86f31645-39b5-4028-8f80-0730fb715ce7	3533-111-1	apartment	\N	81.78	\N	564650.24
1bc62766-084d-47cf-9f4b-57f826b5bb81	86f31645-39b5-4028-8f80-0730fb715ce7	3533-112-2	apartment	\N	166.12	\N	714334.83
b657affa-976b-40b5-949e-30b617a7170b	86f31645-39b5-4028-8f80-0730fb715ce7	3533-113-3	apartment	\N	370.37	\N	1009404.51
8aa93d63-081d-4b4f-9bd2-1f91bd8da7a0	378ed650-fd95-4d9d-b360-b701711b9ed3	2587-110-1	apartment	\N	73.67	\N	328521.60
442cb749-17f1-4ca6-80c0-e530c6892d8f	378ed650-fd95-4d9d-b360-b701711b9ed3	2587-111-2	apartment	\N	133.50	\N	443904.00
06b61b61-612a-4f44-8ccb-d7578c4b7267	378ed650-fd95-4d9d-b360-b701711b9ed3	2587-113-3	apartment	\N	163.79	\N	1020000.00
f479f2ff-3d17-4642-b590-dc7be96c9608	b7e97fb2-b092-4232-853e-0cd5b668530a	3363-111-1	apartment	\N	76.03	\N	648127.58
e9dc2aba-3f78-4727-bf7c-d9c3480846ea	b7e97fb2-b092-4232-853e-0cd5b668530a	3363-112-2	apartment	\N	314.71	\N	802584.96
0709a13c-52be-4a5b-b502-82c0b724b1f0	b7e97fb2-b092-4232-853e-0cd5b668530a	3363-113-3	apartment	\N	151.28	\N	1061452.80
4b82c7ce-cf2d-43ed-a90e-02b92e05fef8	e884faed-b135-417a-b9a5-07e7e681a095	3869-110-1	apartment	\N	53.89	\N	351449.02
9af59ebb-083d-4cce-a4ab-912fbd23c96a	e884faed-b135-417a-b9a5-07e7e681a095	3869-111-2	apartment	\N	86.87	\N	457408.80
37a914ef-30b7-451f-9475-18a6d567e4c1	e884faed-b135-417a-b9a5-07e7e681a095	3869-112-3	apartment	\N	98.87	\N	608861.12
c23b311b-5047-42b1-943d-7fa1e2f9c790	e696cf56-1e75-4a13-a320-52472dd51466	2112-111-1	apartment	\N	77.08	\N	396872.48
ba7525fe-ec0e-4d7c-97d7-37dfca7ef400	83912222-afd3-4022-8a2b-ce4674be154a	4682-111-1	apartment	\N	54.81	\N	326666.56
13ccc7ed-d6ce-49ad-8148-5785a3b40469	2118ba29-225f-49cd-91a8-b2bcc895a36b	5451-111-1	apartment	\N	69.12	\N	432208.00
00b25f0a-35ea-4e01-b189-f025ed3b5e64	2118ba29-225f-49cd-91a8-b2bcc895a36b	5451-112-2	apartment	\N	111.48	\N	615808.00
cfc58a97-abd2-4b7e-b750-21f02c800bf5	2118ba29-225f-49cd-91a8-b2bcc895a36b	5451-113-3	apartment	\N	171.87	\N	952000.00
022d5aa6-07b8-407a-92d8-52342c254a86	1a1a95be-a667-4221-aa77-d19db954185d	1864-110-1	apartment	\N	45.99	\N	272000.00
0b115868-85f9-4efb-884a-f49e47f5efb9	1a1a95be-a667-4221-aa77-d19db954185d	1864-111-2	apartment	\N	85.65	\N	467840.00
031ecd56-20aa-423e-8a06-4d80fbf6db73	6b91fcf0-46c9-453a-8ef3-6b881374e2f4	3050-111-1	apartment	\N	134.97	\N	820053.07
b0331703-069c-4baf-ac5b-207f6716886a	6b91fcf0-46c9-453a-8ef3-6b881374e2f4	3050-112-2	apartment	\N	208.33	\N	1112650.27
2cff76a4-047d-4476-9f8e-d3ceeb8d46c3	6b91fcf0-46c9-453a-8ef3-6b881374e2f4	3050-113-3	apartment	\N	272.71	\N	2102101.68
15cc309c-055b-4de8-b884-f13db1219920	6b91fcf0-46c9-453a-8ef3-6b881374e2f4	3050-164-4	penthouse	\N	794.79	\N	1241892.70
fcc5c8a6-e014-4ac8-979c-4e7635818890	488374c6-9ac9-4f8d-b462-27cf29356f25	4958-112-1	apartment	\N	117.51	\N	435964.32
5aaeece8-afe2-4fef-848e-234167a0d9cd	a3602bf8-69e1-4c9e-b602-dfca95b8975a	5479-111-1	apartment	\N	68.93	\N	421600.00
c41c573e-05a6-45cb-8e5f-a09768fea600	a3602bf8-69e1-4c9e-b602-dfca95b8975a	5479-112-2	apartment	\N	103.22	\N	647360.00
6b5d4351-71c9-4096-b102-c0147f5bee3f	a3602bf8-69e1-4c9e-b602-dfca95b8975a	5479-113-3	apartment	\N	239.69	\N	932960.00
a1dd6d6b-a016-43e2-be78-486cedac25dd	759cf321-9c76-4bbc-8815-0a0b744b2123	5297-111-1	apartment	\N	73.77	\N	326768.29
f01d9940-1b89-4e78-8410-1fa1669d2128	759cf321-9c76-4bbc-8815-0a0b744b2123	5297-112-2	apartment	\N	106.10	\N	593058.46
794d2da2-3c28-49a4-93c5-4573288899c5	dbb5eb25-b30e-4056-b893-f012fba2de32	5256-110-1	apartment	\N	42.27	\N	182240.00
b7ebb7aa-04e2-403d-ae00-a42177f11043	dbb5eb25-b30e-4056-b893-f012fba2de32	5256-111-2	apartment	\N	77.85	\N	269280.00
8acb0cf8-bc5d-4f08-bd84-eee05e7239ac	dbb5eb25-b30e-4056-b893-f012fba2de32	5256-112-3	apartment	\N	126.53	\N	448800.00
4de8a9ce-559b-432b-b9c1-05b063d3ab39	dbb5eb25-b30e-4056-b893-f012fba2de32	5256-113-4	apartment	\N	214.88	\N	952000.00
6dc3c328-17c5-492c-b55a-17d7b52f9291	9cdd252f-b888-4483-8785-ca872908e284	5160-111-1	apartment	\N	62.80	\N	465120.00
1533a8f9-fd3f-49fd-ad57-25162c3dcdd2	9cdd252f-b888-4483-8785-ca872908e284	5160-112-2	apartment	\N	98.48	\N	682720.00
ce99ff48-e90b-4462-b786-e6200f34da56	9cdd252f-b888-4483-8785-ca872908e284	5160-113-3	apartment	\N	243.69	\N	1297440.00
19666c93-8dee-4ddd-8077-92c25eeba0c3	ae229b7f-546f-4f68-9687-44b42334d8d1	4672-111-1	apartment	\N	84.36	\N	601888.13
a090e93f-703f-4aea-a9d7-864290fd7120	ae229b7f-546f-4f68-9687-44b42334d8d1	4672-112-2	apartment	\N	241.54	\N	919081.74
e204813e-9041-45b9-a1bd-6ab2c40e0aca	ae229b7f-546f-4f68-9687-44b42334d8d1	4672-113-3	apartment	\N	214.57	\N	1034457.34
435b7184-3b2d-4c0c-bc2b-edeb1dc9d957	51ac60bf-3a6b-4c5d-8848-ebe85dd0bef3	4240-111-1	apartment	\N	116.01	\N	330295.31
a73206b1-6fee-43f2-85ae-da27bc0e696a	51ac60bf-3a6b-4c5d-8848-ebe85dd0bef3	4240-112-2	apartment	\N	175.33	\N	581057.28
5b149396-ae85-409a-9ba1-e3c8c269ca61	51ac60bf-3a6b-4c5d-8848-ebe85dd0bef3	4240-164-3	penthouse	\N	436.88	\N	1584416.59
42102f3e-e015-4c93-8fb3-1b6cbf7f2a4d	3def36cc-594f-4f1a-8975-a2819abac85b	5523-111-1	apartment	\N	79.90	\N	462400.00
1ee253f2-8247-448e-9246-063f09f8772f	3def36cc-594f-4f1a-8975-a2819abac85b	5523-112-2	apartment	\N	116.04	\N	816000.00
fb62126e-3739-46b7-9b66-5b62e38d1a74	3def36cc-594f-4f1a-8975-a2819abac85b	5523-113-3	apartment	\N	218.04	\N	1523200.00
df0072f3-6a63-42ba-8ce8-5d4b812c615d	3331ba0a-b613-4207-ab93-df265d07848f	5498-110-1	apartment	\N	41.16	\N	182240.00
6a0ccf87-d26a-4d8b-b8aa-15da49d79469	3331ba0a-b613-4207-ab93-df265d07848f	5498-111-2	apartment	\N	70.42	\N	252960.00
4b9ed75f-fa7e-4d3a-a87d-3c2c98713414	3331ba0a-b613-4207-ab93-df265d07848f	5498-112-3	apartment	\N	116.59	\N	394400.00
4204328a-faf3-4606-bda4-0e7a83fe74f1	86a5542c-d31e-4aeb-9ff4-7e1caf86c144	5497-112-1	apartment	\N	258.55	\N	1411680.00
c46e9f2b-3456-4102-9357-4341c383d53b	86a5542c-d31e-4aeb-9ff4-7e1caf86c144	5497-113-2	apartment	\N	331.94	\N	1686400.00
385e39cc-39b8-4fcc-b765-61d42c1dd078	86a5542c-d31e-4aeb-9ff4-7e1caf86c144	5497-114-3	penthouse	\N	472.88	\N	2491520.00
157efc8e-99c2-4088-a140-933a5717a6f9	03711215-caac-483e-9146-5a206c686739	5465-110-1	apartment	\N	36.79	\N	323136.00
a93944a0-4e29-4678-bedf-f016059dece8	03711215-caac-483e-9146-5a206c686739	5465-111-2	apartment	\N	71.26	\N	625872.00
abd5854c-62fd-404e-8f97-21695339345e	03711215-caac-483e-9146-5a206c686739	5465-112-3	apartment	\N	108.60	\N	953904.00
b8db9525-3637-4cd3-aaf9-983c602481e8	03711215-caac-483e-9146-5a206c686739	5465-113-4	apartment	\N	160.13	\N	1405968.00
54ebb409-5051-40d1-9b4d-3515d83f4ba2	472b78fd-980a-4376-80a1-7d3771c252e0	5458-110-1	apartment	\N	37.16	\N	197200.00
de132521-1c87-44ea-880d-34fd9a004a5e	472b78fd-980a-4376-80a1-7d3771c252e0	5458-111-2	apartment	\N	68.75	\N	299200.00
94a4cf3f-009f-42f8-b7f4-5ee501478bb4	472b78fd-980a-4376-80a1-7d3771c252e0	5458-112-3	apartment	\N	111.48	\N	435200.00
6281350a-0d57-4998-a5b3-ba6ce6f7a1a3	472b78fd-980a-4376-80a1-7d3771c252e0	5458-113-4	apartment	\N	167.23	\N	489600.00
0ead944f-f88e-4808-aab7-5a27fa2bdd2e	9e1edb1d-db4c-442f-acb5-80f5b506f1b4	5454-110-1	apartment	\N	31.22	\N	143412.00
d169f69c-3ad4-40ef-bf1d-3cb7524c4bc4	9e1edb1d-db4c-442f-acb5-80f5b506f1b4	5454-111-2	apartment	\N	49.89	\N	193800.00
46665d57-c74d-421e-bbfd-b347b7ab30e7	9e1edb1d-db4c-442f-acb5-80f5b506f1b4	5454-112-3	apartment	\N	85.47	\N	374680.00
8fa90e92-fd4a-4374-8608-bbc5628fac5b	d344bebc-28f8-4bd8-97eb-6d0d3d7ec2c3	5439-110-1	apartment	\N	40.88	\N	176799.73
5955231f-7494-4566-ae41-913c6923c575	d344bebc-28f8-4bd8-97eb-6d0d3d7ec2c3	5439-111-2	apartment	\N	64.38	\N	326400.00
628f3183-2f41-4aad-b857-b474a56533c1	d344bebc-28f8-4bd8-97eb-6d0d3d7ec2c3	5439-112-3	apartment	\N	95.23	\N	476000.00
669c04f0-daa4-483c-a7a7-b79dc7625810	d344bebc-28f8-4bd8-97eb-6d0d3d7ec2c3	5439-113-4	apartment	\N	209.03	\N	707200.00
b867e713-6a80-4c20-b899-d71d79c5bae6	84a35f58-ee3b-414d-b9c2-3c0a02ad0dcd	5425-112-1	apartment	\N	111.45	\N	421599.73
9f46c75c-e051-4d1e-9fb5-6b0076f6b0f1	5de1f33f-6164-4f99-b925-13f22c0d58f3	5401-111-1	apartment	\N	78.50	\N	544000.00
159ecf79-0979-453f-b42a-cb0878e84544	5de1f33f-6164-4f99-b925-13f22c0d58f3	5401-112-2	apartment	\N	124.49	\N	816000.00
a26011d0-b5e1-4d36-ba90-57a25db3bcbe	5de1f33f-6164-4f99-b925-13f22c0d58f3	5401-113-3	apartment	\N	238.30	\N	1281120.00
7186b3ab-8c89-4b71-9a6a-19a6e8348427	03eb5a09-ef8b-45b2-976c-fa6aa7917b1e	5388-112-1	apartment	\N	118.30	\N	360128.00
f3fdadf8-eb50-41bf-94b8-48f6f14ea1cf	03eb5a09-ef8b-45b2-976c-fa6aa7917b1e	5388-113-2	apartment	\N	262.25	\N	603840.00
831c8bc0-994a-426f-94eb-679d3295ba51	24e4ee33-4ee4-452a-b841-0f11831e969a	5336-110-1	apartment	\N	36.68	\N	219503.73
99f0c161-7863-44ba-8bad-e98fcec69952	24e4ee33-4ee4-452a-b841-0f11831e969a	5336-111-2	apartment	\N	84.82	\N	353599.73
053ab741-90c9-4101-9d8a-d060a9e4beff	24e4ee33-4ee4-452a-b841-0f11831e969a	5336-112-3	apartment	\N	95.59	\N	579359.73
97a9b9b0-626d-4bd9-bde6-33f0b0b04da0	24e4ee33-4ee4-452a-b841-0f11831e969a	5336-164-4	penthouse	\N	961.07	\N	1054774.11
4f2ff2a1-9b1d-4868-a733-3aaa2e2f1365	9eb2ec9b-54e6-4263-b2a0-ddc51742e7ff	5318-112-1	apartment	\N	355.35	\N	2257600.00
1119d719-2e43-4b0a-a8c3-2cab0b5e8097	9eb2ec9b-54e6-4263-b2a0-ddc51742e7ff	5318-113-2	apartment	\N	390.94	\N	5521600.00
1b2d020f-f6dd-4496-8c35-d719a01afc3d	8d67039d-5166-423d-9791-c5f62b83eee4	5316-110-1	apartment	\N	34.28	\N	179248.00
4bfa8fef-d603-430d-b3ba-25f55913d38a	8d67039d-5166-423d-9791-c5f62b83eee4	5316-111-2	apartment	\N	62.34	\N	263568.00
96d63d79-b1b7-40f7-a225-44de18e82b4d	8d67039d-5166-423d-9791-c5f62b83eee4	5316-113-3	apartment	\N	133.41	\N	421056.00
d04d63b5-8c0c-4aec-94a6-4ed3872b54be	8d05aed2-adf9-437f-b060-6df2e0230a7d	5302-110-1	apartment	\N	29.73	\N	149600.00
359ad495-60f7-418b-a215-bff4e3d795e8	8d05aed2-adf9-437f-b060-6df2e0230a7d	5302-111-2	apartment	\N	51.10	\N	217600.00
c9c691e6-e92e-445d-ba3b-6e01465e69c5	8d05aed2-adf9-437f-b060-6df2e0230a7d	5302-112-3	apartment	\N	86.40	\N	375360.00
b7bc8e77-f5c9-42aa-a0ad-b5668f7c4e2d	6579efdf-d702-485e-8137-ad057f7a7826	5241-110-1	apartment	\N	34.23	\N	161461.38
0bfc8887-2770-4dda-9e81-a9a99d6d081a	6579efdf-d702-485e-8137-ad057f7a7826	5241-111-2	apartment	\N	69.15	\N	323952.82
1c2f91cd-6b27-4018-8dbc-810d4660f715	6579efdf-d702-485e-8137-ad057f7a7826	5241-112-3	apartment	\N	90.62	\N	451022.24
237313ab-7c36-4774-ba94-90915aa62645	6579efdf-d702-485e-8137-ad057f7a7826	5241-113-4	apartment	\N	168.92	\N	791291.52
75c450fb-e89c-4203-9169-f3d05acc5ed9	4c52294b-5d04-4fb7-8a3b-3321b2108891	5208-111-1	apartment	\N	77.11	\N	489600.00
3c2c000d-4fad-4868-9eee-947bcd40f248	4c52294b-5d04-4fb7-8a3b-3321b2108891	5208-112-2	apartment	\N	108.23	\N	652800.00
57f975aa-ebe7-48be-9793-2bc2c2e45d00	4c52294b-5d04-4fb7-8a3b-3321b2108891	5208-113-3	apartment	\N	138.43	\N	1088000.00
58be274c-8fec-441b-a098-844b94fa9412	343299d1-e3ee-4253-a764-960828af9e45	5202-110-1	apartment	\N	34.46	\N	171360.00
16c1b2eb-fd5f-4e14-ada6-02d87b673f52	343299d1-e3ee-4253-a764-960828af9e45	5202-111-2	apartment	\N	66.40	\N	285600.00
692d7d76-b1df-4a82-8a27-e9614782ce65	343299d1-e3ee-4253-a764-960828af9e45	5202-112-3	apartment	\N	83.33	\N	340000.00
08cabe9c-3349-4120-8a0c-408479a341d5	587d7a49-5aea-4a64-a0d5-4b6ad937ef03	5194-111-1	apartment	\N	72.74	\N	516800.00
3daaa64e-03d2-416c-be39-4595f76176ae	587d7a49-5aea-4a64-a0d5-4b6ad937ef03	5194-112-2	apartment	\N	102.19	\N	979200.00
26270a3d-0e48-4ac9-a7c2-89d700beefaf	587d7a49-5aea-4a64-a0d5-4b6ad937ef03	5194-113-3	apartment	\N	159.61	\N	1577600.00
76f445d3-31d9-4126-aa96-0e01837afa4a	9ebdd3f7-6dca-4e56-8be5-2c34f4e6b7b5	5185-111-1	apartment	\N	69.03	\N	530400.00
5251ac90-c152-40d1-b73a-f59a7950e64b	9ebdd3f7-6dca-4e56-8be5-2c34f4e6b7b5	5185-112-2	apartment	\N	327.02	\N	811104.00
6d0052de-e097-4af6-9157-6df89ada1212	9ebdd3f7-6dca-4e56-8be5-2c34f4e6b7b5	5185-113-3	apartment	\N	170.94	\N	1305056.00
78f1867e-1fa8-476f-bfe3-380531c63066	9ebdd3f7-6dca-4e56-8be5-2c34f4e6b7b5	5185-114-4	penthouse	\N	282.05	\N	1859120.00
01653619-6c0e-4a22-9d87-578e2d674c63	4f8daeca-470e-4019-9580-42ebfdf30042	5126-111-1	apartment	\N	66.70	\N	300499.34
14aab6ef-f247-445f-87e7-f30b3b34e95f	33a97210-2825-40aa-bf99-2cadccf42552	5096-110-1	apartment	\N	40.23	\N	204000.00
50ead766-dc9b-488e-bc33-47ef5c30f022	33a97210-2825-40aa-bf99-2cadccf42552	5096-111-2	apartment	\N	80.83	\N	340000.00
f4f5902b-da7d-47c8-a013-85e41e8d3e0b	33a97210-2825-40aa-bf99-2cadccf42552	5096-112-3	apartment	\N	94.67	\N	530400.00
4c24e900-1c15-47d0-986b-e36d9b45a6d0	bdaddba8-dc15-4c0c-994f-69f75c7d6a7b	5090-112-1	apartment	\N	165.18	\N	1400800.00
1f789007-194e-49e7-bbc1-56be02c79e4e	bdaddba8-dc15-4c0c-994f-69f75c7d6a7b	5090-113-2	apartment	\N	379.14	\N	2230128.00
47c44d8e-8e8f-4ccc-8b80-59d5f11806d6	bdaddba8-dc15-4c0c-994f-69f75c7d6a7b	5090-114-3	penthouse	\N	538.09	\N	2653632.00
dbc900a1-dd24-490f-bc22-8cfe980b4043	262162a1-1f0f-4177-857b-d524bd6cbd74	5046-110-1	apartment	\N	38.55	\N	174442.58
f5edb984-7aba-41b2-92c4-e33f64c32a0a	262162a1-1f0f-4177-857b-d524bd6cbd74	5046-111-2	apartment	\N	81.20	\N	312346.58
7e2c00ae-76e8-4d37-b4d9-3bfcdc1214d5	262162a1-1f0f-4177-857b-d524bd6cbd74	5046-112-3	apartment	\N	108.60	\N	525050.58
56c0434d-3668-4285-b4f3-e17d11d26deb	20789f13-f5ed-415a-8a1c-75df4bcfd5a1	4971-110-1	apartment	\N	39.25	\N	220521.01
196b1a23-5e90-4111-a79a-8a4d35848e97	20789f13-f5ed-415a-8a1c-75df4bcfd5a1	4971-111-2	apartment	\N	69.51	\N	311933.95
26955a34-92bb-45d3-bcc3-99e20c7c9bd5	eccbf668-81cd-4e32-8f8b-ff27a61805b1	4964-111-1	apartment	\N	89.16	\N	304378.34
c6ae1438-bf0a-4a8e-b1b5-63041f5b2e87	aa744734-dc0f-4d46-b01f-04154b08a4af	4828-111-1	apartment	\N	60.85	\N	299200.00
11c7ca8c-ec6c-42b5-9d1d-1ea1d1ba47a8	aa744734-dc0f-4d46-b01f-04154b08a4af	4828-112-2	apartment	\N	104.70	\N	516800.00
09bbb749-ec4a-473d-ad9e-fe160e35007e	aa744734-dc0f-4d46-b01f-04154b08a4af	4828-113-3	apartment	\N	174.56	\N	897600.00
c7a9bbb6-3182-4b07-bc7d-2ea6f85ca2d3	c49b0988-2105-47cf-b527-e953297e2572	4821-110-1	apartment	\N	33.63	\N	285600.00
c98f50f6-ed36-4821-9cca-03226f48a3a3	c49b0988-2105-47cf-b527-e953297e2572	4821-111-2	apartment	\N	65.87	\N	435200.00
6db38fba-f5eb-4c64-98be-eaf1a2ac8e98	c49b0988-2105-47cf-b527-e953297e2572	4821-112-3	apartment	\N	185.81	\N	489600.00
f194f432-e3b0-4519-a6ea-ad9327492105	c49b0988-2105-47cf-b527-e953297e2572	4821-113-4	apartment	\N	292.18	\N	1632000.00
7a6bcc4e-3fc3-4530-86fd-c42fef291a2e	26dc8f2b-0193-4bfd-8fa4-1236debabfd7	4813-111-1	apartment	\N	70.88	\N	518220.38
06f6be4f-03a8-4dbe-aeb9-4dccbfe481ef	8a52ef88-3691-45ea-8e57-41c1b039c121	4733-110-1	apartment	\N	45.71	\N	341324.91
20695bdf-fb2e-46f6-b029-ffbdf906908c	8a52ef88-3691-45ea-8e57-41c1b039c121	4733-111-2	apartment	\N	75.90	\N	540010.58
347c7be7-cc8e-44e2-982f-378eb54ae072	15ec770a-ac63-44a9-8931-3235c6183983	4317-111-1	apartment	\N	68.75	\N	245344.00
2b18c36e-4c9b-401d-bf09-9f7b2633d201	15ec770a-ac63-44a9-8931-3235c6183983	4317-112-2	apartment	\N	110.55	\N	340000.00
6d85508d-7c8a-40b1-9d93-3d6151fb12dc	48b80748-b311-40d9-89d3-a3514d6a4e51	4135-110-1	apartment	\N	56.11	\N	274511.65
a6655f03-0816-48c5-8949-3b32582a799e	48b80748-b311-40d9-89d3-a3514d6a4e51	4135-111-2	apartment	\N	125.55	\N	286775.86
357c25c8-e3b8-4acd-bf35-d6011001de1b	48b80748-b311-40d9-89d3-a3514d6a4e51	4135-112-3	apartment	\N	133.55	\N	424194.34
2a189653-246b-4b9a-974b-b82cab3305a5	97a6c0e2-6e2c-456c-a2f6-10eece1992c4	4100-110-1	apartment	\N	39.62	\N	214367.82
a437237e-6b4e-40b1-8493-1a0495c4a66c	97a6c0e2-6e2c-456c-a2f6-10eece1992c4	4100-111-2	apartment	\N	107.60	\N	317005.12
4bf9940a-944c-4e4b-9095-dd58224d2bd7	97a6c0e2-6e2c-456c-a2f6-10eece1992c4	4100-112-3	apartment	\N	187.48	\N	799749.36
873f585a-7e30-4145-ad55-4def52bb3a4d	8002ca39-4d7d-44b7-8637-531abff7f1f9	4082-110-1	apartment	\N	44.65	\N	219370.99
78a1c7a9-c9fc-46f3-bc00-fc22f75af88d	8002ca39-4d7d-44b7-8637-531abff7f1f9	4082-111-2	apartment	\N	100.80	\N	331151.02
45f175a1-2413-46b4-8666-de7cc7f84909	8002ca39-4d7d-44b7-8637-531abff7f1f9	4082-112-3	apartment	\N	164.62	\N	577822.38
e7d90452-4677-42bf-b45a-b6b20a1b3364	9029212d-31a1-402f-bfa3-ef5f00c9f256	4031-110-1	apartment	\N	36.88	\N	189040.00
de26c423-48f8-4d8c-88f3-b75989f413bc	9029212d-31a1-402f-bfa3-ef5f00c9f256	4031-111-2	apartment	\N	60.39	\N	265200.00
19348946-53de-47a7-9411-eb0e2ec57f5b	9029212d-31a1-402f-bfa3-ef5f00c9f256	4031-112-3	apartment	\N	94.20	\N	350880.00
cd481c2b-db3c-4b49-ac2e-ee7b74a17d22	9029212d-31a1-402f-bfa3-ef5f00c9f256	4031-113-4	apartment	\N	145.58	\N	625600.00
7b7a83df-ee38-48f6-9ea8-29918dcfcc42	12fff49f-e540-414c-8940-d067e145ec30	4009-110-1	apartment	\N	55.90	\N	225088.16
61649522-4e04-4661-85d5-46ea00ee81fd	12fff49f-e540-414c-8940-d067e145ec30	4009-111-2	apartment	\N	94.25	\N	336875.81
22117d6d-cdf2-47d2-983a-265546ad96ce	12fff49f-e540-414c-8940-d067e145ec30	4009-112-3	apartment	\N	154.08	\N	422313.46
4f0601f4-5546-4b69-830c-d3f22525a584	50fcdf40-54f4-4c52-89ed-914835c7be72	3600-110-1	apartment	\N	47.56	\N	235929.26
a19d04d2-29e8-4aa8-bd65-689a0d7e93ed	50fcdf40-54f4-4c52-89ed-914835c7be72	3600-111-2	apartment	\N	107.12	\N	318022.13
e0e915e3-45ad-4a1b-8e77-d8b84b1c4d39	50fcdf40-54f4-4c52-89ed-914835c7be72	3600-112-3	apartment	\N	101.73	\N	449682.91
6145b6a5-df68-468d-9894-ebe7003646cf	443fd7a1-9eaa-48cc-bfae-0702b42089b4	3289-110-1	apartment	\N	34.68	\N	199914.56
999bfc22-49f6-48f6-a53c-fb34219c735c	443fd7a1-9eaa-48cc-bfae-0702b42089b4	3289-111-2	apartment	\N	100.72	\N	308627.79
1abd1a07-6356-41b3-832a-8afd30cf3361	443fd7a1-9eaa-48cc-bfae-0702b42089b4	3289-112-3	apartment	\N	134.86	\N	441222.90
f58fe7d5-c4a3-4e43-b453-ec12058bea61	c789013f-8087-4a69-b4b0-81076876ee7e	3276-110-1	apartment	\N	59.37	\N	176800.00
fe9993fe-dc4c-43d9-b607-bcbd4b087137	c789013f-8087-4a69-b4b0-81076876ee7e	3276-111-2	apartment	\N	113.90	\N	271999.73
285f5d03-8eca-41c7-b268-dc19dddb2aac	c789013f-8087-4a69-b4b0-81076876ee7e	3276-112-3	apartment	\N	185.81	\N	394400.00
ad9f4e0d-fc87-447a-9209-29436405523d	e0b1441c-f024-4f1e-83d9-5399d1137a4c	3043-113-1	apartment	\N	517.38	\N	7208000.00
473c5658-012f-4c5d-bc5d-fd710aa17999	e0b1441c-f024-4f1e-83d9-5399d1137a4c	3043-341-2	villa	\N	2972.90	\N	44880000.00
864036bb-1236-4c5a-88cc-51f58b051d47	f38489ff-f106-4cf5-ad3c-1aaa4e22989b	3035-110-1	apartment	\N	52.71	\N	219309.52
6548164f-ef68-4e13-9cac-c473aa10ff41	f38489ff-f106-4cf5-ad3c-1aaa4e22989b	3035-111-2	apartment	\N	98.63	\N	324809.07
2aa30401-0f13-413c-8e0a-1ba676f93d7f	f38489ff-f106-4cf5-ad3c-1aaa4e22989b	3035-112-3	apartment	\N	115.87	\N	476652.53
304b3c40-a438-430b-9f87-912222a70c98	eb12d379-fbf9-4f21-b1bd-89f158c4d6d5	3008-110-1	apartment	\N	40.60	\N	196054.34
0c2ceb4b-19a3-43e5-bd32-5710bf951740	eb12d379-fbf9-4f21-b1bd-89f158c4d6d5	3008-111-2	apartment	\N	109.44	\N	283825.20
6af53a71-b563-430e-ab04-32f8986d230a	eb12d379-fbf9-4f21-b1bd-89f158c4d6d5	3008-112-3	apartment	\N	170.85	\N	446371.04
b21febd1-552b-4a3b-b59d-0da2ac75ab58	eb12d379-fbf9-4f21-b1bd-89f158c4d6d5	3008-113-4	apartment	\N	253.25	\N	592605.58
cc447431-9df7-405a-bdba-8ac7baa71d94	4bb1158e-bc5f-45f0-9aec-5578814dc5f0	2590-110-1	apartment	\N	52.49	\N	216512.00
007dcba8-2563-4db6-89a4-955152646fed	4bb1158e-bc5f-45f0-9aec-5578814dc5f0	2590-111-2	apartment	\N	116.13	\N	292400.00
ce450b19-59f1-4957-9bd1-68070590e0fc	4bb1158e-bc5f-45f0-9aec-5578814dc5f0	2590-112-3	apartment	\N	129.60	\N	413440.00
dba45bf1-b474-4990-ae47-48788b1a23f8	0315eb7d-50d9-43ec-b5f4-b7872701a8f1	2544-111-1	apartment	\N	88.26	\N	489600.00
51e4b23b-a08e-409c-a352-9613b5ead3a7	0315eb7d-50d9-43ec-b5f4-b7872701a8f1	2544-112-2	apartment	\N	139.35	\N	707200.00
304aa841-519e-4436-9355-147fdc819a12	0e426e75-d331-4f05-823c-4ce52ad2c7fa	2480-111-1	apartment	\N	83.71	\N	584800.00
931fdfb5-6b9f-4cf9-a2c7-a453a4888e19	0e426e75-d331-4f05-823c-4ce52ad2c7fa	2480-112-2	apartment	\N	124.68	\N	870400.00
88c5736c-7052-4166-8527-b7a142c8d800	0e426e75-d331-4f05-823c-4ce52ad2c7fa	2480-113-3	apartment	\N	282.15	\N	2078080.00
fcbc739a-7bbf-4401-8ecb-71f2155eed39	a9224060-86f1-4094-b653-d74ebc181695	5522-110-1	apartment	\N	18.00	\N	266560.00
757e8431-3582-47c6-95fc-0e9323a43311	d5d0d405-d709-4dc7-8a63-27cbb25a7fbc	5520-110-1	apartment	\N	30.00	\N	353600.00
e7cb2adc-c9a9-4740-a99f-e61cda2d84f8	2cdd5249-577e-4d3f-a7c5-630dd04a7ce9	5430-111-1	apartment	\N	56.67	\N	375360.00
53d5ab40-4977-4352-9f90-a7a5f54f56ec	9afe6ac7-d53b-4eff-9b70-d1a22ec421ea	5429-110-1	apartment	\N	37.49	\N	217600.00
30e2427f-233b-4a6c-94d2-6347b112bf56	9afe6ac7-d53b-4eff-9b70-d1a22ec421ea	5429-111-2	apartment	\N	71.50	\N	258400.00
afdec8d4-e664-4257-8f72-032bd1ea9864	9afe6ac7-d53b-4eff-9b70-d1a22ec421ea	5429-112-3	apartment	\N	78.84	\N	402560.00
600588b3-0ecf-4fad-bd06-30a00db375fa	65ce7c30-fb95-425f-8fa7-c3dd89f41966	5428-110-1	apartment	\N	39.07	\N	181766.99
edef206a-111f-4825-a565-86c1355a9419	65ce7c30-fb95-425f-8fa7-c3dd89f41966	5428-111-2	apartment	\N	76.53	\N	247925.55
b70cdf79-d943-4c1f-a1ad-52ebfd5779d7	65ce7c30-fb95-425f-8fa7-c3dd89f41966	5428-112-3	apartment	\N	139.67	\N	402216.46
3f208f17-7323-4384-8cf6-012a946c3950	65ce7c30-fb95-425f-8fa7-c3dd89f41966	5428-113-4	apartment	\N	300.26	\N	1049050.42
e9c69976-67d7-4eae-a020-856b9a9f8e56	03b8c5dc-bf8c-41b4-be46-963e0ae84654	5422-111-1	apartment	\N	80.84	\N	791386.18
c7c9cb9e-f31b-4f55-8b5f-28e48c68218a	03b8c5dc-bf8c-41b4-be46-963e0ae84654	5422-112-2	apartment	\N	149.17	\N	1292565.76
fd177051-14dc-4a8d-80b9-53d3bc6dc331	03b8c5dc-bf8c-41b4-be46-963e0ae84654	5422-113-3	apartment	\N	211.05	\N	2543809.55
aab3aa7b-1c37-4768-8b3b-5cd34e6e51a0	67714512-1b0e-4403-b28c-ae8abc3f54dd	5407-110-1	apartment	\N	37.90	\N	135264.24
4ab008f7-9eed-41c4-809b-2a35523994b7	67714512-1b0e-4403-b28c-ae8abc3f54dd	5407-111-2	apartment	\N	80.18	\N	227873.98
a81a744f-056d-4475-86d2-c9d7f506b860	67714512-1b0e-4403-b28c-ae8abc3f54dd	5407-112-3	apartment	\N	102.47	\N	319106.32
9c031c3d-c5fd-4e4a-a51b-7de55c41cbff	d93a35a0-630e-4354-beb0-3bc50c3c0c2e	5402-110-1	apartment	\N	37.25	\N	225216.00
4eb7b10b-1ef2-4f9c-9808-3a29f70c1af1	d93a35a0-630e-4354-beb0-3bc50c3c0c2e	5402-111-2	apartment	\N	82.13	\N	381616.00
0ad69db3-5115-435a-a199-ef3a557260c3	d93a35a0-630e-4354-beb0-3bc50c3c0c2e	5402-112-3	apartment	\N	127.18	\N	491232.00
1fa545f6-02db-4b76-afcc-649565fa5dba	d93a35a0-630e-4354-beb0-3bc50c3c0c2e	5402-164-4	penthouse	\N	444.04	\N	828512.00
fbc2044a-1996-4fae-b15e-ac39e3af9273	0a1f3220-11ee-4e1a-b45d-ebd37ca3be95	5398-111-1	apartment	\N	70.53	\N	244528.00
81d935b3-f81f-4d9d-9210-0fd75dfe0bfa	0a1f3220-11ee-4e1a-b45d-ebd37ca3be95	5398-112-2	apartment	\N	119.00	\N	384880.00
ffc70966-f364-4571-861e-c287286fe88d	628efb4b-c902-4527-b499-7022e2cad693	5324-111-1	apartment	\N	88.07	\N	1048016.00
fd4dd0b2-949e-4b03-b6ab-9a01a69125fa	628efb4b-c902-4527-b499-7022e2cad693	5324-112-2	apartment	\N	137.87	\N	1482672.00
74100376-0e13-417d-910b-68ffee432c16	628efb4b-c902-4527-b499-7022e2cad693	5324-113-3	apartment	\N	203.46	\N	2454256.00
c6523116-a8e6-4107-b0aa-d8c3187727a8	242ab05b-f224-4e1b-92c3-9b473b9949b9	5322-111-1	apartment	\N	78.11	\N	271728.00
7b9abd14-c9e8-46e8-95af-786a3e4a5d8f	242ab05b-f224-4e1b-92c3-9b473b9949b9	5322-112-2	apartment	\N	122.96	\N	459680.00
0cb30b7a-a9d2-4f16-8791-efd3125804e8	b96845f7-c8b9-4212-9282-56244f40b840	5321-110-1	apartment	\N	35.49	\N	199445.09
b73e6d3c-9b48-4ed3-87d6-c54d5f632aa0	b96845f7-c8b9-4212-9282-56244f40b840	5321-111-2	apartment	\N	76.97	\N	333793.78
511f0d61-6068-4431-bd1d-835c5144f73e	b96845f7-c8b9-4212-9282-56244f40b840	5321-112-3	apartment	\N	113.05	\N	470987.31
83fe87c3-b1f5-4864-ae3b-d2637481d30d	34207eb0-5305-4e03-9450-bee8f406852f	5315-111-1	apartment	\N	84.91	\N	549137.54
4cf228a5-1cfb-477f-a6a3-bfae695a7608	34207eb0-5305-4e03-9450-bee8f406852f	5315-112-2	apartment	\N	115.29	\N	821137.54
f04b2d02-d3d9-4aec-aedd-d496f6624f45	34207eb0-5305-4e03-9450-bee8f406852f	5315-113-3	apartment	\N	170.48	\N	1150801.54
baee7801-4edb-43b3-92b9-38f3b8703449	f177b0fc-11aa-44f3-b480-f6d48ca51760	5293-164-1	penthouse	\N	1436.84	\N	6908800.00
76cccce9-a091-431b-88b5-11eca934e970	87607df8-bad5-4103-a85f-2029c9ccc776	5292-110-1	apartment	\N	42.27	\N	204000.00
d25335dd-7d9b-4da4-bed1-428dd34f9929	87607df8-bad5-4103-a85f-2029c9ccc776	5292-111-2	apartment	\N	76.65	\N	310080.00
424d8d49-ba38-45b5-8e84-ab9cec0e997e	87607df8-bad5-4103-a85f-2029c9ccc776	5292-112-3	apartment	\N	139.35	\N	435200.00
1e7c19f4-e17f-4f51-930a-75ad1d4c87e2	87607df8-bad5-4103-a85f-2029c9ccc776	5292-164-4	penthouse	\N	59.37	\N	383520.00
f9fe25e8-ed01-4f77-adc2-d2f55e02816b	73638cc2-ee0c-4de0-9e16-8eeefa8e41d4	5276-110-1	apartment	\N	31.68	\N	159392.00
15e8a14c-e10b-4ab9-8501-80ea6873efa3	73638cc2-ee0c-4de0-9e16-8eeefa8e41d4	5276-111-2	apartment	\N	85.38	\N	267376.00
7b77c174-fb60-4532-bf33-02bd3f8a2bf0	73638cc2-ee0c-4de0-9e16-8eeefa8e41d4	5276-112-3	apartment	\N	106.28	\N	424864.00
c711dc59-c7c3-41a5-84e0-94a354c00b14	dd2f75a0-9d44-4ab5-8c4e-ee900f5c368c	5269-111-1	apartment	\N	75.81	\N	628561.54
4f0888b2-961e-44b4-8d60-8adcc3e3b514	dd2f75a0-9d44-4ab5-8c4e-ee900f5c368c	5269-112-2	apartment	\N	119.47	\N	903825.54
12da29b3-2a80-43fa-a6e5-ec062e4a2c95	dd2f75a0-9d44-4ab5-8c4e-ee900f5c368c	5269-113-3	apartment	\N	209.12	\N	1360513.54
0fa86356-2e70-4982-86ab-e5451a4fb13d	f8ccb233-11e7-41d5-9a40-d23eaed9208a	5264-111-1	apartment	\N	84.23	\N	452851.44
36691890-b5c8-4eb9-b044-6e8aad419163	f8ccb233-11e7-41d5-9a40-d23eaed9208a	5264-112-2	apartment	\N	211.14	\N	639932.50
d8aa4aa0-4148-48da-ab9a-775b35230a61	f8ccb233-11e7-41d5-9a40-d23eaed9208a	5264-113-3	apartment	\N	286.91	\N	1470016.66
79baca5f-c8aa-4d3e-8c4a-3e15b646cc22	f9636ac9-b9fe-4f30-b318-bb6b1ee7c5e4	5263-111-1	apartment	\N	69.55	\N	504194.43
9e489217-edd9-47ad-bf39-5211570c73d3	f9636ac9-b9fe-4f30-b318-bb6b1ee7c5e4	5263-112-2	apartment	\N	81.01	\N	671544.61
5b731a08-5eda-404e-9d40-db879cc75af0	a83b58de-7ed1-4505-b66e-fdd1f13f5110	5261-111-1	apartment	\N	69.41	\N	241808.00
809c9458-ebbe-49af-8424-1c9c102204d1	a83b58de-7ed1-4505-b66e-fdd1f13f5110	5261-112-2	apartment	\N	95.03	\N	353328.00
78173e52-c48e-4034-b528-db27d8262d49	b355bf25-c689-471a-9c3f-06db8644c1b4	5240-110-1	apartment	\N	83.49	\N	205451.94
dd0e765e-dc38-4ebc-b516-966f746f9217	b355bf25-c689-471a-9c3f-06db8644c1b4	5240-111-2	apartment	\N	151.97	\N	323811.92
a8cae3d8-f901-4d54-b7c1-9ed7b5e787da	b355bf25-c689-471a-9c3f-06db8644c1b4	5240-112-3	apartment	\N	111.12	\N	458465.52
8914bc41-1e8d-4d9c-b8f3-a552959668b9	a7eada4d-eff0-4dcb-afec-25b4bc060d02	5239-111-1	apartment	\N	143.30	\N	802128.00
76cd46a0-378a-4965-9827-0b8f2634f71f	a7eada4d-eff0-4dcb-afec-25b4bc060d02	5239-112-2	apartment	\N	268.35	\N	1379312.00
1fc23043-ce3c-4a3e-b8b3-77dfde557c30	a7eada4d-eff0-4dcb-afec-25b4bc060d02	5239-113-3	apartment	\N	185.60	\N	2171920.00
856d8969-6af8-49f3-afb7-547523d4236c	a7eada4d-eff0-4dcb-afec-25b4bc060d02	5239-114-4	penthouse	\N	284.24	\N	3535184.00
97c60f82-7813-4ec7-9c23-96d8c784ee4d	033737b7-f557-42d8-9fb1-e26856d8cb3e	5235-112-1	apartment	\N	119.85	\N	753107.34
1d652da8-47b9-45b5-a1c7-5d805d0058d9	033737b7-f557-42d8-9fb1-e26856d8cb3e	5235-113-2	apartment	\N	331.01	\N	1521779.34
16f599ef-3daa-4871-b9ea-fa8ffae4d687	033737b7-f557-42d8-9fb1-e26856d8cb3e	5235-114-3	penthouse	\N	330.36	\N	4858403.34
671383cb-2d3e-485d-b354-9ca0d31d9d43	054ec1c2-7bf4-4684-9b65-05f44b2ea88c	5234-111-1	apartment	\N	59.18	\N	293729.54
e2f268f0-e4f6-439f-a58d-e94052c6fc9a	054ec1c2-7bf4-4684-9b65-05f44b2ea88c	5234-112-2	apartment	\N	86.68	\N	411777.54
d5abe12c-f9dc-4a5e-ad2c-d36d2fd6b6f8	054ec1c2-7bf4-4684-9b65-05f44b2ea88c	5234-113-3	apartment	\N	133.04	\N	630193.54
ae5f27b3-9dcf-4cc4-98f4-936f8943b072	10724ff5-fcfb-4612-a0f4-fff1c131fc91	5232-111-1	apartment	\N	94.67	\N	283972.08
e85649f9-dea2-4b68-b149-42c34579fed7	10724ff5-fcfb-4612-a0f4-fff1c131fc91	5232-112-2	apartment	\N	130.62	\N	430815.09
4f8fde60-6e2e-48e6-8290-b5d2ee36d179	733ec47f-1ad1-4610-80d1-c6131540d13b	5216-111-1	apartment	\N	68.56	\N	775200.00
bda1b300-9ef6-40b9-bf03-653ced69ffce	733ec47f-1ad1-4610-80d1-c6131540d13b	5216-112-2	apartment	\N	114.64	\N	1346400.00
f0813bfe-636b-4900-a1bb-4fb4b562b82a	37d3fa99-ae63-4e08-ba66-dd93d264c920	5209-110-1	apartment	\N	47.57	\N	160752.00
d579a890-cd8c-48ea-b254-f2429c2df64a	37d3fa99-ae63-4e08-ba66-dd93d264c920	5209-111-2	apartment	\N	80.55	\N	289952.00
59b63535-0cfe-4686-a035-a712b16a7efa	37d3fa99-ae63-4e08-ba66-dd93d264c920	5209-112-3	apartment	\N	126.35	\N	361216.00
94e8da84-d40a-4db0-8b82-87a4ca423296	b6b7bf29-465c-4b3a-bc7c-02f476f7cc84	5201-110-1	apartment	\N	49.80	\N	149600.00
d4838c2d-9532-464f-a8c2-482f4d1db81b	b6b7bf29-465c-4b3a-bc7c-02f476f7cc84	5201-111-2	apartment	\N	126.81	\N	264628.80
45e7d316-0af6-4e23-a76c-038a5420407d	b6b7bf29-465c-4b3a-bc7c-02f476f7cc84	5201-112-3	apartment	\N	112.04	\N	377264.00
847c88c2-823f-4360-ad74-d223864b9057	65c9351e-9494-427b-8b94-5bbe5aad39e2	5199-111-1	apartment	\N	157.18	\N	503605.28
670aa7d4-2c9e-463a-82b4-d22ff952aa44	65c9351e-9494-427b-8b94-5bbe5aad39e2	5199-112-2	apartment	\N	352.83	\N	851170.69
5afe4347-a0a5-41d2-897d-e6440d719fc4	b64c6a2b-60ef-49ff-abed-69fa31621f2d	5176-111-1	apartment	\N	102.01	\N	544000.00
41665ab8-1e6d-4ef5-8dea-d754e4606191	b64c6a2b-60ef-49ff-abed-69fa31621f2d	5176-112-2	apartment	\N	128.95	\N	750025.04
d38a78cf-bee1-4409-a5b8-79399843cc63	b64c6a2b-60ef-49ff-abed-69fa31621f2d	5176-113-3	apartment	\N	188.59	\N	1019728.00
96e5c7bc-b6b7-4646-beb5-860228a91b71	1337ed0c-f00b-49ae-8a66-cffd8aa5e55c	5171-111-1	apartment	\N	92.96	\N	512506.48
93e3f227-3979-467c-ab68-f2d3d1ff8f63	1337ed0c-f00b-49ae-8a66-cffd8aa5e55c	5171-112-2	apartment	\N	135.80	\N	695610.35
4ccfa43a-10cd-4d94-b4be-e6bdaca287d5	1337ed0c-f00b-49ae-8a66-cffd8aa5e55c	5171-113-3	apartment	\N	192.12	\N	944803.70
3ed9f692-f24c-44e3-9e31-34ad9ab3512d	6bfc1f36-2b0b-46e3-8348-b97acbfb776e	5128-111-1	apartment	\N	94.95	\N	432480.00
7b64f5d7-c4a9-4f66-9666-471f63bb54de	6bfc1f36-2b0b-46e3-8348-b97acbfb776e	5128-112-2	apartment	\N	172.15	\N	701760.00
fa158587-e322-490e-bd2c-ae724149c71f	6bfc1f36-2b0b-46e3-8348-b97acbfb776e	5128-113-3	apartment	\N	331.85	\N	1822400.00
f290cebf-b411-4e46-af66-e9be1821162e	11c5df2a-1fba-4f5e-9b44-8d54539195ef	5114-110-1	apartment	\N	44.31	\N	361216.00
6badfec4-4e2e-46fc-bf02-c7e0d2bc7644	11c5df2a-1fba-4f5e-9b44-8d54539195ef	5114-111-2	apartment	\N	74.79	\N	518432.00
f42b491d-560e-4f9d-9c3d-d1507587f26d	11c5df2a-1fba-4f5e-9b44-8d54539195ef	5114-112-3	apartment	\N	95.30	\N	1034688.00
d1cd2ede-7049-41b4-bea4-ba441aa06a2f	11c5df2a-1fba-4f5e-9b44-8d54539195ef	5114-113-4	apartment	\N	164.35	\N	1642880.00
01287d64-6aa3-4024-81c6-d8f742fd9f54	11c5df2a-1fba-4f5e-9b44-8d54539195ef	5114-114-5	penthouse	\N	321.44	\N	3076320.00
266b12c6-2d85-4c31-8cd8-82cd715a4c72	7c25a05b-ed11-493a-84f1-3a47d2d1ea82	5113-111-1	apartment	\N	93.37	\N	340000.00
06fe55ef-72c6-4fa1-b6f6-f392e562b981	7c25a05b-ed11-493a-84f1-3a47d2d1ea82	5113-112-2	apartment	\N	105.45	\N	496944.00
79474180-420d-498e-8377-e771b6a323e6	2eee1c45-8a78-4841-83f7-4fa2e5e08a8f	5111-164-1	penthouse	\N	173.54	\N	558688.00
9fe8bca0-447a-447e-9ee9-049312648348	7122ae11-ea0e-4d10-9898-97ba2f4a5d3f	5093-110-1	apartment	\N	40.97	\N	243440.00
76d4a7ac-a9d6-4150-9f46-6c11fe4bd5fb	7122ae11-ea0e-4d10-9898-97ba2f4a5d3f	5093-111-2	apartment	\N	73.12	\N	369648.00
9ea151c2-9003-421e-9d44-8c00495acf3d	7122ae11-ea0e-4d10-9898-97ba2f4a5d3f	5093-112-3	apartment	\N	116.71	\N	591872.00
36345d70-d281-4dab-a60d-749054ea18ce	66aea192-979f-433b-bd85-44139765212e	5083-111-1	apartment	\N	85.01	\N	293094.96
703b9c2d-4886-44f3-9d9e-2504faa70893	66aea192-979f-433b-bd85-44139765212e	5083-112-2	apartment	\N	213.12	\N	446230.96
189609e8-956f-4c55-b138-f2ae69d832bf	dde0c888-0397-42e8-8196-26dd464bcbba	5073-111-1	apartment	\N	76.65	\N	267526.96
bd23ec9f-f943-442d-b9b4-8703567b049c	dde0c888-0397-42e8-8196-26dd464bcbba	5073-112-2	apartment	\N	122.54	\N	396182.96
c7954885-2c96-4a6b-ac56-276766c7150e	dde0c888-0397-42e8-8196-26dd464bcbba	5073-113-3	apartment	\N	113.90	\N	406518.96
b72fc492-e1b0-4f00-9928-de38d7c9ccb5	bb4089be-afb8-4612-aed4-3f0e50527eed	5064-110-1	apartment	\N	43.34	\N	159120.00
84f3f678-1733-4865-b6e1-1e5c158f082b	bb4089be-afb8-4612-aed4-3f0e50527eed	5064-111-2	apartment	\N	93.47	\N	231472.00
89324d71-ddd4-4503-995a-62a1a1f26eb3	2bf93ce0-2ff1-4d98-82d0-9d43c46cff74	5047-112-1	apartment	\N	116.85	\N	470241.22
6ea218fd-4350-40df-a8e9-6f80020410de	2bf93ce0-2ff1-4d98-82d0-9d43c46cff74	5047-113-2	apartment	\N	138.65	\N	630449.22
73b44655-284b-4c22-89b5-3b82a3925e7d	4c00918f-5814-4b8e-b269-82412ac6a4a2	5045-111-1	apartment	\N	79.94	\N	590737.22
67580d92-a133-4c5c-8595-a38096f203c0	4c00918f-5814-4b8e-b269-82412ac6a4a2	5045-112-2	apartment	\N	127.06	\N	877153.22
ed3c86c8-5a3c-47e9-a7f0-1d16c03d3103	378708db-a764-4a78-ad1a-28ce111e86a8	5034-110-1	apartment	\N	36.88	\N	161568.00
e3a5b3fa-ae9b-4ed1-865b-20c7933f0685	378708db-a764-4a78-ad1a-28ce111e86a8	5034-111-2	apartment	\N	81.38	\N	266016.00
82bb04cf-24d1-4da9-9c7e-8b5bbbd2243b	378708db-a764-4a78-ad1a-28ce111e86a8	5034-112-3	apartment	\N	100.80	\N	429760.00
c7cc439d-872c-42cf-8b33-52026d9edcef	b575383c-0bab-4cb1-828c-84bcca273cd0	5016-112-1	apartment	\N	139.56	\N	804163.38
87db864c-f15a-446f-a4ef-671b24455588	c0b3eae3-78fa-417a-a897-2fbb007b3196	5011-111-1	apartment	\N	70.14	\N	516856.85
dcd1be21-9963-40eb-a982-a422ff4f626c	c0b3eae3-78fa-417a-a897-2fbb007b3196	5011-112-2	apartment	\N	142.23	\N	825541.76
126bd53c-0f38-4e4f-ab9b-bb695e50f0e4	979ddc95-b3c4-4479-94cf-c0ac1d1492ba	5009-110-1	apartment	\N	48.82	\N	233104.00
11aa4386-20bf-4c3c-8ccb-4188c312bc22	979ddc95-b3c4-4479-94cf-c0ac1d1492ba	5009-111-2	apartment	\N	73.56	\N	325584.00
6b929280-db6e-48b3-81e8-7448288d366d	4f2a2c68-cef7-424d-9c4a-50a2a3f190a5	5001-111-1	apartment	\N	83.71	\N	575521.54
30edeabe-5dbc-4db5-8250-57bf3211faf2	4f2a2c68-cef7-424d-9c4a-50a2a3f190a5	5001-112-2	apartment	\N	129.51	\N	869553.54
078502b3-8b52-45b7-9fe0-5c866c9cc8fa	4f2a2c68-cef7-424d-9c4a-50a2a3f190a5	5001-113-3	apartment	\N	237.37	\N	1212001.54
3c45c5f2-8f31-4e96-9cb4-915160672671	d9ea8560-8540-460d-a4c1-4ef6b575d7d3	4995-110-1	apartment	\N	39.39	\N	224128.00
4e8b8412-6b89-4134-8ce3-16acd5c38656	d9ea8560-8540-460d-a4c1-4ef6b575d7d3	4995-111-2	apartment	\N	80.10	\N	380256.00
2498f01b-e849-47a9-aa98-a6352e65106f	d9ea8560-8540-460d-a4c1-4ef6b575d7d3	4995-112-3	apartment	\N	126.81	\N	469744.00
ad0132c4-929f-4df5-b32e-5970cd812a30	d9ea8560-8540-460d-a4c1-4ef6b575d7d3	4995-164-4	penthouse	\N	451.73	\N	915824.00
16c889a2-16bf-4f19-9d81-e485de255198	aa7e8dde-e11d-45b4-9b19-d3e001da39cf	4993-110-1	apartment	\N	43.48	\N	236435.73
9d9118be-9b47-4c16-9650-c9eee1b46d7a	aa7e8dde-e11d-45b4-9b19-d3e001da39cf	4993-111-2	apartment	\N	79.25	\N	363702.08
b70ce233-9f82-4b4c-bd6c-5d5858e7997c	46b6520e-dec0-40a0-8f36-8d4a42047c07	4992-113-1	apartment	\N	223.06	\N	639200.00
67e8f7e1-5cce-43e5-bb0b-fcd000f5accb	46b6520e-dec0-40a0-8f36-8d4a42047c07	4992-114-2	penthouse	\N	228.08	\N	884000.00
4b0f4d10-f606-48cf-b79f-cea3edf27548	39e2c254-9e64-4538-bc5e-b3ebb3d9d84a	4990-110-1	apartment	\N	40.65	\N	170000.00
88067352-c054-42e2-90ff-65e16319dbf0	39e2c254-9e64-4538-bc5e-b3ebb3d9d84a	4990-111-2	apartment	\N	108.00	\N	265200.00
8795ba57-0f09-42a1-b1e4-8b60cd601bc4	39e2c254-9e64-4538-bc5e-b3ebb3d9d84a	4990-112-3	apartment	\N	108.62	\N	371089.87
a6690462-95dd-4bf1-ac0e-0717de0cc4f5	9cbb3993-3108-4fce-86a6-b0854fde16f4	4982-112-1	apartment	\N	148.26	\N	768515.33
bc8d7583-ba38-4e86-a1ce-dd1594a436b3	cf03bb11-3f02-4eea-b520-38f53fa24234	4981-112-1	apartment	\N	262.13	\N	429000.85
3571874a-cd1e-4d97-aca4-d6a853c5ea11	c5cd02d4-6511-46b2-96cc-b85e390e1084	4966-110-1	apartment	\N	68.80	\N	452547.34
11f20211-5b52-45e5-a7a3-9bebf2e1507e	c5cd02d4-6511-46b2-96cc-b85e390e1084	4966-111-2	apartment	\N	94.20	\N	500691.34
a2fd1d46-9e0a-4be3-a407-3e4a405879be	c5cd02d4-6511-46b2-96cc-b85e390e1084	4966-112-3	apartment	\N	262.92	\N	1540819.34
9a13f0c7-cf95-47ab-b69e-6a4f6dd160b1	c5cd02d4-6511-46b2-96cc-b85e390e1084	4966-113-4	apartment	\N	184.51	\N	1432291.34
cbe2f7c5-01c5-4619-ad0b-6a0b42924097	78d55485-7910-4c70-a567-070f61d252f7	4956-110-1	apartment	\N	41.43	\N	199177.44
f00476d8-27bc-4d99-8b15-fe45183e49a7	78d55485-7910-4c70-a567-070f61d252f7	4956-111-2	apartment	\N	82.78	\N	258319.22
e4547156-63c4-4614-84ff-eec1d1ed0475	78d55485-7910-4c70-a567-070f61d252f7	4956-112-3	apartment	\N	135.82	\N	469314.51
fa9246d3-5989-470d-a832-297eda1ff325	5de2a696-43b5-4dd6-ba50-9e616446dc26	4939-111-1	apartment	\N	69.57	\N	494549.04
0da92c2d-f951-4efd-b287-4937f04dffeb	5de2a696-43b5-4dd6-ba50-9e616446dc26	4939-112-2	apartment	\N	79.21	\N	671205.97
7dec43d0-5f12-4fcc-93f0-4ad64766116a	1b26e061-59f6-4ab7-a510-d66f1f0646b7	4937-111-1	apartment	\N	74.24	\N	469200.00
9bffb63d-30f5-473b-a6ea-7c50398d3420	1b26e061-59f6-4ab7-a510-d66f1f0646b7	4937-112-2	apartment	\N	237.70	\N	666400.00
4a43809c-6d48-4e97-b678-2a9db89f0f5d	8c7a2a9c-7783-4542-b713-87a54c1bd372	4933-110-1	apartment	\N	32.52	\N	177072.00
2cb870d4-5c97-4787-bbe0-54ab68b10895	8c7a2a9c-7783-4542-b713-87a54c1bd372	4933-111-2	apartment	\N	101.26	\N	290224.00
67e3dd6a-f09d-4802-b8e6-6bcbef57c0a1	8c7a2a9c-7783-4542-b713-87a54c1bd372	4933-112-3	apartment	\N	196.73	\N	409904.00
c752ad4d-892e-4b4e-a225-5c765850e40f	8c7a2a9c-7783-4542-b713-87a54c1bd372	4933-113-4	apartment	\N	373.56	\N	600032.00
b9d899df-b33d-4a2b-910a-d86beb0ecc1b	dbd3ba7f-c8a7-4d34-97f5-7a94768a22c6	4932-112-1	apartment	\N	118.45	\N	1088000.00
55adf448-c719-496b-9575-9f8130a14285	dbd3ba7f-c8a7-4d34-97f5-7a94768a22c6	4932-113-2	apartment	\N	338.17	\N	3672000.00
da3d2b49-259a-4996-93b0-842de98b0f93	6cb6258f-ec26-4308-9505-cdfe48f1b5bf	4926-111-1	apartment	\N	75.99	\N	476000.00
8dc55eaa-9be8-46ac-ae3d-113abc7baec7	6cb6258f-ec26-4308-9505-cdfe48f1b5bf	4926-112-2	apartment	\N	111.30	\N	631040.00
5f5f0b0a-f92b-4ad0-a9ef-891b82f45f8b	6cb6258f-ec26-4308-9505-cdfe48f1b5bf	4926-113-3	apartment	\N	200.58	\N	1224000.00
eed96d35-0c83-4258-8dad-095d25409720	876f4c08-9ab1-4694-850d-b2bf96748d5b	4923-164-1	penthouse	\N	267.00	\N	1081200.00
d5adf391-c22b-4101-94a0-37ae2af03c3e	8bb9bca0-6c68-4096-951c-037b3bb4f833	4896-164-1	penthouse	\N	159.98	\N	1044480.00
b076cd95-2ebf-45e1-9836-532679481778	c55bc3f5-eed1-4f8b-9e1e-d210d710895a	4877-111-1	apartment	\N	97.23	\N	255721.89
f7869016-32c2-4387-8fb2-3d0e56ad9876	c55bc3f5-eed1-4f8b-9e1e-d210d710895a	4877-112-2	apartment	\N	115.29	\N	370553.22
a19c6201-0435-480e-8f54-c3c915ea9a69	c55bc3f5-eed1-4f8b-9e1e-d210d710895a	4877-113-3	apartment	\N	185.11	\N	471846.29
1bbc65b1-564c-44d1-9e69-14886755eb69	3560891c-eef7-45d4-9c78-3e7ce450ed5b	4875-111-1	apartment	\N	121.80	\N	418336.00
afe16665-43e3-4cd8-b35c-b6abfd2b55b3	3560891c-eef7-45d4-9c78-3e7ce450ed5b	4875-112-2	apartment	\N	108.42	\N	407456.00
b5e69821-f1ce-4cde-a93d-1f2845357ccf	3560891c-eef7-45d4-9c78-3e7ce450ed5b	4875-113-3	apartment	\N	109.35	\N	409088.00
4c975d0d-70e9-401d-ba5d-eeda8c619a5f	3560891c-eef7-45d4-9c78-3e7ce450ed5b	4875-114-4	penthouse	\N	73.95	\N	420784.00
e58714d5-2455-4f0a-bea0-89642b13fb7b	3560891c-eef7-45d4-9c78-3e7ce450ed5b	4875-115-5	penthouse	\N	460.80	\N	2994992.00
cd9dd21b-6243-458c-976b-6cdc37b90e19	3560891c-eef7-45d4-9c78-3e7ce450ed5b	4875-164-6	penthouse	\N	62.99	\N	646000.00
ffe0e48b-5d44-4e1d-aa74-22e8b40ea6d2	e89b292c-bf84-464b-969b-feae90b47723	4872-111-1	apartment	\N	58.90	\N	281761.54
69edf283-32cc-4db3-967d-8382334edd4c	e89b292c-bf84-464b-969b-feae90b47723	4872-112-2	apartment	\N	88.82	\N	413409.54
2e71715f-4a5a-4416-a11d-9d0c87d3c56d	e89b292c-bf84-464b-969b-feae90b47723	4872-113-3	apartment	\N	130.16	\N	606257.54
0a8f2fe8-ad75-4647-ba5d-8a34ad9c2396	295d0df1-f115-4328-ae16-4f62d8296c46	4866-164-1	penthouse	\N	170.29	\N	1146480.00
7f0b06e7-89e8-4ee4-9330-1cc92656efae	57671b7d-9a36-4f25-b38a-1fffd15e0cbd	4865-164-1	penthouse	\N	165.83	\N	943840.00
2c06f397-10fe-4d1a-9b4f-6e79bd85b8d3	56a13144-49ce-4386-a34f-309de6212414	4839-164-1	penthouse	\N	185.99	\N	1527008.00
c632553c-414a-4af2-b9e6-8b790111ce9a	dddc67e7-0bb2-41f7-a2bd-d291ddb59c31	4814-111-1	apartment	\N	127.80	\N	1135056.00
236fae26-ebf2-4852-84a4-1f9b6afbdcc8	dddc67e7-0bb2-41f7-a2bd-d291ddb59c31	4814-112-2	apartment	\N	192.68	\N	1884688.00
afdae576-7f14-44f3-9898-9ddf87fdf49e	dddc67e7-0bb2-41f7-a2bd-d291ddb59c31	4814-113-3	apartment	\N	350.34	\N	3535728.00
a3369315-483b-4d6b-9bb8-7fabc0112129	dddc67e7-0bb2-41f7-a2bd-d291ddb59c31	4814-341-4	villa	\N	1085.85	\N	26734880.00
010749dd-e176-4069-b69b-bd86edf087d9	b7b9c407-15b8-4483-96a7-8a11fc39cc40	4810-111-1	apartment	\N	85.01	\N	528737.54
8f697112-4363-4328-a78a-47619b92481e	b7b9c407-15b8-4483-96a7-8a11fc39cc40	4810-112-2	apartment	\N	115.01	\N	769457.54
101a515b-0070-4dd9-a692-aa2444802785	b7b9c407-15b8-4483-96a7-8a11fc39cc40	4810-113-3	apartment	\N	170.48	\N	1090961.54
5c3f3ab6-9652-411a-a5f3-63be468562eb	07b844c5-94e0-44e6-a269-e16328520a93	4806-113-1	apartment	\N	139.97	\N	654929.22
72ed53ac-a946-4d85-a441-fba9c3f7fab3	27f334dc-35e5-4fbd-b27e-0be939a62b56	4805-111-1	apartment	\N	69.03	\N	489600.00
57df80d8-af15-492a-8855-3b80a9ca0442	27f334dc-35e5-4fbd-b27e-0be939a62b56	4805-112-2	apartment	\N	166.41	\N	707200.00
85c3e300-dcf6-49e6-8004-e3e82bcdae88	27f334dc-35e5-4fbd-b27e-0be939a62b56	4805-113-3	apartment	\N	197.57	\N	1088000.00
5de7d891-b99e-4094-b4dc-ce33f1c04038	27f334dc-35e5-4fbd-b27e-0be939a62b56	4805-114-4	penthouse	\N	331.14	\N	1496000.00
48451be4-3fe5-433a-a6c4-e2c2fa873106	d28a93d1-6c40-4ca0-99e0-90995a523077	4796-110-1	apartment	\N	43.31	\N	212137.15
113ca372-5cea-4d23-8853-2266549c7a14	d28a93d1-6c40-4ca0-99e0-90995a523077	4796-111-2	apartment	\N	90.09	\N	365404.80
e22bec83-c869-4ab9-8cfe-0e800205fcf1	f1578de6-343d-4330-b897-a75328f11f81	4793-111-1	apartment	\N	98.59	\N	555335.06
e28d6d3d-6420-4f10-a0b9-c6baa55befde	f1578de6-343d-4330-b897-a75328f11f81	4793-112-2	apartment	\N	203.18	\N	812803.18
9d4fae57-1ed7-4462-8aaf-2b7733c6bbd5	f1578de6-343d-4330-b897-a75328f11f81	4793-113-3	apartment	\N	236.90	\N	1806793.46
68cb8b13-02ca-47f9-a300-7f99f67aacb5	9419ad88-b04e-4371-904f-043dc4cd042d	4789-111-1	apartment	\N	76.13	\N	311930.42
19ffcdcd-1321-4303-a95a-258693928611	9419ad88-b04e-4371-904f-043dc4cd042d	4789-112-2	apartment	\N	153.82	\N	486603.92
b8eb415b-8436-4a53-b5a8-c9f453b840ad	5233b178-75cc-48e9-962d-708ed1d04217	4785-111-1	apartment	\N	73.77	\N	573889.54
9c4d8bef-db1e-4d21-9be5-142806b09de5	5233b178-75cc-48e9-962d-708ed1d04217	4785-112-2	apartment	\N	178.47	\N	1315633.54
ce77e53f-9b57-4c7c-bf75-acbd9d4a2789	5233b178-75cc-48e9-962d-708ed1d04217	4785-113-3	apartment	\N	158.31	\N	1788913.54
b60dc7c9-b3e3-4416-a1d4-8269186a19d4	5233b178-75cc-48e9-962d-708ed1d04217	4785-114-4	penthouse	\N	274.06	\N	3095057.54
6512555a-61ef-41a2-98b7-469ec6212c23	2b4f8dd3-74d0-49d8-8ce3-b75677a593d5	4782-111-1	apartment	\N	77.02	\N	399840.00
ce0c459a-f204-463b-939a-27c68815e589	2b4f8dd3-74d0-49d8-8ce3-b75677a593d5	4782-112-2	apartment	\N	154.41	\N	652800.00
541c4820-82ea-4906-98d1-44784d138c87	272a1def-2c8f-4aa5-a5ca-8a9bcffb4150	4780-112-1	apartment	\N	121.60	\N	588063.73
9556a535-8f9f-4baf-9de6-03e73871da89	272a1def-2c8f-4aa5-a5ca-8a9bcffb4150	4780-113-2	apartment	\N	183.75	\N	715903.73
622c2dcf-a858-4280-8b88-822e8a44886f	272a1def-2c8f-4aa5-a5ca-8a9bcffb4150	4780-164-3	penthouse	\N	411.37	\N	705422.48
e45108a3-6a3e-49c6-932e-ca07e8f24f89	e7cbd673-d4d2-46f7-afea-0662bb62d5ed	4740-110-1	apartment	\N	53.20	\N	224338.80
2d15f2ea-c230-430d-b023-c231162cceb5	e7cbd673-d4d2-46f7-afea-0662bb62d5ed	4740-112-2	apartment	\N	125.40	\N	525497.20
080c4a6b-ba77-4cb4-99ff-d3beef6a78b1	e7cbd673-d4d2-46f7-afea-0662bb62d5ed	4740-113-3	apartment	\N	135.17	\N	696598.53
bbaedc22-e35c-4c62-bc75-b2b055e2a038	630b75f3-0b33-40b4-9fad-75e60040b47a	4732-110-1	apartment	\N	38.74	\N	155325.60
1810648c-257e-4ff5-9fc9-a47ef8b86f10	630b75f3-0b33-40b4-9fad-75e60040b47a	4732-111-2	apartment	\N	65.50	\N	293080.00
f7369f88-695f-418f-90cc-077746ad34f9	630b75f3-0b33-40b4-9fad-75e60040b47a	4732-112-3	apartment	\N	114.55	\N	449316.80
68a019e4-2c7c-439f-b8c9-226a398ccaa2	ce5c0b6b-2f45-4dca-abd9-17a1f9e32d64	4731-110-1	apartment	\N	43.20	\N	147981.60
0953d476-c189-4d6d-95d0-cfa20c4317c4	ce5c0b6b-2f45-4dca-abd9-17a1f9e32d64	4731-111-2	apartment	\N	92.07	\N	270857.60
54768b33-87dc-40a8-b0fd-c9ec47edb33c	6a0e6928-d64e-4434-ad23-ede32d5e0a25	4726-111-1	apartment	\N	97.29	\N	377264.00
5e1d1d1d-3657-474d-bd56-b13500511131	6a0e6928-d64e-4434-ad23-ede32d5e0a25	4726-112-2	apartment	\N	137.77	\N	537200.00
dd7a0a64-4bb6-473d-b815-2a7ef1beb2e8	1a8d3fd2-2e21-427e-aea9-0baaa9995c16	4714-112-1	apartment	\N	126.72	\N	437274.00
87cd91a8-19c5-4890-a789-2ed32cde3e15	61539fd9-115b-43e8-9bf9-f439b206547f	4713-110-1	apartment	\N	45.53	\N	182240.00
63c01c8a-2369-41b8-9068-97f14a042ed8	61539fd9-115b-43e8-9bf9-f439b206547f	4713-111-2	apartment	\N	83.30	\N	247520.00
564e832e-af3d-4715-8e7e-8f8ded5f64f6	61539fd9-115b-43e8-9bf9-f439b206547f	4713-112-3	apartment	\N	127.36	\N	375360.00
74bed2de-a2ad-4ddb-ad33-e9335f20e342	61539fd9-115b-43e8-9bf9-f439b206547f	4713-113-4	apartment	\N	172.74	\N	492592.00
0586116c-671d-4574-a997-5e49f109e78f	61539fd9-115b-43e8-9bf9-f439b206547f	4713-114-5	penthouse	\N	244.29	\N	655248.00
12c0a158-1a90-4ff3-b6a9-2491d989b87d	1bcdbcec-0f8a-4bdf-a21c-f6b002ce2794	4709-110-1	apartment	\N	46.27	\N	157488.00
9b55842a-6d97-463a-a171-a82bbdfac15e	1bcdbcec-0f8a-4bdf-a21c-f6b002ce2794	4709-111-2	apartment	\N	86.86	\N	261936.00
cf31aed7-4ac5-453f-85e0-0e985232fd4c	1bcdbcec-0f8a-4bdf-a21c-f6b002ce2794	4709-112-3	apartment	\N	106.84	\N	474368.00
01dc7404-6807-43c0-80ee-7e725815500a	e0bc0e5d-4ff3-4e92-9b40-21654d755c30	4706-110-1	apartment	\N	48.03	\N	167280.00
0660e901-2445-4240-a4b2-a9e6905f38b9	e0bc0e5d-4ff3-4e92-9b40-21654d755c30	4706-111-2	apartment	\N	80.08	\N	251600.00
85d4933e-99db-465a-8a8e-348ea171a717	e0bc0e5d-4ff3-4e92-9b40-21654d755c30	4706-112-3	apartment	\N	119.38	\N	368560.00
513e17af-c64a-4e75-9dca-3ee69b9f8879	60ea40a8-7827-4b67-bb6b-66ae5d1d0215	4705-111-1	apartment	\N	76.27	\N	453665.54
e0a9196c-05ab-4f16-b60e-66bd9df67906	60ea40a8-7827-4b67-bb6b-66ae5d1d0215	4705-112-2	apartment	\N	141.21	\N	894577.54
c0070b91-3753-407c-9bce-79538950d357	60ea40a8-7827-4b67-bb6b-66ae5d1d0215	4705-113-3	apartment	\N	162.02	\N	1262049.54
bcee0e8d-c8d8-4eb8-9bb2-c2494d295292	064975d6-e930-41e8-9c54-068f5e97ede8	4702-110-1	apartment	\N	45.44	\N	202368.00
9502c699-5942-4893-9150-54c946d73cfd	064975d6-e930-41e8-9c54-068f5e97ede8	4702-111-2	apartment	\N	78.95	\N	340000.00
e43f98b1-33fe-4d9d-963b-111f1d9d1946	064975d6-e930-41e8-9c54-068f5e97ede8	4702-112-3	apartment	\N	126.53	\N	510816.00
e1fd4d93-0efe-457a-b97d-f7b5ca54c628	f97cc525-4fb1-4899-ae69-77fd9bc1346c	4698-111-1	apartment	\N	75.98	\N	443631.73
325cbe61-e0f7-4f9b-b6f5-2a0d0704a7d2	f97cc525-4fb1-4899-ae69-77fd9bc1346c	4698-112-2	apartment	\N	110.17	\N	517887.73
d8081a9a-3a29-484f-8a8a-4a5ae906ed21	40b14732-ece7-403c-9198-f9a3f331eae3	4688-114-1	penthouse	\N	294.97	\N	3048576.00
e8a019b1-7f9d-4313-8658-3faafe16fa3b	9c08cc4d-3ef9-4da8-be9a-33d31c974152	4679-112-1	apartment	\N	89.74	\N	476000.00
003da740-ebdd-452d-8172-f1bb81ddb50b	cf6fc1b2-06f1-4978-b04e-47f75f11adff	4678-111-1	apartment	\N	77.81	\N	567936.00
f011f89f-3cd2-4dad-a076-a998907fc942	cf6fc1b2-06f1-4978-b04e-47f75f11adff	4678-112-2	apartment	\N	138.64	\N	831504.00
e257e2c0-f880-4113-b570-deb5e0e1be7f	cf6fc1b2-06f1-4978-b04e-47f75f11adff	4678-113-3	apartment	\N	250.52	\N	1095888.00
1d0b80cf-fa64-4c61-8f48-058916838804	cf6fc1b2-06f1-4978-b04e-47f75f11adff	4678-114-4	penthouse	\N	285.66	\N	1325184.00
9b3822a0-4112-4630-bb9a-272b86ea228e	ed39e78b-d873-4801-9c45-9e1d27fe20c6	4677-113-1	apartment	\N	387.02	\N	2026808.54
f1ac5b62-988c-4904-bf59-02c3a496dab7	ed39e78b-d873-4801-9c45-9e1d27fe20c6	4677-114-2	penthouse	\N	403.83	\N	2339072.16
bd33ae15-6244-4a8e-90e9-81c562ade4e9	9d2f0b2a-c5bb-4e4b-a654-b144f22ccee7	4670-111-1	apartment	\N	100.10	\N	225243.20
d858080f-b9fa-4d64-8a8e-f845ea8009cb	9d2f0b2a-c5bb-4e4b-a654-b144f22ccee7	4670-112-2	apartment	\N	159.35	\N	325042.72
ee5e040e-50f6-43d0-8f84-eaf4de54a43d	e3e740d1-d6a3-4ae3-822f-32d3a7a2d4e9	4616-164-1	penthouse	\N	121.86	\N	637143.68
882a3f54-da6b-413f-9b33-4bc6843cc02b	4f160e23-c807-4496-891a-a64d671658cf	4600-114-1	penthouse	\N	408.22	\N	4535328.00
bcc15a1c-0051-470b-bbcb-dbe779236a92	8dbf701e-3224-4b59-be69-a6d3e4889490	4599-110-1	apartment	\N	44.87	\N	156400.00
6d67d672-633f-492d-8207-c9f25c67a14d	8dbf701e-3224-4b59-be69-a6d3e4889490	4599-111-2	apartment	\N	87.61	\N	284512.00
766eca09-a133-450c-bb3a-fb3db15b8839	8dbf701e-3224-4b59-be69-a6d3e4889490	4599-112-3	apartment	\N	102.94	\N	450704.00
4b2330fe-d53f-4dcf-8678-3edf4a39080b	7227cd34-f4b0-4d2f-9382-6fc07ed9b1b1	4597-111-1	apartment	\N	63.36	\N	318481.54
cf8aab22-11bf-488c-95b3-34f75b9bf2ec	7227cd34-f4b0-4d2f-9382-6fc07ed9b1b1	4597-112-2	apartment	\N	92.16	\N	446865.54
6eb8a42c-c4e7-4b4e-a610-49dffc3f88ba	3b0ef420-af03-4039-a289-00b55308dd19	4596-112-1	apartment	\N	135.71	\N	1095616.00
798f30df-e996-44d0-ab7c-15cf9ffba1c8	3b0ef420-af03-4039-a289-00b55308dd19	4596-113-2	apartment	\N	166.84	\N	1551760.00
57500193-6a71-4e17-8758-a618295275d7	3dc73248-0229-4684-ab5f-e97ce804e2cb	4593-111-1	apartment	\N	105.50	\N	313681.82
1f210afd-d468-4813-b99b-bd78c16560fd	3dc73248-0229-4684-ab5f-e97ce804e2cb	4593-112-2	apartment	\N	197.11	\N	449181.89
2b80dd8d-d4da-4b01-8807-70d5817812a1	a3e189cf-aaaf-4628-92bc-1e19511d3738	4576-110-1	apartment	\N	38.88	\N	233587.34
7c10802f-d66a-46f6-b4ab-b4bc4149ca08	a3e189cf-aaaf-4628-92bc-1e19511d3738	4576-111-2	apartment	\N	71.88	\N	357891.34
6ca02671-97d4-472a-9851-aab79d6e459a	a3e189cf-aaaf-4628-92bc-1e19511d3738	4576-112-3	apartment	\N	97.89	\N	550195.34
8f3461e5-526e-47e3-9cec-ff5f8cc1f505	85ebf052-aa03-44da-9b8d-b0e0ae2ab9c3	4575-111-1	apartment	\N	75.72	\N	353716.42
7103ac7d-b699-4f20-9b15-d0d248ebe564	85ebf052-aa03-44da-9b8d-b0e0ae2ab9c3	4575-112-2	apartment	\N	130.53	\N	459292.94
b1063888-e3a9-4f1b-8667-4975b5f5431f	615e09c6-7401-44ac-b648-3f1d8ecda129	4574-111-1	apartment	\N	80.83	\N	365568.00
709e7745-d619-42d5-84ef-aeac4412f349	615e09c6-7401-44ac-b648-3f1d8ecda129	4574-112-2	apartment	\N	185.71	\N	538016.00
4f807ea7-7a38-4936-ada5-228cb422cd20	615e09c6-7401-44ac-b648-3f1d8ecda129	4574-113-3	apartment	\N	199.09	\N	629136.00
319ab9cc-c259-497c-acb1-c0a60f6750ae	893e4c74-bcf3-4cb9-bcc4-c8d4aac3fe86	4562-110-1	apartment	\N	42.27	\N	161024.00
c80f95ef-8486-4a50-a199-688ceb917815	893e4c74-bcf3-4cb9-bcc4-c8d4aac3fe86	4562-111-2	apartment	\N	114.46	\N	274448.00
0ee8f929-4bfe-43e3-bcaf-d44e28ca5b05	893e4c74-bcf3-4cb9-bcc4-c8d4aac3fe86	4562-112-3	apartment	\N	107.77	\N	462672.00
0bd2de2e-a340-4557-b172-d7baefed04ca	e5a27666-a62d-4c44-b561-6082d21226dd	4558-111-1	apartment	\N	80.74	\N	284614.27
85ba42c0-ed92-4b2f-a5ec-1a43a4860d51	e5a27666-a62d-4c44-b561-6082d21226dd	4558-112-2	apartment	\N	140.40	\N	456493.25
180caca2-167c-49f4-b42e-0fdc8b8788fc	e5a27666-a62d-4c44-b561-6082d21226dd	4558-113-3	apartment	\N	193.66	\N	794656.16
5329525d-ada7-49fc-8a34-c96627ae6276	4111900b-c4ea-46c7-94b5-367ccfd77198	4554-164-1	penthouse	\N	208.77	\N	434112.00
07cc3b2f-0461-4f63-baa5-02820bc60919	6a21733d-8e99-4806-9573-158e18929f6b	4550-113-1	apartment	\N	356.28	\N	1554092.94
293424fc-baf6-464c-95a9-06fea6164d5a	6a21733d-8e99-4806-9573-158e18929f6b	4550-114-2	penthouse	\N	471.30	\N	4780552.05
88fcb6be-fa27-471a-8106-611c42619840	6a21733d-8e99-4806-9573-158e18929f6b	4550-115-3	penthouse	\N	514.78	\N	7466191.10
199fb8bc-2a2d-4c54-ae34-357412d9c2d0	63184687-85dd-4b76-bbb6-cd0aa74cd863	4546-112-1	apartment	\N	215.09	\N	510272.00
3c178f4a-0d63-45b2-baaa-ab8d6b5819fa	63184687-85dd-4b76-bbb6-cd0aa74cd863	4546-113-2	apartment	\N	166.04	\N	537825.60
9c1097a7-2a38-4d24-bd54-847213551e94	63184687-85dd-4b76-bbb6-cd0aa74cd863	4546-164-3	penthouse	\N	426.61	\N	2173280.00
16a6aa78-7aeb-4fea-8f7a-77b6f12393e6	0522a81c-96eb-4d9b-af15-06bf2213f6b9	4544-110-1	apartment	\N	49.35	\N	204000.00
e900331c-4feb-4690-a147-cb739350a6d6	0522a81c-96eb-4d9b-af15-06bf2213f6b9	4544-111-2	apartment	\N	153.59	\N	340000.00
e5ba5f5d-b8a7-4a77-a83a-f13331301e87	0522a81c-96eb-4d9b-af15-06bf2213f6b9	4544-113-3	apartment	\N	258.27	\N	719712.00
de0d7d5a-65a2-4acf-b4f8-ce8e9920e16f	af1223bd-2a45-4d51-a004-3d1b639b49c7	4542-110-1	apartment	\N	42.27	\N	160480.00
137fc186-7edf-4628-92ec-2b1a57d0f9eb	af1223bd-2a45-4d51-a004-3d1b639b49c7	4542-111-2	apartment	\N	114.46	\N	269552.00
a488972f-8f0c-4ef5-aaec-c7a1551b3eb7	af1223bd-2a45-4d51-a004-3d1b639b49c7	4542-112-3	apartment	\N	107.77	\N	462672.00
bd3d18dc-b74f-4720-a63f-9b7cfe44a49d	71286476-2808-4696-8ab6-988ef80d1eff	4540-111-1	apartment	\N	70.14	\N	492561.54
e2525596-2a12-480f-b3a6-6d1c24c084f3	71286476-2808-4696-8ab6-988ef80d1eff	4540-112-2	apartment	\N	133.78	\N	852417.54
26e81423-e16e-418d-a32a-e6e7b10d167b	71286476-2808-4696-8ab6-988ef80d1eff	4540-113-3	apartment	\N	170.38	\N	1074369.54
cf736c12-f5d4-4128-b1d8-322fb38213a1	520cff99-fb86-4d13-8699-272f3d663a96	4524-110-1	apartment	\N	38.83	\N	249142.75
1bc1ad91-71a9-40fc-9e69-2a043aec4c45	520cff99-fb86-4d13-8699-272f3d663a96	4524-111-2	apartment	\N	74.23	\N	342388.16
76445e08-f4b2-481e-95f8-2050232c55d5	520cff99-fb86-4d13-8699-272f3d663a96	4524-112-3	apartment	\N	109.25	\N	461278.27
510ab503-aa06-4dae-b25e-04eb2348b65d	520cff99-fb86-4d13-8699-272f3d663a96	4524-114-4	penthouse	\N	358.74	\N	1269933.46
dcb95dae-c777-4bfd-8138-6f109e1109de	520cff99-fb86-4d13-8699-272f3d663a96	4524-164-5	penthouse	\N	374.57	\N	2741649.84
17768fa5-9271-4ad7-b9b2-48535af01f47	10a7ad5c-3f34-4887-99bb-1960621e7f61	4523-110-1	apartment	\N	36.60	\N	232288.00
07fed66d-0fc1-4591-b723-1bd7e492ca20	10a7ad5c-3f34-4887-99bb-1960621e7f61	4523-111-2	apartment	\N	73.58	\N	297568.00
d9ac5fab-31c2-4030-845d-cedb5a755e04	10a7ad5c-3f34-4887-99bb-1960621e7f61	4523-112-3	apartment	\N	78.87	\N	479536.00
caa4ada8-7185-4ef2-8684-25ed22d6d143	10a7ad5c-3f34-4887-99bb-1960621e7f61	4523-113-4	apartment	\N	123.28	\N	653344.00
b05c4458-b0dc-4713-ac24-ad61913427d3	10a7ad5c-3f34-4887-99bb-1960621e7f61	4523-164-5	penthouse	\N	74.42	\N	220048.00
68240b26-f8ea-4a5f-8f43-3b78d1410438	ebf53a13-445c-4b9e-bdb6-f553b440e760	4518-110-1	apartment	\N	32.70	\N	163200.00
e7488ba3-9a7c-4efd-96a6-6f236d3895c9	ebf53a13-445c-4b9e-bdb6-f553b440e760	4518-111-2	apartment	\N	63.17	\N	279072.00
302674be-720e-43e4-b78c-05013a7619c2	ebf53a13-445c-4b9e-bdb6-f553b440e760	4518-112-3	apartment	\N	86.68	\N	426768.00
212399d8-6ccd-4961-83d9-30affe4013e2	ebf53a13-445c-4b9e-bdb6-f553b440e760	4518-113-4	apartment	\N	127.46	\N	564128.00
20e9d9fc-8df1-4299-bd70-6e679655252a	de6fc1ad-39c9-4e10-a12a-32c6df79134f	4494-110-1	apartment	\N	43.29	\N	203024.61
d2b88d1d-688e-415a-9346-e9596cd33c8c	de6fc1ad-39c9-4e10-a12a-32c6df79134f	4494-111-2	apartment	\N	65.96	\N	356188.08
6b7418cb-9bab-4e3b-a0b6-8bc048fe532b	de6fc1ad-39c9-4e10-a12a-32c6df79134f	4494-112-3	apartment	\N	123.00	\N	484314.77
f96ed246-cb01-422c-8cbc-02ab1636aca1	0c611500-1d53-41e9-bb53-2deb4b2bf516	4396-112-1	apartment	\N	119.51	\N	489328.00
668240d2-1da1-4551-b9f3-15cade15fcb6	7fd397be-e269-43b1-b598-b695195b8bd9	4357-112-1	apartment	\N	142.74	\N	536248.00
4a2836c8-6293-4487-984e-2d754e1812d1	7fd397be-e269-43b1-b598-b695195b8bd9	4357-113-2	apartment	\N	166.88	\N	897872.00
17bbf748-f328-47bf-a36e-5c36708c0622	d44b0960-aa24-453a-8932-2ac0b78e29e1	4356-110-1	apartment	\N	49.51	\N	455599.73
a1a3e71a-b350-43e9-be2a-412b3cfec721	d44b0960-aa24-453a-8932-2ac0b78e29e1	4356-111-2	apartment	\N	89.81	\N	888079.73
28f8e760-1538-418a-862e-21892e526dcb	d44b0960-aa24-453a-8932-2ac0b78e29e1	4356-112-3	apartment	\N	117.14	\N	1278399.73
5cbd3a0b-823c-430f-b7f4-47e8ff51c014	d44b0960-aa24-453a-8932-2ac0b78e29e1	4356-113-4	apartment	\N	204.14	\N	3535999.73
c9e1b5ec-5553-416d-be5f-eb8517b1b2d0	c8065ed5-1fd2-475b-a0ab-936864e985d2	4343-111-1	apartment	\N	106.71	\N	604928.00
8ed2902d-05ba-4855-adb9-6895d53d42cd	c8065ed5-1fd2-475b-a0ab-936864e985d2	4343-112-2	apartment	\N	144.07	\N	903040.00
5a52303c-610b-4060-93f5-389816118df6	c8065ed5-1fd2-475b-a0ab-936864e985d2	4343-113-3	apartment	\N	191.59	\N	1684224.00
10212c95-deee-4fe0-962f-0022ddd42855	9db890e7-430f-472d-a382-2690e8cf0025	4340-111-1	apartment	\N	72.68	\N	490498.69
74499e94-fa09-44d1-8068-3ba1fe342746	9db890e7-430f-472d-a382-2690e8cf0025	4340-112-2	apartment	\N	111.67	\N	719432.11
69ed5469-3232-4faa-a01d-e1e0ca98fe08	a16807e4-6c5c-4b77-8dba-09728d2f9e31	4339-112-1	apartment	\N	203.46	\N	539079.25
f21f5ee2-fda1-405e-a9b2-46b04ce07d8e	a16807e4-6c5c-4b77-8dba-09728d2f9e31	4339-113-2	apartment	\N	216.37	\N	666238.70
1e5ada40-bf46-4298-928b-274aac910491	79675d23-fd13-4cd3-bf78-b61b140294e1	4338-111-1	apartment	\N	93.06	\N	680544.00
9bb17a7c-e4da-4776-aa4f-fd65a3d38623	79675d23-fd13-4cd3-bf78-b61b140294e1	4338-112-2	apartment	\N	259.66	\N	1559920.00
b8d5bb48-f44f-4f17-85ae-4d9d6d6ad69b	79675d23-fd13-4cd3-bf78-b61b140294e1	4338-113-3	apartment	\N	174.47	\N	1398896.00
734fb0e9-11ce-4c4a-a832-4801371e8e3b	79675d23-fd13-4cd3-bf78-b61b140294e1	4338-164-4	penthouse	\N	233.47	\N	1219104.00
a4e641cf-f2bf-4cd2-a045-68f3518911c2	22005eda-eee3-44d0-befe-2f349a337cfa	4337-110-1	apartment	\N	42.74	\N	461856.00
3ab781a6-441d-43f8-8f6f-a90ff5b07ab0	22005eda-eee3-44d0-befe-2f349a337cfa	4337-111-2	apartment	\N	99.69	\N	770576.00
dbe97ad5-fabd-403f-8370-b6bb111acb8f	22005eda-eee3-44d0-befe-2f349a337cfa	4337-112-3	apartment	\N	111.95	\N	1182656.00
d74598c3-13a6-4138-9830-aeb70fe5c9e3	22005eda-eee3-44d0-befe-2f349a337cfa	4337-164-4	penthouse	\N	302.12	\N	1589568.00
1e4a093e-c7b1-4e02-96f6-65269cf353cd	24faf8ff-9299-496b-91ee-c6f6aade37c2	4331-111-1	apartment	\N	62.52	\N	273826.48
ab827816-ad4f-4701-9bd3-fc5739e59ffa	73505510-137f-4877-a2ea-ecd30b8a0af5	4327-111-1	apartment	\N	130.69	\N	1047200.00
c7cd4c26-9958-4f1a-b2ed-60dbffd3711c	73505510-137f-4877-a2ea-ecd30b8a0af5	4327-112-2	apartment	\N	194.26	\N	1648320.00
8e0f744c-d212-4935-b491-8f3a895d57d4	73505510-137f-4877-a2ea-ecd30b8a0af5	4327-113-3	apartment	\N	340.48	\N	3402720.00
682f7944-de35-4a72-802e-0213dfdb59d6	73505510-137f-4877-a2ea-ecd30b8a0af5	4327-114-4	penthouse	\N	436.44	\N	6465440.00
a7213e41-592b-4fcb-a9a5-de1993982b9a	73505510-137f-4877-a2ea-ecd30b8a0af5	4327-115-5	penthouse	\N	581.26	\N	9396240.00
a1f97595-dbda-4577-9aff-6d43b2ef0481	73505510-137f-4877-a2ea-ecd30b8a0af5	4327-341-6	villa	\N	1359.02	\N	23936000.00
41a7412c-c875-40a7-b1e0-b2676c3b7978	5666f026-4208-4400-be64-8f72fb4f72c8	4319-111-1	apartment	\N	104.01	\N	580720.00
8633a296-971d-4944-b1b0-3fefb8792e7f	5666f026-4208-4400-be64-8f72fb4f72c8	4319-112-2	apartment	\N	274.44	\N	878560.00
425c3d87-5c48-4dfe-8627-5d454e470fa4	081e9880-0dfb-4b91-aff1-f017ceb5c4c1	4309-110-1	apartment	\N	38.46	\N	191672.14
ab6bca87-f68f-4eff-bae4-16741d3093d4	717b7d12-9773-4301-bee3-19dac0034731	4308-112-1	apartment	\N	118.30	\N	360128.00
fe1f27ce-9675-4733-8963-1488010bbcd8	717b7d12-9773-4301-bee3-19dac0034731	4308-113-2	apartment	\N	262.25	\N	603840.00
d8981261-f82f-4e89-bb27-6dfab681f584	91b8ccd2-7e05-4dce-814c-ca99267b2369	4307-111-1	apartment	\N	84.82	\N	584948.24
baffd3aa-3370-4ae1-a979-21994893457e	91b8ccd2-7e05-4dce-814c-ca99267b2369	4307-112-2	apartment	\N	252.51	\N	802779.17
3658c969-2bca-4102-9166-947482d664b6	91b8ccd2-7e05-4dce-814c-ca99267b2369	4307-113-3	apartment	\N	440.45	\N	1291116.00
988d6867-beb9-4d4d-91ac-33df6074aceb	91b8ccd2-7e05-4dce-814c-ca99267b2369	4307-114-4	penthouse	\N	491.09	\N	5231967.06
f179b9a3-4fd8-49a5-8f96-4e9e64cb720d	fd3e3c38-b96c-4e05-a886-187abba393e3	4306-112-1	apartment	\N	104.52	\N	362457.68
cd8369ea-3611-42f1-a020-133751d00a4b	442eaf93-eeb8-4e34-a82e-0f885331d0ff	4304-111-1	apartment	\N	102.00	\N	313083.15
028d7c88-da31-43cb-99df-afe6a0b5115c	442eaf93-eeb8-4e34-a82e-0f885331d0ff	4304-112-2	apartment	\N	223.00	\N	460409.23
e9c17d10-903f-441f-89ef-2518274cd3df	442eaf93-eeb8-4e34-a82e-0f885331d0ff	4304-113-3	apartment	\N	296.00	\N	657812.96
7681065e-1e87-426c-a49c-2a96d43846c9	a6809811-1b44-4cde-b9eb-b0f66d0b374e	4297-111-1	apartment	\N	93.04	\N	806752.00
32a34a93-331f-4d3e-adc1-8c018703f79c	a6809811-1b44-4cde-b9eb-b0f66d0b374e	4297-112-2	apartment	\N	154.16	\N	1269696.00
b4aceb9c-2258-423f-a82d-1b00909fa191	a6809811-1b44-4cde-b9eb-b0f66d0b374e	4297-113-3	apartment	\N	190.02	\N	1496816.00
5ef3807f-cdc3-4d52-aca7-089b139e84a7	834b35e6-44bb-4572-8587-b3f0103a4beb	4296-111-1	apartment	\N	98.81	\N	489600.00
88fe32f5-4212-4ed6-a4a6-f1dcd1f761b0	e9382800-032e-43e4-90a2-bc39c24bbc02	4295-111-1	apartment	\N	102.66	\N	462400.00
b1ecf67b-7eb2-4cc1-8e56-67311e67024a	b77de1b1-69b3-42b4-af6f-8206639720c8	4292-113-1	apartment	\N	170.77	\N	761600.00
1d047167-449e-460b-a767-70c5efde9ba6	57939172-0965-4331-b16a-7347be35c0bb	4289-112-1	apartment	\N	137.77	\N	776016.00
6f96c35f-8073-4562-94fd-7680bc6f4ebd	57939172-0965-4331-b16a-7347be35c0bb	4289-113-2	apartment	\N	172.41	\N	1700816.00
cd29d496-9f1c-46e7-88c9-a1ee4b0cc383	5969d8cb-8639-4cf0-a85e-39ee50a93046	4288-111-1	apartment	\N	76.34	\N	584753.22
24ce2520-e765-45d7-824b-a03d131da4ae	5969d8cb-8639-4cf0-a85e-39ee50a93046	4288-112-2	apartment	\N	116.51	\N	833361.22
635a3aeb-268e-4492-b7aa-3a680ff84a43	5969d8cb-8639-4cf0-a85e-39ee50a93046	4288-113-3	apartment	\N	181.12	\N	1228305.22
7a110b03-b0aa-4e2f-b7ff-3a110edfc4e2	65b3d08d-e034-4fb8-9229-5f1c3cc8b8e9	4287-110-1	apartment	\N	34.50	\N	197267.46
3eb3662b-5e8b-404c-9068-1fb4306d6f9b	65b3d08d-e034-4fb8-9229-5f1c3cc8b8e9	4287-111-2	apartment	\N	63.45	\N	302796.66
fdd8319b-6592-46d5-a0c6-ff9a2bea1983	65b3d08d-e034-4fb8-9229-5f1c3cc8b8e9	4287-112-3	apartment	\N	105.82	\N	534284.70
e373713e-eb24-44eb-acb5-3a658da5ef74	65b3d08d-e034-4fb8-9229-5f1c3cc8b8e9	4287-113-4	apartment	\N	191.69	\N	990358.80
f7f2ff4d-b06e-40db-90a1-d21c2045ae04	acf9b767-2781-4deb-b5f1-aa3a9cfbda40	4286-164-1	penthouse	\N	221.08	\N	930240.00
2242ab39-6005-4ed6-b8b5-49ac8e3a9061	983ad764-e57c-4ba6-8ab7-a422b768c237	4280-110-1	apartment	\N	81.85	\N	220021.07
b2e99ca6-e8be-4f0e-a651-1da4f0831652	983ad764-e57c-4ba6-8ab7-a422b768c237	4280-111-2	apartment	\N	110.00	\N	338815.44
fc16f2d9-4060-4f72-b31f-ad09ae0a3eaa	983ad764-e57c-4ba6-8ab7-a422b768c237	4280-112-3	apartment	\N	103.87	\N	496680.98
16f37a3e-7d9b-48b5-934e-012bb2197b2b	ba84439c-9064-4de5-8343-88ff41ebb52a	4273-164-1	penthouse	\N	1430.32	\N	715360.00
e0a67d9e-79fd-4c02-895a-8876882aecde	b3e0ab96-c2bf-4cc7-9685-4ec563b037df	4254-110-1	apartment	\N	31.68	\N	160480.00
015c6c38-9816-4f1e-a7c3-620c32be3470	b3e0ab96-c2bf-4cc7-9685-4ec563b037df	4254-111-2	apartment	\N	63.17	\N	257584.00
ad8d7456-7209-410a-b624-eb7ec0b4f10c	b3e0ab96-c2bf-4cc7-9685-4ec563b037df	4254-112-3	apartment	\N	98.43	\N	452064.00
8a417e55-fa7f-44cd-9675-d47146af3b56	b3e0ab96-c2bf-4cc7-9685-4ec563b037df	4254-113-4	apartment	\N	278.90	\N	652256.00
faa3abbb-364d-422d-b563-d5867c91f99d	1ebe7eea-4f43-4ab9-b65f-5b7fef604695	4231-113-1	apartment	\N	237.55	\N	2909040.00
17c14cc7-615f-4c57-bb4f-5740d71fe1ef	1ebe7eea-4f43-4ab9-b65f-5b7fef604695	4231-114-2	penthouse	\N	322.56	\N	9969072.00
de447ff7-7358-439c-a2a3-47c51511e238	39d0d8d1-d1b5-4a76-8a1d-131b3bf3c73a	4224-111-1	apartment	\N	85.82	\N	688232.08
bcec47f2-59a3-468f-bcb0-c9b275e660a6	39d0d8d1-d1b5-4a76-8a1d-131b3bf3c73a	4224-113-2	apartment	\N	186.53	\N	1238999.71
108a5fc7-554d-49d5-b4f6-6ac62fcadffe	39d0d8d1-d1b5-4a76-8a1d-131b3bf3c73a	4224-114-3	penthouse	\N	366.76	\N	2134325.79
7c25b8e8-7ada-4648-8ec3-5fc823823a4b	312c2512-9817-42e5-8f5d-7a23b064f899	4218-111-1	apartment	\N	85.01	\N	289136.00
f5299cf7-34b9-40b2-9b15-52fb4073512e	312c2512-9817-42e5-8f5d-7a23b064f899	4218-112-2	apartment	\N	124.12	\N	434112.00
985d0535-cb97-4ff6-b0c3-fa5eb3ccc02a	35f6fce4-6882-4416-b57e-e3c992a31a4b	4217-164-1	penthouse	\N	233.27	\N	489297.54
5a72311c-a4d4-4b71-9c4e-d0a6eb294b0e	15a63d21-44c6-4550-9716-9d41c4522671	4212-110-1	apartment	\N	40.23	\N	215968.00
17c8603a-e580-4f4e-865b-cd7e7f5ef1ed	15a63d21-44c6-4550-9716-9d41c4522671	4212-111-2	apartment	\N	94.58	\N	345440.00
3dc6ee88-0df0-4067-8fe2-4929f2bcab19	15a63d21-44c6-4550-9716-9d41c4522671	4212-112-3	apartment	\N	144.84	\N	448800.00
d2416066-98db-4972-8b1d-2f6503ca4aca	e3a54d5a-b249-46f3-8f75-1412245bd9f8	4208-111-1	apartment	\N	79.38	\N	245616.00
9f0cce35-d36c-429e-9d17-8a48d8a7577b	e3a54d5a-b249-46f3-8f75-1412245bd9f8	4208-112-2	apartment	\N	121.38	\N	404453.39
ecc4dcb8-9add-4cb1-b2ee-9889e40d4dc2	7552a51d-bbb8-462a-9b3f-6e14d9bc00bf	4204-112-1	apartment	\N	121.87	\N	677793.54
07e9e184-e6f8-470b-8b4c-d1e11a40360f	7552a51d-bbb8-462a-9b3f-6e14d9bc00bf	4204-113-2	apartment	\N	219.28	\N	819777.54
7496b00b-9e7b-48a8-b858-0f6934faf0d3	84a9633a-c363-467b-a298-a61a8f83ada8	4202-111-1	apartment	\N	156.99	\N	418774.46
30b0138f-f4d6-4f25-9fac-2978e31aa470	84a9633a-c363-467b-a298-a61a8f83ada8	4202-112-2	apartment	\N	145.28	\N	717656.50
61ae5160-4232-4bde-b4d1-00e509d6a35f	cef3d5cf-8c02-41c3-88aa-280ba6c9daa2	4199-112-1	apartment	\N	99.69	\N	459105.54
fc28d3cc-86b9-4f74-8cb6-8f20da62a473	378b456b-47bb-433c-a939-5324f4083810	4198-111-1	apartment	\N	75.14	\N	483854.27
a0e26f0d-cb0a-4bbb-8502-a2cf1cd4b870	378b456b-47bb-433c-a939-5324f4083810	4198-112-2	apartment	\N	131.42	\N	699548.37
1da5dd6b-c111-47ec-baa9-53eaf4127250	378b456b-47bb-433c-a939-5324f4083810	4198-164-3	penthouse	\N	606.00	\N	5491922.35
30251baa-34bf-4e6f-bca1-f9e0316988bc	f66ffb4c-1d18-4ae2-89ba-eb7f37e4168f	4197-164-1	penthouse	\N	198.03	\N	1402160.00
e90d18b3-cc0e-411d-a80b-0b8bb071842e	e02c0c20-49b7-4571-a61d-6ed2a3a62873	4193-111-1	apartment	\N	103.75	\N	721542.29
fef79edf-2039-447a-aecb-c5a99ed04449	e02c0c20-49b7-4571-a61d-6ed2a3a62873	4193-113-2	apartment	\N	156.49	\N	1178639.38
6272e890-d2e9-440f-81f4-1d72e0b01207	874951db-0daa-43be-813c-6c72d0f7a9a8	4185-112-1	apartment	\N	203.09	\N	4080000.00
dc5cd4aa-7660-472a-9203-0bc40659048e	874951db-0daa-43be-813c-6c72d0f7a9a8	4185-113-2	apartment	\N	313.92	\N	6256000.00
744ed80b-4ce7-46f6-b5c2-ed7942056335	874951db-0daa-43be-813c-6c72d0f7a9a8	4185-114-3	penthouse	\N	396.79	\N	11424000.00
335cc949-ae3a-411a-bd0a-20c3d08494de	d4f11e1d-c7df-4b4d-8759-ac32c45eb6e7	4182-110-1	apartment	\N	40.23	\N	220262.88
35835439-524c-4719-8963-0d01ba0092cb	d4f11e1d-c7df-4b4d-8759-ac32c45eb6e7	4182-111-2	apartment	\N	84.54	\N	306187.68
201490f2-c83f-4759-a357-b433e2673d91	c36e76ad-a89c-4924-b9d2-452c7f901eb6	4179-111-1	apartment	\N	78.54	\N	285600.00
02432ff9-28dc-4bd2-97e5-c487e301862e	c36e76ad-a89c-4924-b9d2-452c7f901eb6	4179-112-2	apartment	\N	152.46	\N	428400.00
43a2783b-9fd8-4a66-9bc4-feb1052d9a8f	4a9b21c6-21bb-4410-b069-317e69bebdd6	4172-110-1	apartment	\N	40.51	\N	200425.10
08fb311f-9ade-4725-bcc6-ceb4d1ae0fa9	4a9b21c6-21bb-4410-b069-317e69bebdd6	4172-112-2	apartment	\N	109.07	\N	431365.07
7980be88-52ca-4e49-8b84-fa2a3ed719b4	5ee220b7-c7d5-4526-8e20-edf049331220	4169-110-1	apartment	\N	42.45	\N	209957.62
0961c9da-7d32-4462-b862-210015170424	5ee220b7-c7d5-4526-8e20-edf049331220	4169-111-2	apartment	\N	81.38	\N	344608.77
a124b9d0-da9b-4ee9-8881-7aac7dac9788	20fa6af8-a548-4d98-b473-a5a58efce541	4167-111-1	apartment	\N	72.68	\N	519882.58
8831f3c2-e958-4dc7-8b2f-2f58bf3b6948	20fa6af8-a548-4d98-b473-a5a58efce541	4167-112-2	apartment	\N	144.37	\N	699837.23
f77f5a71-b721-49f5-a206-5ca1dc72532a	9bca98d6-dde4-46eb-ba08-6ec0db6065f6	4165-164-1	penthouse	\N	128.30	\N	979275.89
e8921381-dd68-40e8-bfb4-b5cbd9f12060	c9273af1-31c2-4416-a417-68aae9f355d2	4160-111-1	apartment	\N	129.97	\N	625600.00
ec01ff0e-3272-46f7-b279-a0b4a6b9d4c2	c9273af1-31c2-4416-a417-68aae9f355d2	4160-112-2	apartment	\N	218.51	\N	775200.00
20accc2c-08a9-4afc-8e8f-434fd3ec8820	c9273af1-31c2-4416-a417-68aae9f355d2	4160-113-3	apartment	\N	312.53	\N	1438880.00
4f3a994f-6f06-4a2e-adb4-c431440acb21	5865a7f3-94ee-4ba9-b19b-f6c0008db7ff	4155-110-1	apartment	\N	35.48	\N	221652.80
5832f01c-9b21-4370-bc0c-6ef1ce638e61	5865a7f3-94ee-4ba9-b19b-f6c0008db7ff	4155-111-2	apartment	\N	91.84	\N	299172.80
29a53e2c-aba4-42c8-880b-8615c488a62d	5865a7f3-94ee-4ba9-b19b-f6c0008db7ff	4155-112-3	apartment	\N	89.30	\N	429732.80
c8a5fe8c-a892-409d-a8f7-115a3d3300d5	eb9abee6-12c1-4c3b-92f9-ca251a983dd7	4152-110-1	apartment	\N	59.27	\N	335920.00
3a9e46dd-6287-4c8b-b9d5-3ab47dbb92bd	eb9abee6-12c1-4c3b-92f9-ca251a983dd7	4152-164-2	penthouse	\N	133.32	\N	760240.00
b5dfc6e1-51c2-4915-8690-4121701c256f	c38f6789-51dc-4fd6-887d-45d2b9e7ddb5	4150-110-1	apartment	\N	42.74	\N	448528.00
39655efe-f48b-4790-acd3-3742a2166bd0	c38f6789-51dc-4fd6-887d-45d2b9e7ddb5	4150-111-2	apartment	\N	105.17	\N	736304.00
1d9ed067-cb10-4cb0-8c34-6b30e5aaf1da	c38f6789-51dc-4fd6-887d-45d2b9e7ddb5	4150-112-3	apartment	\N	123.04	\N	1104864.00
c29d8939-c41f-48cb-bf45-cebfa4176b31	c38f6789-51dc-4fd6-887d-45d2b9e7ddb5	4150-113-4	apartment	\N	198.81	\N	3330640.00
9d9f08e5-ab02-40ef-a352-231784573f3b	c38f6789-51dc-4fd6-887d-45d2b9e7ddb5	4150-164-5	penthouse	\N	349.41	\N	2074000.00
ac4bdb9c-79e3-40e9-b974-2d8b483a98d0	3e6aa29f-d637-42db-a505-f305e1667d28	4147-111-1	apartment	\N	72.00	\N	495281.54
84cfa6c5-14a1-41ab-aaf2-b90244df5576	3e6aa29f-d637-42db-a505-f305e1667d28	4147-112-2	apartment	\N	133.50	\N	956321.54
f0f3fc8c-9994-4c72-95d3-eb91035e9aa7	3e6aa29f-d637-42db-a505-f305e1667d28	4147-113-3	apartment	\N	387.03	\N	1156513.54
78cc3105-7aa7-4e01-88b3-0a02cf06ede8	86af8bf1-ee5e-4159-bb03-4a9f55e35f91	4146-110-1	apartment	\N	42.81	\N	171360.00
5624732e-cf93-4fc1-bfc1-04cc0affa840	86af8bf1-ee5e-4159-bb03-4a9f55e35f91	4146-111-2	apartment	\N	85.15	\N	266560.00
180b1db5-e49d-4b47-a15e-def2dac1325c	86af8bf1-ee5e-4159-bb03-4a9f55e35f91	4146-112-3	apartment	\N	114.93	\N	443088.00
91a33c3d-2fc7-4934-8cd2-258b31cec58d	4e1d5428-5047-4e34-adfd-0691d305a1f2	4134-111-1	apartment	\N	77.59	\N	565209.20
ec49d9c3-f0cf-493e-918c-d94a2f845de5	4e1d5428-5047-4e34-adfd-0691d305a1f2	4134-112-2	apartment	\N	166.79	\N	855694.86
c1ff0cc2-6944-4391-a3ce-fe19e7e6a953	4e1d5428-5047-4e34-adfd-0691d305a1f2	4134-113-3	apartment	\N	291.52	\N	1302511.44
e8e03983-7d85-43b8-b38e-69adcbd4ac1d	ce70f430-4bea-4a1d-a67f-34a9a07dd2a2	4116-110-1	apartment	\N	60.29	\N	224185.66
2fc96821-2190-43c5-92e5-a302a743ee61	ce70f430-4bea-4a1d-a67f-34a9a07dd2a2	4116-111-2	apartment	\N	214.70	\N	362171.54
16c63465-7e34-493b-84b6-485e29de2b84	ce70f430-4bea-4a1d-a67f-34a9a07dd2a2	4116-112-3	apartment	\N	168.74	\N	475403.50
c93c3a73-2d6d-4d49-a43c-00332123c5dd	6fd1d7dd-0ec8-4e10-a44b-a791fe959662	4110-112-1	apartment	\N	128.94	\N	417248.00
95e38964-6693-408d-b86e-235cafb696c8	6fd1d7dd-0ec8-4e10-a44b-a791fe959662	4110-113-2	apartment	\N	199.94	\N	672384.00
5cec19c5-d83d-4534-96d3-b399b70a28ea	5079931d-06b5-47a8-bed2-41101ba331eb	4102-111-1	apartment	\N	156.24	\N	333611.26
05cc9dc3-1af0-4eae-aa2f-75642054c9af	5079931d-06b5-47a8-bed2-41101ba331eb	4102-112-2	apartment	\N	182.38	\N	470623.38
f23ea8c8-8519-46c7-9d2d-e770b92de053	07452643-f416-401c-8c20-ece7cf2fe551	4099-110-1	apartment	\N	36.98	\N	159936.00
499023b5-4f3a-45b3-9e6e-a3a4388138c5	07452643-f416-401c-8c20-ece7cf2fe551	4099-111-2	apartment	\N	118.82	\N	267104.00
c3fe2468-1557-41f9-bba0-e82bd485a002	07452643-f416-401c-8c20-ece7cf2fe551	4099-112-3	apartment	\N	192.22	\N	456416.00
de54b3ec-167a-4180-a6aa-ad8f2c97334a	07452643-f416-401c-8c20-ece7cf2fe551	4099-113-4	apartment	\N	214.05	\N	578000.00
36c6b4ee-b084-474a-adfd-5faedb86d6bc	129f5180-1df0-4483-8079-0edd5805809d	4097-110-1	apartment	\N	33.26	\N	159392.00
ea1f7cc2-1d14-4ca3-9ac6-31dd8fe77599	129f5180-1df0-4483-8079-0edd5805809d	4097-111-2	apartment	\N	79.34	\N	269008.00
dd1660b8-538a-4206-85e3-12549148d52d	129f5180-1df0-4483-8079-0edd5805809d	4097-112-3	apartment	\N	117.24	\N	467568.00
4491f1dd-08b0-412b-8e07-324ed527976a	129f5180-1df0-4483-8079-0edd5805809d	4097-113-4	apartment	\N	148.09	\N	552160.00
335b081c-1f08-48f8-9b7b-4fce1855c7ed	7b6adca3-97e4-4674-a8ab-3fc157bd04ee	4093-110-1	apartment	\N	87.36	\N	185473.54
74b24651-d5c8-4a5a-91a5-aaf04fbe0b0e	7b6adca3-97e4-4674-a8ab-3fc157bd04ee	4093-111-2	apartment	\N	83.00	\N	246401.54
e6d892ee-0f01-41b8-8765-18a2f3f31db0	7b6adca3-97e4-4674-a8ab-3fc157bd04ee	4093-112-3	apartment	\N	131.77	\N	376417.54
635ea829-f4e0-4f14-8ef8-51476cfce70b	7b6adca3-97e4-4674-a8ab-3fc157bd04ee	4093-113-4	apartment	\N	164.03	\N	457201.54
e5331ec3-95fa-424d-8848-221b04cc33c9	301ffbb8-f5a1-4bf7-bd96-3c4bd2946efa	4090-110-1	apartment	\N	44.38	\N	213700.61
a69f5538-df2f-4b97-878a-ea78cb57bcb5	301ffbb8-f5a1-4bf7-bd96-3c4bd2946efa	4090-111-2	apartment	\N	62.43	\N	261911.52
630ff33f-2c1b-4a92-bfd7-b07b5f2019ca	301ffbb8-f5a1-4bf7-bd96-3c4bd2946efa	4090-112-3	apartment	\N	93.95	\N	390455.46
44e1dfb2-2a0e-4db5-b136-f4ad252aec51	301ffbb8-f5a1-4bf7-bd96-3c4bd2946efa	4090-113-4	apartment	\N	129.78	\N	511260.99
0fbd96dc-e2d3-4c8b-b90a-eb5206f97751	387db737-4326-409d-96c6-7fae8e21cd9a	4085-112-1	apartment	\N	129.23	\N	654432.00
57b0fff4-3b71-48ff-a7d9-e52eb5d34a92	387db737-4326-409d-96c6-7fae8e21cd9a	4085-113-2	apartment	\N	241.83	\N	847824.00
f9e84bdf-2446-41c4-9fd9-b496b99fc45a	c584afa7-04c1-45ea-9dd1-da41149d4fd0	4080-111-1	apartment	\N	82.03	\N	774959.01
ef8e590e-3366-432f-b17c-5c7d34c6c751	c584afa7-04c1-45ea-9dd1-da41149d4fd0	4080-112-2	apartment	\N	147.26	\N	2119190.35
acd86b33-0bd4-41a2-9e2c-d445cbc712fc	c584afa7-04c1-45ea-9dd1-da41149d4fd0	4080-113-3	apartment	\N	201.62	\N	1828352.45
2fd49241-5839-4325-917c-03a68a78fd38	7b12072a-f4a4-48dd-b40e-bc3d5ab09fba	4069-111-1	apartment	\N	89.65	\N	483344.00
a4efbd11-4b77-40b5-b683-3933edcd7f01	7b12072a-f4a4-48dd-b40e-bc3d5ab09fba	4069-112-2	apartment	\N	135.36	\N	795600.00
2ec74bc6-c8a6-40e5-94a7-b34ee35aa2df	12820bd1-d415-4ca0-b883-a1302ecd359e	4066-110-1	apartment	\N	62.71	\N	215016.00
a53604b8-ea2c-43dc-934d-7b8f4a68aae0	12820bd1-d415-4ca0-b883-a1302ecd359e	4066-111-2	apartment	\N	106.21	\N	332928.00
5251628e-9558-4ed0-aafa-785959af7ca3	12820bd1-d415-4ca0-b883-a1302ecd359e	4066-112-3	apartment	\N	151.44	\N	469200.00
f53ee04d-650e-4942-923a-1da361e083d2	12820bd1-d415-4ca0-b883-a1302ecd359e	4066-113-4	apartment	\N	194.53	\N	811512.00
1e77e948-f32f-4a85-b7e3-33adccde2326	230b855e-5679-47a2-a5af-0e1f5c3274bc	4055-110-1	apartment	\N	51.86	\N	312527.73
3d925578-77a3-40c3-b3b7-875da560993e	230b855e-5679-47a2-a5af-0e1f5c3274bc	4055-111-2	apartment	\N	97.34	\N	531759.73
3edd3755-e9c3-49b9-8b58-a062cf7f4eb0	230b855e-5679-47a2-a5af-0e1f5c3274bc	4055-112-3	apartment	\N	237.76	\N	790159.73
f4f2a776-a3c7-4c89-996f-0ba8a17ea468	230b855e-5679-47a2-a5af-0e1f5c3274bc	4055-164-4	penthouse	\N	1143.15	\N	4228734.50
21095ba0-b543-416c-9e7d-f645fef5d069	28492275-50b8-4781-9723-151b3caf5d91	4051-110-1	apartment	\N	44.47	\N	208932.45
1759dfd2-2e60-4efb-bf24-c8a2c39f803b	28492275-50b8-4781-9723-151b3caf5d91	4051-112-2	apartment	\N	115.51	\N	431802.99
50c8671c-5b41-44c9-a817-f897400df511	28492275-50b8-4781-9723-151b3caf5d91	4051-113-3	apartment	\N	144.60	\N	514160.24
1fba444b-1acc-49a7-aa8a-8a4b675e90ee	35ceff68-98ec-45c3-bfa4-1977591be34d	4045-112-1	apartment	\N	106.02	\N	492592.00
bcc6c82a-d185-46bf-a03e-86c50df486fb	35ceff68-98ec-45c3-bfa4-1977591be34d	4045-113-2	apartment	\N	187.49	\N	637024.00
cbb22093-6da5-4174-84e3-e73fed445774	cf48cdf8-d77c-4c57-9e6f-4440ee337f81	4030-110-1	apartment	\N	37.72	\N	211888.00
5d85386f-a4ac-4665-aef8-a59ab7d1bc8f	cf48cdf8-d77c-4c57-9e6f-4440ee337f81	4030-111-2	apartment	\N	89.22	\N	307088.00
cd8e48db-a615-4312-a94d-549e6ce60106	cf48cdf8-d77c-4c57-9e6f-4440ee337f81	4030-112-3	apartment	\N	109.81	\N	511088.00
059bcbc0-d30b-40b6-93b7-f25e77be88aa	44ccd0d7-0ed8-4604-aeec-28abbf8ff184	4003-113-1	apartment	\N	237.92	\N	2292960.00
ab719f07-652c-461e-a3ae-115979d25e22	44ccd0d7-0ed8-4604-aeec-28abbf8ff184	4003-114-2	penthouse	\N	265.70	\N	2771136.00
6c7e508d-db81-43e0-b1de-5edfd50f3043	44ccd0d7-0ed8-4604-aeec-28abbf8ff184	4003-115-3	penthouse	\N	676.15	\N	6785040.00
c021490c-8eec-44cd-b9f6-d9e592bbbfce	de61dffa-3485-40c1-92bf-e1531ea9ec30	3976-110-1	apartment	\N	46.45	\N	195709.71
1cceb861-de0e-4455-8ec9-ffb26699ae46	686327aa-68dc-4fe7-9105-59f330b2093b	3961-113-1	apartment	\N	188.04	\N	3036880.00
d2d730ae-b505-46b8-92bc-baf9b23c2052	b93cb50f-8797-4771-9d7b-ec4943e4c749	3942-110-1	apartment	\N	41.04	\N	209566.21
be537af3-c07b-4d45-a85e-813b81c90e2e	b93cb50f-8797-4771-9d7b-ec4943e4c749	3942-112-2	apartment	\N	129.11	\N	459123.22
68f9e372-3418-4353-8639-1ae87011839e	b93cb50f-8797-4771-9d7b-ec4943e4c749	3942-113-3	apartment	\N	147.44	\N	716415.63
49f60a22-afee-468f-865e-943e1e240d6a	5d853019-cb0d-4411-9f28-a13df5443602	3939-111-1	apartment	\N	81.48	\N	632177.78
25f95929-b48a-488a-b473-824514f74e76	5d853019-cb0d-4411-9f28-a13df5443602	3939-112-2	apartment	\N	155.73	\N	891369.30
aa8bc624-4ab1-4227-9038-27c892a777f6	5d853019-cb0d-4411-9f28-a13df5443602	3939-113-3	apartment	\N	156.38	\N	1235708.78
a11325fd-ba74-4f97-8b25-446b861620d9	5d853019-cb0d-4411-9f28-a13df5443602	3939-114-4	penthouse	\N	288.99	\N	2343703.23
5cf04916-a2dd-454a-bb7a-99584f616e9f	48002e2d-0195-4c63-b2a2-80b2dee1b421	3935-112-1	apartment	\N	137.38	\N	573257.95
25bc4113-6a72-443d-99f0-c64b7bbe4265	064f4a79-c021-4bf8-8b21-2fbe598589a3	3929-111-1	apartment	\N	71.35	\N	494193.54
0d173584-4035-41d8-9764-4d37ba04196c	064f4a79-c021-4bf8-8b21-2fbe598589a3	3929-112-2	apartment	\N	134.99	\N	879617.54
1311c2d8-4744-4bdf-a00b-35fe1323dba7	064f4a79-c021-4bf8-8b21-2fbe598589a3	3929-113-3	apartment	\N	387.03	\N	1165217.54
11ab37b0-ae1d-448b-9d1a-12d480116749	40c463aa-29d4-4237-9890-2cddd6300ed7	3926-110-1	apartment	\N	52.34	\N	224128.00
8e273105-7752-44a3-963c-31ca4d3d5dc6	40c463aa-29d4-4237-9890-2cddd6300ed7	3926-164-2	penthouse	\N	115.54	\N	901757.25
edbcbcd7-da8c-4b42-95f4-0cf274ee6d2e	fdf62cbb-fc64-46fe-b2a9-fa60a5b36579	3920-164-1	penthouse	\N	109.81	\N	817573.52
1e878b93-e96e-4d21-b527-e1a09de2bebd	983fc43f-d73a-4978-b088-276926d5112a	3912-110-1	apartment	\N	31.40	\N	159120.00
9182819f-ca74-404d-b817-8fe26b5cbe4a	983fc43f-d73a-4978-b088-276926d5112a	3912-111-2	apartment	\N	60.47	\N	269008.00
c2d18ef4-21f8-4ef5-9776-c8d7001c0fb4	983fc43f-d73a-4978-b088-276926d5112a	3912-112-3	apartment	\N	103.22	\N	467568.00
211b45aa-15b5-4742-8d1a-c809c38332b0	983fc43f-d73a-4978-b088-276926d5112a	3912-113-4	apartment	\N	134.52	\N	552160.00
c69b242d-321a-4c42-8928-8af34d6087ca	cdd85e41-d12e-4084-8528-29f95b12914a	3910-112-1	apartment	\N	212.97	\N	1077392.00
443d4e75-5125-454d-9ad6-745020570572	cdd85e41-d12e-4084-8528-29f95b12914a	3910-113-2	apartment	\N	430.12	\N	1742432.00
59d21fe2-0b8b-469e-9219-c2412facf691	cdd85e41-d12e-4084-8528-29f95b12914a	3910-114-3	penthouse	\N	497.10	\N	2590800.00
93b42fca-e732-4ed9-b6e9-f049c6e30a9c	900ee819-9c79-48de-9838-014f48a07662	3877-111-1	apartment	\N	85.92	\N	243145.97
834cc9af-6f6c-4b5e-993f-5e1cee8b7b40	900ee819-9c79-48de-9838-014f48a07662	3877-112-2	apartment	\N	133.98	\N	367200.00
c5291573-f487-4a71-9f88-cec76e5ea6e2	f6edb1f8-a90f-4b37-abd2-9435aac5708f	3872-111-1	apartment	\N	145.29	\N	578514.08
e0d5e292-04a0-4b3c-bdd9-59cef2423876	f6edb1f8-a90f-4b37-abd2-9435aac5708f	3872-112-2	apartment	\N	226.63	\N	793302.69
d3e655a5-c32f-4c73-90c6-f674f5ffa878	f6edb1f8-a90f-4b37-abd2-9435aac5708f	3872-113-3	apartment	\N	334.32	\N	1270503.84
48dc28bb-f0ef-40bb-97f6-55931ddfe3f5	a5c69114-1acc-4a2f-83f4-f6d37b8bac03	3871-164-1	penthouse	\N	217.69	\N	601442.05
4acee442-8841-4b14-aadb-a67b12fec240	abe94af8-4c12-41e1-b94b-01fc6ab53cae	3855-111-1	apartment	\N	76.92	\N	401304.99
6ef8ef65-4235-490b-9584-58875b244f8c	abe94af8-4c12-41e1-b94b-01fc6ab53cae	3855-112-2	apartment	\N	95.69	\N	624919.46
3a3954ee-03fe-433d-843d-ec47e7f8340e	8aec2bc8-a6e9-4406-8868-30fc64f40ce2	3846-112-1	apartment	\N	141.49	\N	697105.54
64e106a0-44e2-4e7c-a5c4-c98a860865e4	8aec2bc8-a6e9-4406-8868-30fc64f40ce2	3846-113-2	apartment	\N	165.09	\N	890497.54
59d96afc-dc11-449c-ab83-36d9a470d99c	4e48f362-85d8-44d7-8496-4f1d19a55f4a	3843-113-1	apartment	\N	266.63	\N	744977.54
620259a7-d439-4f37-8b26-ee437b133894	1a796bf8-3707-4ff9-b04c-2cff72af66fa	3822-111-1	apartment	\N	86.31	\N	302464.00
c7afa1ee-90c5-49b2-a6d6-8418426e960d	1a796bf8-3707-4ff9-b04c-2cff72af66fa	3822-112-2	apartment	\N	125.23	\N	400656.00
11f51d7e-540f-482b-a7c7-c8bea901a141	1a796bf8-3707-4ff9-b04c-2cff72af66fa	3822-113-3	apartment	\N	253.16	\N	885265.89
04600f7c-01a8-47fd-abf2-b696140135a2	80c51df6-61f2-4c88-a34f-8002996ed35a	3818-111-1	apartment	\N	133.87	\N	295120.00
b0d347c2-fa03-4ff1-b25f-6d72910d2a0d	80c51df6-61f2-4c88-a34f-8002996ed35a	3818-112-2	apartment	\N	244.06	\N	428400.00
ead8d8fe-c9c9-48ab-9561-59c9f52e7aae	381e73fe-847c-4777-a8a4-b4251c199884	3814-111-1	apartment	\N	92.46	\N	309063.81
d1045fb7-d701-4860-a199-2cfb18a9ad4c	381e73fe-847c-4777-a8a4-b4251c199884	3814-112-2	apartment	\N	128.46	\N	454616.72
f7a2ff71-0c1f-4cb7-b70a-754799c2007b	30973a95-f62a-4af6-af10-a13bc24cb2cb	3778-112-1	apartment	\N	203.75	\N	761600.00
7a748f83-8f10-48f4-827e-d380e871f662	61eca2c9-bac5-4e92-a0cb-3a712db54a58	3773-112-1	apartment	\N	224.87	\N	1670080.00
cd62eaf4-97dc-4601-8e0d-5e438f4d5631	34e54881-e10c-4950-9d1b-e9d7a58e5938	3764-111-1	apartment	\N	105.63	\N	1020562.22
8a8c7de9-41eb-4f69-995c-e67561f150a3	34e54881-e10c-4950-9d1b-e9d7a58e5938	3764-112-2	apartment	\N	163.73	\N	1552289.04
3e1a5fe1-790d-4600-b984-7d07ada947db	34e54881-e10c-4950-9d1b-e9d7a58e5938	3764-113-3	apartment	\N	279.40	\N	2181831.14
814b3c3f-9f85-4813-b5ab-8b2c91943666	34e54881-e10c-4950-9d1b-e9d7a58e5938	3764-114-4	penthouse	\N	376.74	\N	4457062.18
abe67fcb-9f2b-4cbd-91b4-e33f701eedc1	34e54881-e10c-4950-9d1b-e9d7a58e5938	3764-115-5	penthouse	\N	383.19	\N	5497293.54
7624861d-910e-4199-bd2e-d21479d30ae6	ec4a035e-0ef6-4a8f-9a2b-f93f1fc48834	3760-114-1	penthouse	\N	278.70	\N	2244000.00
bd1d9f8f-e3e4-4134-9193-ce24f398e10b	ec4a035e-0ef6-4a8f-9a2b-f93f1fc48834	3760-115-2	penthouse	\N	559.08	\N	4883760.00
41d363ed-977b-4462-9849-c488304e9c0b	ea1e050e-c6a3-4589-9119-1451acb8760d	3744-113-1	apartment	\N	167.81	\N	1049920.00
fa618da4-99ff-4f3b-8376-1b80ccf68760	507313ff-10ae-468d-8407-bdb7e089c344	3732-164-1	penthouse	\N	330.89	\N	620736.91
9761d593-3168-4383-a98e-9d6d380b4893	3310faac-d50e-43d5-85b4-b8119c4c5ca5	3712-111-1	apartment	\N	89.89	\N	550269.33
00923dcd-18dc-4a7c-b4a8-9dc220d9256a	3310faac-d50e-43d5-85b4-b8119c4c5ca5	3712-112-2	apartment	\N	159.04	\N	894487.50
fffbc73a-870c-48c8-9003-685c6653a543	3310faac-d50e-43d5-85b4-b8119c4c5ca5	3712-113-3	apartment	\N	138.41	\N	1053614.85
ff05bab8-7449-42f6-b2cb-9710ead1f391	ce07b5f3-e1b8-44d8-b6e9-07d09081adec	3702-110-1	apartment	\N	44.87	\N	326641.54
fb8bf091-d59f-408b-b14e-e2cb316048c0	ce07b5f3-e1b8-44d8-b6e9-07d09081adec	3702-111-2	apartment	\N	129.79	\N	503441.54
3a216bc9-958e-4523-95e7-ac4b78224ea9	ce07b5f3-e1b8-44d8-b6e9-07d09081adec	3702-112-3	apartment	\N	136.10	\N	780881.54
98b73130-5f3c-42e4-bb10-c5639f772194	1fdab001-bf5c-4708-bd10-80aa83f812ce	3699-110-1	apartment	\N	40.88	\N	222496.00
3fba4b52-c1d1-4f71-bc30-1b03415187df	1fdab001-bf5c-4708-bd10-80aa83f812ce	3699-111-2	apartment	\N	82.83	\N	365024.00
c68a0218-8a0b-4070-b01e-c1b8fa2bba53	1fdab001-bf5c-4708-bd10-80aa83f812ce	3699-112-3	apartment	\N	159.47	\N	540464.00
4076677f-06be-4add-af7d-e0294812f45b	1fdab001-bf5c-4708-bd10-80aa83f812ce	3699-164-4	penthouse	\N	145.57	\N	826880.00
3a366ea5-ea8e-4607-88d9-d01b93e957d2	6999da94-9a4b-4ed2-9453-df275074b9e6	3685-110-1	apartment	\N	32.29	\N	189251.34
c7d8c0af-ca19-4e83-90fe-89c212bf567d	6999da94-9a4b-4ed2-9453-df275074b9e6	3685-111-2	apartment	\N	107.54	\N	258883.34
9be7b909-ab49-4f6b-bedb-dc9daf533698	6999da94-9a4b-4ed2-9453-df275074b9e6	3685-112-3	apartment	\N	103.90	\N	431603.34
af22f4f4-e0d5-4724-8f20-013747d63eb3	e182f799-1dfc-4a88-96da-d8c55aa3b4a7	3680-110-1	apartment	\N	67.70	\N	247356.80
0e1e89df-a728-46ba-b0af-8513c1581a49	e182f799-1dfc-4a88-96da-d8c55aa3b4a7	3680-111-2	apartment	\N	97.46	\N	460224.00
e09f21b7-57ed-4a3a-b4d4-e565afe530d8	e182f799-1dfc-4a88-96da-d8c55aa3b4a7	3680-112-3	apartment	\N	184.99	\N	904740.00
5cc993e3-cd37-4967-a7a2-56b768f3836f	8a5eaaa1-ca01-4418-a250-de97afa18a62	3639-111-1	apartment	\N	67.71	\N	320144.00
18e56740-b478-4cfb-82c5-ee840c98d7d4	8a5eaaa1-ca01-4418-a250-de97afa18a62	3639-112-2	apartment	\N	130.05	\N	386784.00
19f545d3-4d6e-4eb7-9a13-35f7c4805430	8a5eaaa1-ca01-4418-a250-de97afa18a62	3639-113-3	apartment	\N	169.35	\N	608192.00
10448c92-ca50-4bad-a931-9ef8da4f9e0b	1f2577b1-0439-46d0-b04b-bc353bff0d94	3635-111-1	apartment	\N	113.30	\N	349801.25
12df7981-c878-4e42-a9e8-88c38b6788ae	1f2577b1-0439-46d0-b04b-bc353bff0d94	3635-112-2	apartment	\N	190.00	\N	935429.76
1899aeed-a984-466b-8f97-20257ea8f6bd	1f2577b1-0439-46d0-b04b-bc353bff0d94	3635-113-3	apartment	\N	221.14	\N	809677.09
387ff765-abdb-4a5a-9e00-b96231f33b00	334d7f12-b882-4d28-a1be-bb765bf72a19	3628-110-1	apartment	\N	45.36	\N	176854.13
bd38a41b-ef98-4329-98a6-81ccc9b02b5c	334d7f12-b882-4d28-a1be-bb765bf72a19	3628-111-2	apartment	\N	69.68	\N	245192.50
e1990d05-7d52-4644-8999-a0e89f798ed1	8173765f-6e52-41ca-a79c-cabdc4e598c1	3621-112-1	apartment	\N	133.13	\N	507320.80
ef08e7ad-88ea-4a37-928b-aacd519b8bc5	8173765f-6e52-41ca-a79c-cabdc4e598c1	3621-164-2	penthouse	\N	1276.00	\N	557797.47
51de90de-7f98-4d3b-9af0-0a58db0d289d	54e6c982-1f66-4a91-a92f-938af38c2da8	3598-111-1	apartment	\N	133.04	\N	464305.63
aca53e6a-421b-4d8f-ba3f-0b339fa58f49	54e6c982-1f66-4a91-a92f-938af38c2da8	3598-112-2	apartment	\N	157.66	\N	644502.10
9e00bbb4-7006-4c0a-ac00-2353bd18e142	54e6c982-1f66-4a91-a92f-938af38c2da8	3598-113-3	apartment	\N	307.14	\N	1004323.82
f4b48600-1f33-4d41-ae72-11d1a587bf6a	c74e71b9-bcd9-4f7c-9ff0-180592d3c63f	3595-111-1	apartment	\N	78.50	\N	502897.54
6253fde9-5629-4ed2-a752-1b2d5e72c293	c74e71b9-bcd9-4f7c-9ff0-180592d3c63f	3595-112-2	apartment	\N	123.28	\N	801825.54
b7be37c0-4e76-4522-90eb-44b77eb82cc1	c74e71b9-bcd9-4f7c-9ff0-180592d3c63f	3595-113-3	apartment	\N	147.07	\N	1108097.54
2db33662-9cf0-4be5-a9ee-14c22e3b5aa3	73a78611-8a90-4b45-b776-a5f5c945dcfb	3593-111-1	apartment	\N	102.00	\N	400384.00
208f5167-8086-49ef-8ba2-e2fe05d7da0f	73a78611-8a90-4b45-b776-a5f5c945dcfb	3593-112-2	apartment	\N	137.57	\N	503200.00
db52bed0-dc61-4976-bb35-4b9a571d2fdb	73a78611-8a90-4b45-b776-a5f5c945dcfb	3593-113-3	apartment	\N	186.08	\N	1104456.00
72561884-efd3-4dd8-847f-950e2f33e05e	bfc1f048-193c-4276-b13b-5bf2417d3c87	3589-110-1	apartment	\N	76.55	\N	277919.54
cb3641e0-4744-4303-8f15-45c1aecc187d	bfc1f048-193c-4276-b13b-5bf2417d3c87	3589-111-2	apartment	\N	87.51	\N	400701.70
77c887d2-4d2d-46dd-8974-3e2ea536138e	bfc1f048-193c-4276-b13b-5bf2417d3c87	3589-112-3	apartment	\N	445.84	\N	617741.38
ddf5757f-b472-4d68-9e6e-69f1b2bebb7d	048944a7-39ff-4941-8e93-407776dcf57f	3588-110-1	apartment	\N	56.15	\N	312800.00
5ac7e184-269e-413f-b00d-0e55ee4bf686	048944a7-39ff-4941-8e93-407776dcf57f	3588-111-2	apartment	\N	92.48	\N	510544.00
cfceebf4-ed05-41ea-9502-cc4b17e8557a	b3466946-e73b-4ebd-9691-4c2726bcb601	3580-110-1	apartment	\N	38.63	\N	210799.73
4ec7d6a9-0290-4571-a866-210610f7b72b	55751976-5436-4c1b-86e2-cae717f9b446	3570-112-1	apartment	\N	253.13	\N	969869.86
5d624579-5765-4b41-ac40-e329a198955d	221bb8da-a213-410a-b93c-858aecab3220	3550-112-1	apartment	\N	79.31	\N	417248.00
f1c62b4d-4e61-4ed3-b031-6d17b37dd97d	221bb8da-a213-410a-b93c-858aecab3220	3550-113-2	apartment	\N	131.75	\N	625600.00
f6061141-525b-4191-b18c-79943c3bdcd2	221bb8da-a213-410a-b93c-858aecab3220	3550-164-3	penthouse	\N	294.42	\N	1066784.00
9b862f19-fe85-45bd-b697-54ead1b3df73	dfcca45a-d129-4112-ad11-0a459cc5957f	3549-111-1	apartment	\N	80.18	\N	497175.20
a2eb4a32-6f1f-477e-af25-6fd1d474feef	dfcca45a-d129-4112-ad11-0a459cc5957f	3549-112-2	apartment	\N	137.96	\N	843417.60
15c5a7b5-93e9-42e9-ae48-472dc150b0e5	1e957770-7cba-4ead-a88c-ae3a35e9a8a8	3545-111-1	apartment	\N	112.07	\N	421328.00
53779d19-fab1-49a5-950e-702ec8ca3d6c	1e957770-7cba-4ead-a88c-ae3a35e9a8a8	3545-112-2	apartment	\N	103.24	\N	936632.00
461f33b9-4147-4209-93b0-0c47c6db02fc	1e957770-7cba-4ead-a88c-ae3a35e9a8a8	3545-113-3	apartment	\N	185.16	\N	1337016.00
d215d21f-0c2d-4232-a25b-82c541d1d6a2	11b48ecf-2b5e-4bb2-a6aa-605444f3461e	3536-112-1	apartment	\N	119.10	\N	490416.00
644de552-8d52-45db-b335-e93ac112658d	e7003c28-36ae-4881-ae5c-a05e6585152e	3535-111-1	apartment	\N	83.15	\N	504832.00
2a889cb6-bbd5-4b7b-a6c4-993682ea0868	e7003c28-36ae-4881-ae5c-a05e6585152e	3535-114-2	penthouse	\N	574.98	\N	7860800.00
28cb102f-6583-4367-a256-bec4ba132591	82a0ddb9-ed8f-4fb2-a6b3-59cb7cba4a7f	3513-110-1	apartment	\N	39.48	\N	236952.80
b9ed261c-ef90-4099-8702-a66ef3c7c833	82a0ddb9-ed8f-4fb2-a6b3-59cb7cba4a7f	3513-111-2	apartment	\N	74.60	\N	409267.52
c6f1d796-dd3d-483b-924b-8f4a6d5cc9e6	82a0ddb9-ed8f-4fb2-a6b3-59cb7cba4a7f	3513-112-3	apartment	\N	117.91	\N	600673.92
dc233141-a4d5-493a-8838-54365497848d	788098a1-1478-4655-a11d-8a5a6852b901	3496-111-1	apartment	\N	70.05	\N	498310.80
51dacee4-c00e-43e0-beb9-055405fad6ad	788098a1-1478-4655-a11d-8a5a6852b901	3496-112-2	apartment	\N	140.86	\N	647332.80
1859529a-6791-4213-ac52-dab357be50b1	788098a1-1478-4655-a11d-8a5a6852b901	3496-113-3	apartment	\N	181.93	\N	1287132.02
4becd074-7334-4bd0-a899-53458500f97f	788098a1-1478-4655-a11d-8a5a6852b901	3496-114-4	penthouse	\N	376.03	\N	2266431.57
45e75532-00b0-447e-a297-f562da7b50af	bd7a4f39-e393-4690-8aa8-e6862bafa30f	3494-112-1	apartment	\N	137.20	\N	938368.45
f8fdb04e-7157-4b91-909a-d8ae8db59872	bd7a4f39-e393-4690-8aa8-e6862bafa30f	3494-113-2	apartment	\N	165.93	\N	952579.09
f9cd5876-03d3-412d-b07d-881ab982934d	bd7a4f39-e393-4690-8aa8-e6862bafa30f	3494-114-3	penthouse	\N	177.28	\N	1205630.75
521ac756-d2f9-4ea6-a7b7-ed4ab478dbf9	8042dd14-287c-4e09-962d-8df8b6f214a4	3489-110-1	apartment	\N	38.28	\N	202639.73
b2f78484-765d-4b29-ab4a-63cde35a433f	8042dd14-287c-4e09-962d-8df8b6f214a4	3489-111-2	apartment	\N	76.47	\N	318239.73
070e3935-c040-4004-938a-bb8b1339a38a	8042dd14-287c-4e09-962d-8df8b6f214a4	3489-112-3	apartment	\N	152.96	\N	432479.73
da6281de-0245-4c50-99c7-41e699d34778	85956e9b-6aaf-469b-9c9d-72439a808413	3482-112-1	apartment	\N	115.58	\N	707200.00
04f1cae2-4f2b-4339-8d81-623b5ebdd196	85956e9b-6aaf-469b-9c9d-72439a808413	3482-113-2	apartment	\N	410.60	\N	1043664.00
d414351d-1856-4b28-9539-bbe26d0794c7	e556130a-99d1-4241-8075-d320b9316698	3457-112-1	apartment	\N	219.73	\N	458320.00
4256ce4e-a357-446f-abb0-9abd77bca081	e556130a-99d1-4241-8075-d320b9316698	3457-113-2	apartment	\N	441.98	\N	857480.00
ef17dfc4-c0be-46d6-b20f-85d6fb1cd3ba	281e80fa-b343-4029-8780-08ac9628da64	3456-113-1	apartment	\N	195.87	\N	1308600.98
42bb07e3-c4b3-4c0d-a4b9-921462bf6477	9d015acb-f982-4c84-87ce-27b9e9d45404	3417-111-1	apartment	\N	95.22	\N	400656.00
ddecc65e-3799-4989-904f-54ed682fc5ae	9d015acb-f982-4c84-87ce-27b9e9d45404	3417-112-2	apartment	\N	131.91	\N	583984.00
147b0f78-f05e-494a-bab5-9b88d64fc2c8	c3bfbc9c-b5e0-4bbd-976e-93e571fdb810	3416-111-1	apartment	\N	97.47	\N	241536.00
1e06b808-8b7e-4019-b53a-d94db7e23e16	c3bfbc9c-b5e0-4bbd-976e-93e571fdb810	3416-112-2	apartment	\N	132.12	\N	357680.00
14d801bd-ecca-4d4e-83d0-3fe10685d6ac	61bb6769-2606-429c-9b90-be3edb94c180	3406-111-1	apartment	\N	108.99	\N	263296.00
72113b62-d893-4acb-9375-691bc16f8e50	178e5b66-b22f-4198-8d7c-6af7a6f4fbdb	3370-164-1	penthouse	\N	289.39	\N	1483760.00
57ffbc7b-e810-473f-b7f8-cb22df886a08	772d97f2-d2ca-4c3b-8eb5-7d7032437789	3361-111-1	apartment	\N	63.92	\N	366928.00
376d4495-b138-47bb-8a34-4f6370214bd8	75348471-7d62-4977-acde-1286a192647d	3360-114-1	penthouse	\N	426.33	\N	4471952.00
5581370f-883d-4930-8e3e-d2589b4b14eb	9d52eda3-4003-4111-93b8-c3ad4b448493	3328-111-1	apartment	\N	73.52	\N	276020.16
368870ef-0a70-4acd-b818-ba0cb56690af	9d52eda3-4003-4111-93b8-c3ad4b448493	3328-112-2	apartment	\N	100.70	\N	341750.86
a103f901-d4be-4a3a-b1d9-47311d3a17c5	9d52eda3-4003-4111-93b8-c3ad4b448493	3328-113-3	apartment	\N	164.26	\N	601147.20
4bce6529-fd8d-4ac1-97f4-7c531b8f8308	45f5d4f5-4acf-4c00-babb-b73afed2f777	3315-111-1	apartment	\N	81.48	\N	390390.18
0baa5dff-207f-42a4-b5d8-be3742dc35fa	45f5d4f5-4acf-4c00-babb-b73afed2f777	3315-112-2	apartment	\N	123.75	\N	524078.99
b11cd536-aedb-4065-af58-916f847d1e87	45f5d4f5-4acf-4c00-babb-b73afed2f777	3315-113-3	apartment	\N	151.62	\N	842622.00
f7f7e6cf-9012-4506-9ff9-fac06497b061	8cf3866d-9f3c-48c8-9800-5316bdaaa0eb	3278-111-1	apartment	\N	117.29	\N	304728.40
c7ef4179-9047-4512-822d-c9c1e984251d	1db5df0d-e844-4698-b035-fca83022406e	3250-110-1	apartment	\N	24.90	\N	139231.36
b5f1a1bf-4bcf-476a-9c30-7ddf43fdc7ba	1db5df0d-e844-4698-b035-fca83022406e	3250-111-2	apartment	\N	132.15	\N	193755.66
e0e796ca-4710-4e43-b1ea-17633706ef82	1db5df0d-e844-4698-b035-fca83022406e	3250-112-3	apartment	\N	199.74	\N	303405.12
2449e554-e506-49db-a061-49a2d11a57dc	3c0f7602-52b5-49fb-a3d5-5c409676f2e3	3245-111-1	apartment	\N	83.61	\N	455600.00
9312024e-7182-4e2f-ab7a-9ff42e4b06d6	3c0f7602-52b5-49fb-a3d5-5c409676f2e3	3245-112-2	apartment	\N	115.01	\N	750992.00
4620c83e-b95d-40b2-aafb-49d5ec66c662	3c0f7602-52b5-49fb-a3d5-5c409676f2e3	3245-113-3	apartment	\N	130.90	\N	1024624.00
6979886d-12b5-44ab-b830-0d00f4b762bc	3c0f7602-52b5-49fb-a3d5-5c409676f2e3	3245-114-4	penthouse	\N	543.20	\N	1870000.00
0d7d2b8f-6244-4978-b201-2a175bbce3e3	e1bd44b6-88d5-4878-bc38-ee74df1bbae8	3243-112-1	apartment	\N	148.64	\N	550209.22
3ca50821-1bc8-40f3-a185-e612a204bc86	e1bd44b6-88d5-4878-bc38-ee74df1bbae8	3243-113-2	apartment	\N	227.32	\N	740881.22
ce6b996c-1163-475b-b362-61aecec8a48e	4287006c-bf4c-4948-9e4e-7b237fc3cdae	3204-112-1	apartment	\N	101.77	\N	295405.60
b5390ea7-311e-4a56-87bd-f57a02d0e9d9	1e377013-8d0e-4e7a-95a9-7833e8fbb89b	3199-111-1	apartment	\N	113.37	\N	386919.73
bbf1da2e-f104-4099-9d1c-e82ddb7c7154	1e377013-8d0e-4e7a-95a9-7833e8fbb89b	3199-112-2	apartment	\N	123.98	\N	484645.52
08c9f163-0079-49ea-b868-4dfd35bfa49d	1e377013-8d0e-4e7a-95a9-7833e8fbb89b	3199-113-3	apartment	\N	181.24	\N	679266.96
c8ab8233-cfe0-4375-872c-65ac68427d57	adb9c8de-fb2e-41b8-b7e6-77275589659f	3197-110-1	apartment	\N	35.50	\N	156400.00
4f7dd049-f5a4-460b-a42e-e6a02d41c020	adb9c8de-fb2e-41b8-b7e6-77275589659f	3197-111-2	apartment	\N	74.14	\N	281792.00
4a3eb235-b0eb-4a47-b4a8-739befab554c	adb9c8de-fb2e-41b8-b7e6-77275589659f	3197-112-3	apartment	\N	192.44	\N	306566.58
4c4f87d7-fd54-412a-bbfc-dd6448215065	c7578cda-93b1-4f3d-9f11-51f64c948f05	3172-111-1	apartment	\N	123.22	\N	941120.00
338c3a4c-501a-474a-9d4c-907910e34e8e	c7578cda-93b1-4f3d-9f11-51f64c948f05	3172-112-2	apartment	\N	152.81	\N	1145120.00
9a7f2aa5-f63c-4005-918c-be1c9db2a900	c7578cda-93b1-4f3d-9f11-51f64c948f05	3172-113-3	apartment	\N	315.94	\N	2747200.00
2c41d49d-13cf-48ac-a7fd-322db0a58e48	62138abf-5997-4a8b-8743-cd84369fbabe	3152-113-1	apartment	\N	132.67	\N	654401.54
4bfafeee-84aa-4762-90bd-e660eb603546	35611488-4728-4f79-9ff4-ac1fc046b7f3	3146-112-1	apartment	\N	330.36	\N	2784732.19
fe11e9f1-2ca1-4ae1-9b2d-ba8aebb30f5a	35611488-4728-4f79-9ff4-ac1fc046b7f3	3146-113-2	apartment	\N	528.90	\N	3932414.43
3883edc2-e1db-439c-a68c-a8c2d01bbb63	35611488-4728-4f79-9ff4-ac1fc046b7f3	3146-114-3	penthouse	\N	687.95	\N	6528000.00
77960093-521f-4ccc-a874-ec4a34fa2d75	35611488-4728-4f79-9ff4-ac1fc046b7f3	3146-115-4	penthouse	\N	1478.83	\N	20717166.96
ed12c899-a2db-4cf1-99eb-60b7531345c3	35611488-4728-4f79-9ff4-ac1fc046b7f3	3146-343-5	office	\N	3088.66	\N	57716862.93
31f5ba11-f326-4eee-b2d0-fd84a05b0f33	ced2589d-1cd7-4db2-a624-26cc954e65b2	3137-111-1	apartment	\N	69.87	\N	843200.00
d2b59ece-0a33-49ab-bc9c-dfb3b752687d	ced2589d-1cd7-4db2-a624-26cc954e65b2	3137-112-2	apartment	\N	173.42	\N	960160.00
92ed4de2-725b-4f83-baee-bd7fcf36b53d	ead33866-f603-4660-9040-e55585db947d	3135-112-1	apartment	\N	123.00	\N	817310.50
46a46cec-dfda-4da5-b1ec-4211325a9590	ead33866-f603-4660-9040-e55585db947d	3135-113-2	apartment	\N	199.56	\N	1368750.24
2fdf7a7d-85da-46a3-87e0-b4586e4c8c14	236ff69c-1a6b-4a26-95c5-a70ba2f36152	3128-110-1	apartment	\N	35.77	\N	179519.73
560b48cf-33f7-4184-8c48-597cdd21c6d3	236ff69c-1a6b-4a26-95c5-a70ba2f36152	3128-112-2	apartment	\N	134.43	\N	554826.96
6108df47-bf07-4881-b14e-25f9e65e3213	52f75735-6023-4d30-ade4-81e9034f8e02	3127-110-1	apartment	\N	39.68	\N	197200.00
da63d15a-fb7f-4caf-bb4e-a86f946b21db	52f75735-6023-4d30-ade4-81e9034f8e02	3127-111-2	apartment	\N	63.80	\N	284240.00
8b1f2c6b-4232-4dbc-b61f-ace2bf387a5e	a4968c56-163f-44c8-8c1b-80998093c7a5	3122-112-1	apartment	\N	126.07	\N	452059.92
22d5552c-48d9-4c2b-8e51-46566cabf5ec	933a7063-07a4-419a-b58e-22869832424b	3121-111-1	apartment	\N	129.61	\N	370161.54
cc9d57c3-95a5-4780-be83-70dbfb805774	933a7063-07a4-419a-b58e-22869832424b	3121-112-2	apartment	\N	196.09	\N	549409.54
f2708a16-0008-460f-b67a-d4f9142f4be7	eeba8151-f3a6-453e-b012-9c01b2790d28	3119-111-1	apartment	\N	104.52	\N	308756.45
59e84fd9-7945-40ea-80cd-2d1ca100b333	eeba8151-f3a6-453e-b012-9c01b2790d28	3119-112-2	apartment	\N	194.54	\N	446802.43
a8fa6deb-c1b6-4328-9c06-e996213b140c	73f17b2a-c542-4e9b-862a-be0cf859a869	3113-112-1	apartment	\N	92.25	\N	544231.20
23f0d34f-f546-4c63-90e8-e1c0988e4301	c724f2fa-1743-4c71-aaab-af741282a045	3107-111-1	apartment	\N	96.17	\N	620704.00
46b5cf2f-7009-4d61-a326-0c9927c5d59e	c724f2fa-1743-4c71-aaab-af741282a045	3107-112-2	apartment	\N	139.30	\N	908208.00
e8be4c1c-3a02-4bab-b424-9a020342e469	c724f2fa-1743-4c71-aaab-af741282a045	3107-113-3	apartment	\N	204.31	\N	1463088.00
42b7f7b8-fa04-40c7-8f17-4b09e3c12425	d0785132-0520-427f-b051-579415dc5d59	3100-110-1	apartment	\N	35.76	\N	167517.18
f4e4c7a2-117c-406a-9520-6ce561a126d4	d0785132-0520-427f-b051-579415dc5d59	3100-111-2	apartment	\N	98.27	\N	460341.50
b23d61c5-6728-4443-9c7d-234c877c9d7c	d0785132-0520-427f-b051-579415dc5d59	3100-112-3	apartment	\N	107.10	\N	501702.91
c1b1d311-f8c9-4ae7-b021-4d2cdaf77c76	43314b73-fe50-4bbb-8278-478e0a2740c4	3091-112-1	apartment	\N	180.32	\N	796144.00
ab8e3d62-9849-4e97-93d6-7e8b374c1eee	43314b73-fe50-4bbb-8278-478e0a2740c4	3091-113-2	apartment	\N	188.22	\N	860880.00
acbe56be-dec9-4bd9-9be7-c80250343f1e	d545d047-3042-4cca-9db7-c8d1fb537fdc	3082-112-1	apartment	\N	129.97	\N	713153.54
253ddc28-923a-45fd-9888-676de3bfc232	d545d047-3042-4cca-9db7-c8d1fb537fdc	3082-113-2	apartment	\N	237.74	\N	1235937.54
d0a7ca86-e550-4e7e-8058-33918a23c6de	5539c2b5-3657-47e8-9221-b8b269d60eed	3081-164-1	penthouse	\N	270.95	\N	2244544.00
0a043a62-00be-4796-b740-ad9c3abcad86	56fc6f31-a296-4d4d-9b37-5083a8c81cbb	3078-113-1	apartment	\N	238.20	\N	1248177.54
019bc5f4-8699-4c2b-b261-9f093d8a9eb8	c625309e-e336-4ba9-9c48-04c172a30b0b	3077-111-1	apartment	\N	74.60	\N	314826.94
c5b55aec-9a4e-4085-97a4-dde2aa96b45f	c625309e-e336-4ba9-9c48-04c172a30b0b	3077-112-2	apartment	\N	127.00	\N	487591.55
028c4512-949d-4fa6-b763-3c2083009a42	ebd2b1d7-fa2a-4e20-9a0c-fe07227dbe09	3076-111-1	apartment	\N	89.49	\N	378929.18
86ca288d-9e80-4002-8c41-5fa1b9e496c5	82a2b9d4-8a54-4216-8f88-5c5e1d80a6bd	3068-110-1	apartment	\N	49.70	\N	195840.00
d2b3708f-c10b-444f-a21a-2cd748c29dd4	82a2b9d4-8a54-4216-8f88-5c5e1d80a6bd	3068-112-2	apartment	\N	138.21	\N	381888.00
9d59c5d4-e95f-449a-a001-3a8987efdd5c	82a2b9d4-8a54-4216-8f88-5c5e1d80a6bd	3068-164-3	penthouse	\N	383.20	\N	3253664.00
5b074a6c-2cdd-4637-b504-65eda2c7d264	e749eab4-4eb8-4dd6-bfc6-a0dd7b4abd31	3063-110-1	apartment	\N	48.97	\N	206719.73
2a28175e-92c6-4ad1-81ef-28ebf156be40	e749eab4-4eb8-4dd6-bfc6-a0dd7b4abd31	3063-111-2	apartment	\N	97.43	\N	342719.73
5ffff393-9b19-4166-98a5-3b143f769dfc	e749eab4-4eb8-4dd6-bfc6-a0dd7b4abd31	3063-112-3	apartment	\N	125.36	\N	462399.73
4f6c768d-79cd-423f-a674-ebb25cad622f	e749eab4-4eb8-4dd6-bfc6-a0dd7b4abd31	3063-113-4	apartment	\N	148.75	\N	688159.73
c075c33a-fac1-4ac0-b741-eaefeeef916c	0c09c0ae-58c6-47f0-8846-6eaec0c13de6	3062-112-1	apartment	\N	158.71	\N	1305600.00
e5e9a2da-f794-44a9-94cb-c533f85d5e66	0c09c0ae-58c6-47f0-8846-6eaec0c13de6	3062-113-2	apartment	\N	260.04	\N	1414400.00
f9947dbe-3b88-4843-9027-64263be15403	0c09c0ae-58c6-47f0-8846-6eaec0c13de6	3062-114-3	penthouse	\N	391.51	\N	1985600.00
9b68f038-6933-49be-828b-7e88f9cf2fbc	0c09c0ae-58c6-47f0-8846-6eaec0c13de6	3062-115-4	penthouse	\N	671.53	\N	7616000.00
9a991f82-d8c3-49cd-8c56-1503171a7bff	8c24b230-9157-4ab5-9fb7-988723e345f4	3055-110-1	apartment	\N	38.41	\N	200854.86
3a4ecf83-8a85-4086-84f0-aeadbdca814d	8c24b230-9157-4ab5-9fb7-988723e345f4	3055-111-2	apartment	\N	76.45	\N	316310.16
766a9cf5-d027-483b-bd70-73a72e9e3029	8c24b230-9157-4ab5-9fb7-988723e345f4	3055-112-3	apartment	\N	160.79	\N	508639.73
1e2e57cb-f246-4f72-afaa-bdb17f6861ae	8c24b230-9157-4ab5-9fb7-988723e345f4	3055-113-4	apartment	\N	182.06	\N	794749.73
933d6ceb-132f-4048-a5af-5794bfeb04db	ef4d94c8-9b22-4881-aea8-2027bb5e73c7	3049-110-1	apartment	\N	45.15	\N	204000.00
7fb4ed31-39b4-43af-95e3-7e485090c3cc	ef4d94c8-9b22-4881-aea8-2027bb5e73c7	3049-111-2	apartment	\N	69.31	\N	341640.43
d69a4450-4ec2-4c65-95ae-f8442e1b592e	ef4d94c8-9b22-4881-aea8-2027bb5e73c7	3049-112-3	apartment	\N	100.06	\N	451089.15
b460e1f8-fec3-4e63-9139-5a9c8279ee61	ece8f73d-a0f6-4a09-8da8-b2f9f60e9034	3046-111-1	apartment	\N	85.17	\N	356711.41
2262fdc5-b630-41e5-ade3-e999b81bd33e	ece8f73d-a0f6-4a09-8da8-b2f9f60e9034	3046-112-2	apartment	\N	174.24	\N	705578.06
0a2536ce-1ed0-4e00-ae79-9bde91524981	ece8f73d-a0f6-4a09-8da8-b2f9f60e9034	3046-113-3	apartment	\N	244.89	\N	788505.97
ef6d5184-9ffc-4c01-8f85-9eb3253faa9d	ece8f73d-a0f6-4a09-8da8-b2f9f60e9034	3046-114-4	penthouse	\N	343.23	\N	1279271.49
1dd7d3e2-fb94-41de-87a4-f281e301b78c	f07cd7a4-cb78-402c-a577-2d5dd8c1bff0	3045-111-1	apartment	\N	101.21	\N	330026.03
54730c4a-9e0f-4a1f-b8b3-01847485573c	f07cd7a4-cb78-402c-a577-2d5dd8c1bff0	3045-112-2	apartment	\N	112.46	\N	419599.17
5c13b039-982a-4adf-9274-809e9a6f2dc1	8b0ce778-fc7a-418a-8ef0-71b8ea99faf3	3038-164-1	penthouse	\N	184.79	\N	1109729.54
25c6b00e-02cf-42da-8b21-baf60ce8f95a	03c23f4d-ea0b-490f-b35e-eee69bf5eb7d	3034-111-1	apartment	\N	101.73	\N	1126352.00
9f87f30c-cd89-44fd-b62b-60b10d85fefa	b2fabe77-ffff-415d-8e8d-c52659fb7434	3032-111-1	apartment	\N	122.26	\N	312739.34
fa0a1dee-ec65-4b74-9f2a-eb5ae439bcb6	b2fabe77-ffff-415d-8e8d-c52659fb7434	3032-112-2	apartment	\N	129.41	\N	517283.34
0d416dab-a33d-4b3c-bedf-6eb060758e3f	b2fabe77-ffff-415d-8e8d-c52659fb7434	3032-113-3	apartment	\N	244.34	\N	858643.34
efa227a9-deba-4651-a7a6-ac0bdc39af22	52ef8346-a627-4662-9ccd-1d664cd97c53	3027-110-1	apartment	\N	32.55	\N	216008.26
50ce1a89-2830-4f3f-a680-c83fedce6a1f	52ef8346-a627-4662-9ccd-1d664cd97c53	3027-111-2	apartment	\N	69.94	\N	320403.22
3993c46d-c4e8-4ba3-be34-f1a61a498a9e	52ef8346-a627-4662-9ccd-1d664cd97c53	3027-112-3	apartment	\N	99.88	\N	464922.53
c3db5f31-01a2-4420-b842-da2ca1abf0a6	f01e84ff-9548-40d4-a0d8-492d6c2a60e0	3023-111-1	apartment	\N	109.46	\N	589751.49
1e5a8016-752e-4e4b-8c71-e35844af8379	f01e84ff-9548-40d4-a0d8-492d6c2a60e0	3023-112-2	apartment	\N	117.32	\N	646852.72
be7b094d-3d8c-4251-b3a9-7d12d0022e10	f01e84ff-9548-40d4-a0d8-492d6c2a60e0	3023-113-3	apartment	\N	142.25	\N	777608.29
52721b36-dc41-4f65-9b2d-ede7ec927bcc	500111d6-103d-435e-b572-129dbbbb3844	3017-111-1	apartment	\N	106.28	\N	303008.00
0333bd34-05f6-4054-bc6b-981838672ff9	500111d6-103d-435e-b572-129dbbbb3844	3017-112-2	apartment	\N	103.03	\N	449072.00
52e9edd1-f694-47d7-8dba-dba169f5a183	500111d6-103d-435e-b572-129dbbbb3844	3017-113-3	apartment	\N	188.78	\N	590784.00
ea519eb5-e7c7-4a83-a454-f84374028fc5	500111d6-103d-435e-b572-129dbbbb3844	3017-164-4	penthouse	\N	331.66	\N	2199120.00
0be5ee45-1c8e-41c9-aed2-155ca616eeb2	4ad968c2-c43b-4b23-b293-41a3f8c6917d	3007-112-1	apartment	\N	174.56	\N	1400677.06
a181defd-3d40-4e08-b00a-95999c1b43d6	4ad968c2-c43b-4b23-b293-41a3f8c6917d	3007-113-2	apartment	\N	256.50	\N	2067077.06
936d94ba-1e63-4dbe-984d-b9ac7df7abfc	3c355308-0752-42f0-821a-76fa8783a84f	3005-110-1	apartment	\N	60.75	\N	413246.06
ab89cb23-d958-4190-aabb-229d790953e5	3c355308-0752-42f0-821a-76fa8783a84f	3005-111-2	apartment	\N	86.87	\N	587692.45
dc706cbf-cbdc-4ab1-a0ce-eb9f660c437a	3c355308-0752-42f0-821a-76fa8783a84f	3005-112-3	apartment	\N	157.45	\N	912633.98
0ab71a19-ae48-4e54-adf2-e1f71c699a27	99208f66-bded-4d27-9b3d-e3a2eb53b13f	3001-111-1	apartment	\N	87.73	\N	654973.55
6b1be68d-ffb9-4a4f-8c57-5eb27197a0d5	99208f66-bded-4d27-9b3d-e3a2eb53b13f	3001-112-2	apartment	\N	112.23	\N	846104.14
b0773dee-0941-48ea-b42a-acc05cca890c	99208f66-bded-4d27-9b3d-e3a2eb53b13f	3001-113-3	apartment	\N	212.65	\N	1553366.16
ed1d1c07-1473-4236-a9b8-c01beaa060af	54584c47-35ea-439e-bf51-580f9759476f	2989-110-1	apartment	\N	45.34	\N	236473.81
5aff6e45-8308-47a3-99ec-bacdb36b7211	54584c47-35ea-439e-bf51-580f9759476f	2989-111-2	apartment	\N	143.10	\N	378756.74
c9e988d3-db40-4221-89c1-2df459e68893	7f5f7470-be7f-4bf6-ab7c-13e3e17c3669	2987-111-1	apartment	\N	74.51	\N	386240.00
8fb80cd9-9cfe-4052-aa70-8ec039895994	7f5f7470-be7f-4bf6-ab7c-13e3e17c3669	2987-112-2	apartment	\N	120.12	\N	407456.00
3c9ff994-a5c1-4991-8496-040a892548fe	7f5f7470-be7f-4bf6-ab7c-13e3e17c3669	2987-113-3	apartment	\N	173.82	\N	644640.00
45bf3580-ce8e-4852-bed1-78fc28334e83	dc6c5f78-bd0d-49f3-a863-bc35a1b14a84	2976-111-1	apartment	\N	60.15	\N	308448.00
cdb42cb6-8adc-4696-b563-f1fb603c6d6d	dc6c5f78-bd0d-49f3-a863-bc35a1b14a84	2976-112-2	apartment	\N	95.74	\N	435200.00
8fa8f80d-719c-44c4-874b-3bfebac4ba52	dc6c5f78-bd0d-49f3-a863-bc35a1b14a84	2976-113-3	apartment	\N	270.90	\N	1240320.00
5e38be64-c000-4841-8459-7a6c4453ca35	cf353625-904b-4e2d-aa44-39a6450c8e04	2975-164-1	penthouse	\N	128.35	\N	797832.03
cca50373-4933-4224-a8b5-41c0277c690a	da04575c-e8e5-46ba-8d6e-b8fc3d1b921a	2972-112-1	apartment	\N	129.89	\N	527633.22
15b05909-5ef9-445e-b543-cdf34cda1d90	da04575c-e8e5-46ba-8d6e-b8fc3d1b921a	2972-113-2	apartment	\N	284.87	\N	1180161.22
e6ab0227-ddf2-4da6-a827-05aca5bbdeb7	1dd49a52-d3d3-4777-a5f6-bcc8b0230314	2971-110-1	apartment	\N	43.14	\N	280160.00
f7d74c8a-8ffe-43b4-8fb4-6baf32359ff8	1dd49a52-d3d3-4777-a5f6-bcc8b0230314	2971-111-2	apartment	\N	106.43	\N	342720.00
d02a9e57-9af2-4adc-bb96-74b90f1e9d66	1dd49a52-d3d3-4777-a5f6-bcc8b0230314	2971-112-3	apartment	\N	124.76	\N	562768.00
48dc7fd7-9fee-4c76-8890-783db7b5c3c7	5b4a3b76-c235-4c74-a4a5-5855c8896f45	2968-110-1	apartment	\N	46.27	\N	233104.00
d49fbe50-59e7-455a-bce7-08f5781fbc71	5b4a3b76-c235-4c74-a4a5-5855c8896f45	2968-112-2	apartment	\N	141.17	\N	512992.00
852340cd-e85e-4179-b34d-e5cfe7d35239	01b3de9b-f81c-4321-a147-345e71240cb4	2966-114-1	penthouse	\N	401.02	\N	1510657.54
59f2d011-3a86-49f6-a4f6-9a445e279c75	01b3de9b-f81c-4321-a147-345e71240cb4	2966-341-2	villa	\N	335.51	\N	1396417.54
2fb06bb2-08f6-4fa0-9a3d-21449dc21682	789a25e7-262f-4805-8c8b-c9beb670396a	2963-110-1	apartment	\N	45.06	\N	225699.34
decbd096-c289-4de2-9656-8a6995149ec0	789a25e7-262f-4805-8c8b-c9beb670396a	2963-111-2	apartment	\N	79.59	\N	323619.34
7824cb8d-ca61-4251-bae7-3d29723b96ac	789a25e7-262f-4805-8c8b-c9beb670396a	2963-112-3	apartment	\N	123.38	\N	584800.00
44d7e3d3-2bb1-4905-be2a-da391f8eeadd	789a25e7-262f-4805-8c8b-c9beb670396a	2963-113-4	apartment	\N	244.68	\N	897539.34
8ae1ae35-2a6a-4c65-b613-2abe19906352	92710963-55e9-43f9-86a2-77d9a7e3f150	2956-113-1	apartment	\N	187.85	\N	1289114.62
8248fe79-bc6a-4001-8d15-8fa92610db61	fec96ff3-4e8c-49ed-95e5-c1db28be3526	2950-111-1	apartment	\N	81.62	\N	394399.73
3e1af6e0-0ae0-4fd6-bfc0-9b9bf7c1c799	fec96ff3-4e8c-49ed-95e5-c1db28be3526	2950-112-2	apartment	\N	122.98	\N	632399.73
c1559cf2-06b6-4256-b3b1-10466352d786	fec96ff3-4e8c-49ed-95e5-c1db28be3526	2950-113-3	apartment	\N	159.75	\N	897599.73
cff705b1-3fa1-4e69-8d00-59d6fc181019	fec96ff3-4e8c-49ed-95e5-c1db28be3526	2950-164-4	penthouse	\N	703.41	\N	4143082.24
a98cbe0c-5d0a-4b70-b515-5c01d8031d67	d19e5588-b013-4d8e-9def-fd424f740e7a	2948-110-1	apartment	\N	53.65	\N	201633.60
f27e3737-246f-421f-be39-e4c49ac1eccf	d19e5588-b013-4d8e-9def-fd424f740e7a	2948-111-2	apartment	\N	86.73	\N	253183.04
9346f395-a79e-4b3f-a686-4f7dc20227eb	bbc1964d-e520-42ad-b5dd-0cf1a0c73d1a	2943-112-1	apartment	\N	328.97	\N	2461790.40
cff8f146-5871-451a-991c-f2311ad173f2	bbc1964d-e520-42ad-b5dd-0cf1a0c73d1a	2943-113-2	apartment	\N	491.09	\N	4148000.00
3f343fe8-b51a-405c-823f-242ef53a441f	bbc1964d-e520-42ad-b5dd-0cf1a0c73d1a	2943-114-3	penthouse	\N	417.88	\N	6045390.40
0ab9c66e-57ba-4a95-a13a-a67b41c1066e	6445ed42-b5ef-4d1a-b55e-1b5c1b22d843	2939-113-1	apartment	\N	245.82	\N	1098547.34
17bf9fc4-ea08-4f7a-8b77-103796e0773b	6445ed42-b5ef-4d1a-b55e-1b5c1b22d843	2939-114-2	penthouse	\N	477.34	\N	4599731.34
5bc99f96-c016-4a88-8c57-169947284cd2	bf4ca676-2616-420c-a985-40838a039d10	2938-110-1	apartment	\N	53.33	\N	201305.30
812a6596-d6f2-4f93-a25a-d59666497604	bf4ca676-2616-420c-a985-40838a039d10	2938-111-2	apartment	\N	89.01	\N	327291.34
0c56c8a4-9039-420d-ac05-a35fd42368de	bf4ca676-2616-420c-a985-40838a039d10	2938-112-3	apartment	\N	154.49	\N	546689.54
ec95fa47-d361-4ac3-8655-0344579d0a3d	bf4ca676-2616-420c-a985-40838a039d10	2938-113-4	apartment	\N	190.65	\N	687857.54
36b906cb-f750-4917-9958-da27a2e70b3a	e8ad9df3-6e8d-4cfc-aa3e-2d9307aca548	2936-110-1	apartment	\N	60.02	\N	166464.00
2f686d6c-32cd-441b-8a9b-4ec4595d8105	e8ad9df3-6e8d-4cfc-aa3e-2d9307aca548	2936-111-2	apartment	\N	89.65	\N	272816.00
d1070665-2e4f-45fd-b6a9-6556054405e9	e8ad9df3-6e8d-4cfc-aa3e-2d9307aca548	2936-112-3	apartment	\N	149.67	\N	617984.00
3a6a9a68-20fd-4ab3-9c00-3813519620ba	e8ad9df3-6e8d-4cfc-aa3e-2d9307aca548	2936-113-4	apartment	\N	177.07	\N	683808.00
05522f89-6172-41a0-af97-5a568e633c0f	48d3f513-6ca6-4ad1-87b2-ef7883e17a6b	2932-110-1	apartment	\N	45.16	\N	215424.00
8dae6ecb-a6d3-4757-bc66-a5e2aff90621	48d3f513-6ca6-4ad1-87b2-ef7883e17a6b	2932-111-2	apartment	\N	89.65	\N	389776.00
d8f1d15b-4466-4c6f-a602-7f7bfca15826	48d3f513-6ca6-4ad1-87b2-ef7883e17a6b	2932-112-3	apartment	\N	161.47	\N	635936.00
4319c82b-244d-4e54-b3ed-ef50eafbf41e	48d3f513-6ca6-4ad1-87b2-ef7883e17a6b	2932-113-4	apartment	\N	352.45	\N	1286016.00
374439a6-2cdf-47a8-995b-8c9724dc7757	c946e9cc-1c62-4fcb-8bd5-6eee7e00d27f	2922-110-1	apartment	\N	67.67	\N	277726.69
27cf8763-7327-47b3-b9bd-8249877ffdb3	c946e9cc-1c62-4fcb-8bd5-6eee7e00d27f	2922-111-2	apartment	\N	229.63	\N	419488.19
4a7d1f81-8ce8-4438-bad1-f5555221e8bd	c946e9cc-1c62-4fcb-8bd5-6eee7e00d27f	2922-112-3	apartment	\N	157.06	\N	516864.74
994a858c-3689-4e14-b09a-67042ae94862	51dc001f-85b8-42a4-be2c-c47850b48f3d	2921-111-1	apartment	\N	97.19	\N	536616.83
0a7dae6e-ffe9-4210-a567-b479ef3be959	51dc001f-85b8-42a4-be2c-c47850b48f3d	2921-112-2	apartment	\N	167.35	\N	660980.67
4617d02f-d3b0-4a5f-874f-e8920194174d	51dc001f-85b8-42a4-be2c-c47850b48f3d	2921-113-3	apartment	\N	276.72	\N	1532050.34
d489c378-5195-42a9-a004-2898ee0cbc54	34b16663-2395-4231-abb9-fc237cfaab79	2909-112-1	apartment	\N	147.85	\N	619888.00
8137c8e7-88f5-420b-9e27-50abb6c9599c	34b16663-2395-4231-abb9-fc237cfaab79	2909-114-2	penthouse	\N	349.76	\N	2433104.19
03121a50-f07a-4e61-b3e6-8a74a05ee85e	48f923e8-d57f-4498-97d8-fd0247aa45bd	2908-113-1	apartment	\N	225.99	\N	1376320.00
07b3718e-a8d6-4ebe-b102-dbc5c213b3bb	48f923e8-d57f-4498-97d8-fd0247aa45bd	2908-114-2	penthouse	\N	391.79	\N	2414816.00
d410b839-bbae-45f3-9bb7-44dff9f3509f	f4e863d3-81f5-4710-bbff-ea53929cdf82	2890-112-1	apartment	\N	107.12	\N	652800.00
7d84ad72-a8ba-4b77-a83c-af11db604eeb	8578e7a2-c000-4c7c-9a04-d72c1e63e5f8	2887-110-1	apartment	\N	49.42	\N	295815.78
8242861b-ac5a-4ff0-a451-6d45249ab56a	8578e7a2-c000-4c7c-9a04-d72c1e63e5f8	2887-111-2	apartment	\N	124.40	\N	486630.03
45ad192f-4e18-4132-8210-6141d380148e	87c8bb2e-337d-468d-b1e1-de49661a0f19	2874-110-1	apartment	\N	42.34	\N	394611.34
0da0dfdf-5556-420a-88c0-eb8fd8e7189e	87c8bb2e-337d-468d-b1e1-de49661a0f19	2874-111-2	apartment	\N	82.06	\N	500419.34
13f0cdc1-6c5e-4a62-b78c-c5595c2ef281	87c8bb2e-337d-468d-b1e1-de49661a0f19	2874-112-3	apartment	\N	137.05	\N	803427.34
da1ec1fc-1037-43ed-b9c3-3c66d0539382	f0eeebf0-cf70-42cf-831c-ae1fe4b7d893	2866-111-1	apartment	\N	82.32	\N	265118.13
b33f2245-88c8-4438-9d9e-100df0a51688	a7fa9e8b-d1e2-4c43-9a6f-bd3fc868e197	2864-111-1	apartment	\N	77.36	\N	249143.84
626aeba3-2c85-46aa-ade1-edc29a69db95	f0784546-c75e-49e4-b171-400c60941818	2853-110-1	apartment	\N	45.43	\N	205511.23
e19d8591-9aa9-4a78-b42c-a0d2fbcb7160	f0784546-c75e-49e4-b171-400c60941818	2853-111-2	apartment	\N	86.03	\N	317560.00
37e966e8-c38f-48ef-ae10-cdba80e0bfb8	f0784546-c75e-49e4-b171-400c60941818	2853-112-3	apartment	\N	115.76	\N	540314.94
2e975447-7946-4880-892e-eff1c81c1c14	d948c785-6ae9-4215-8723-431334fe481c	2840-112-1	apartment	\N	181.48	\N	1793854.14
57b61af6-6cfd-4cc1-9d52-97d77959a762	d948c785-6ae9-4215-8723-431334fe481c	2840-113-2	apartment	\N	385.26	\N	2048393.10
1ecc0691-6fe9-412f-a795-e6beee898b6b	d948c785-6ae9-4215-8723-431334fe481c	2840-114-3	penthouse	\N	991.47	\N	3962340.42
fdb36569-d5c3-4bcd-9075-fcc7a067291b	aec7efe7-21f2-4d71-b47b-61480739e467	2832-113-1	apartment	\N	184.97	\N	1244641.54
642202f8-c1b7-4b05-9200-4bffae8af95a	719f55f7-9492-4806-8748-3bc84f5b2ce8	2829-110-1	apartment	\N	44.61	\N	214880.00
ca59256b-333e-4f2a-9f71-711f6be80708	719f55f7-9492-4806-8748-3bc84f5b2ce8	2829-112-2	apartment	\N	147.90	\N	531760.00
67641f85-1ee0-44cb-b3ff-f4ab7da3a25b	e3f7da78-6fea-4ed5-9e77-723f8790edec	2821-110-1	apartment	\N	44.64	\N	250212.80
c35daa00-1b87-4593-a6c8-7e9944b6345b	e3f7da78-6fea-4ed5-9e77-723f8790edec	2821-111-2	apartment	\N	115.25	\N	320932.80
98ed06ed-b9ab-4f43-9823-6472df9779c1	6b53fe05-3895-403c-8b7f-91846cedeaf1	2808-112-1	apartment	\N	117.12	\N	394400.00
ee978560-4116-45a6-ab34-71bea650e0cd	10e86016-c248-4f30-8653-c2c72f48be63	2806-111-1	apartment	\N	94.94	\N	513264.00
75a4ffb1-ec8d-434d-9b5a-f0d48bae6253	3605dddd-2340-45a6-b8bc-02d65114fe75	2803-110-1	apartment	\N	59.58	\N	188768.00
efbde236-88e1-4abb-8139-09d310cb83ba	3605dddd-2340-45a6-b8bc-02d65114fe75	2803-112-2	apartment	\N	177.57	\N	391680.00
a5e017dc-bd66-4dad-90be-884140cf7e04	cdc28aaf-42bb-4c16-895f-6137f9ea4ee0	2798-111-1	apartment	\N	114.98	\N	517558.61
4cb58003-9a38-41a7-8e62-faa6bfc90eb1	cdc28aaf-42bb-4c16-895f-6137f9ea4ee0	2798-112-2	apartment	\N	124.91	\N	650394.98
2b8c2acd-32c4-4199-9417-72b29243fc5c	767c1ad1-5af7-491c-90c3-d59f58b10c5c	2793-111-1	apartment	\N	85.01	\N	322320.00
f221f446-e9f6-4d23-91bb-50d71e9f5984	7cbc48b3-781c-4f4a-8a64-0b555ac5e18e	2789-112-1	apartment	\N	124.77	\N	596917.87
5e62aff4-2d66-48f2-8cca-5fc983e5c282	972f7e3a-020c-4729-b85d-fd19afd0b153	2772-112-1	apartment	\N	161.19	\N	481440.00
fad83061-efe5-4b56-9949-cae3b5aab59e	36f84178-e650-44fd-8470-c5e320f7404f	2769-111-1	apartment	\N	95.15	\N	397236.69
644d94e1-24da-4078-bff7-e725321d7e30	36f84178-e650-44fd-8470-c5e320f7404f	2769-112-2	apartment	\N	138.33	\N	585629.87
4636ba48-7ce4-4ada-bcb2-118698236931	36f84178-e650-44fd-8470-c5e320f7404f	2769-113-3	apartment	\N	189.22	\N	814928.05
1df93b74-4d3d-4a55-9cd2-d102cca5f9e9	ac5d6764-073d-432b-8d2a-0fb796bd032f	2768-112-1	apartment	\N	98.20	\N	358496.00
5917389d-a3b1-4ae9-adf1-d469bccf7c0b	71f09e3b-2428-4d7f-af57-24e028832de4	2758-110-1	apartment	\N	69.03	\N	214064.00
7aaaaad7-93a0-42d9-b462-b35ced0a52ba	71f09e3b-2428-4d7f-af57-24e028832de4	2758-111-2	apartment	\N	89.65	\N	354688.00
d7543735-1dd0-4575-ae57-d1d602926eaf	71f09e3b-2428-4d7f-af57-24e028832de4	2758-112-3	apartment	\N	128.57	\N	510544.00
859abb51-f2d9-4085-a708-b6d3a5fbf9ca	de35ef0e-d79d-45a5-8d31-063b6cdb746f	2754-112-1	apartment	\N	180.88	\N	307360.00
49267560-736a-4c63-99b0-b399a2ef5674	f4246d8f-02eb-411e-add8-38b0110caa51	2750-111-1	apartment	\N	85.19	\N	451520.00
2a69373a-82b2-4e06-8024-6608ae885dde	f4246d8f-02eb-411e-add8-38b0110caa51	2750-112-2	apartment	\N	120.90	\N	652800.00
11b2b5ab-5183-494d-b5fb-58fd2f46286a	f4246d8f-02eb-411e-add8-38b0110caa51	2750-113-3	apartment	\N	161.39	\N	952000.00
fae9befb-34f1-4a94-9312-5290241e1f10	e85ffcab-8782-46d7-b9bd-7508db96c516	2748-110-1	apartment	\N	49.89	\N	261454.29
e7aeeeb7-6978-4511-8efd-7484609a53a6	e85ffcab-8782-46d7-b9bd-7508db96c516	2748-111-2	apartment	\N	114.62	\N	456003.65
d47304da-d46c-4ff7-98e5-462897eab9b6	e85ffcab-8782-46d7-b9bd-7508db96c516	2748-112-3	apartment	\N	235.07	\N	745162.50
4515ce53-6aef-4aa7-bd17-4db3150fd00c	e85ffcab-8782-46d7-b9bd-7508db96c516	2748-113-4	apartment	\N	406.53	\N	1018261.92
6066e5ad-8dd5-48ad-8336-492e9aa3d38a	e85ffcab-8782-46d7-b9bd-7508db96c516	2748-114-5	penthouse	\N	524.40	\N	1931200.00
a8ec0c4d-b988-4a74-9b52-1cfbba49db26	e85ffcab-8782-46d7-b9bd-7508db96c516	2748-115-6	penthouse	\N	555.37	\N	2926805.68
6fe310e8-db7b-4bdf-93fd-f97758801d7f	cbbac9bd-f36a-4775-bb27-f953b67e3ddc	2747-110-1	apartment	\N	71.29	\N	468353.54
fa2c0824-85f1-49aa-b9de-92d1982d26b9	cbbac9bd-f36a-4775-bb27-f953b67e3ddc	2747-111-2	apartment	\N	132.48	\N	601089.54
593b7b8a-7ed7-42d5-8c6a-2ff8697ee23c	ec564565-d2f1-40a0-bb33-fcc62dbedd6d	2746-110-1	apartment	\N	36.14	\N	150422.53
760fe0ef-b1f6-42c7-8765-dd2576e4ff91	ec564565-d2f1-40a0-bb33-fcc62dbedd6d	2746-111-2	apartment	\N	63.92	\N	249424.00
5be283ae-a4d0-47da-a055-5567c7e8908b	ec564565-d2f1-40a0-bb33-fcc62dbedd6d	2746-112-3	apartment	\N	121.70	\N	302192.00
c9e3e466-85ac-429a-a8f6-df797b8802a6	ec564565-d2f1-40a0-bb33-fcc62dbedd6d	2746-114-4	penthouse	\N	167.50	\N	425680.00
30e7194c-e775-4a91-a60c-3887058f47dc	ff66f79f-f3f7-48ae-8ed8-4eb9a96f287b	2745-113-1	apartment	\N	249.17	\N	2635649.54
df16b425-d930-45aa-ad7b-13c73be6b0e3	06902e70-cab3-4e9e-b2bf-eb82ea58132c	2739-111-1	apartment	\N	122.35	\N	400471.31
fe2e1409-2a27-438b-aecc-d27d00ac486f	06902e70-cab3-4e9e-b2bf-eb82ea58132c	2739-112-2	apartment	\N	228.43	\N	752741.78
7304aae6-23f3-423b-9854-6b27e9174f83	06902e70-cab3-4e9e-b2bf-eb82ea58132c	2739-113-3	apartment	\N	224.30	\N	893112.54
05f39159-275d-4816-86dd-1da2ce035ea3	496ff9e0-1728-46f0-be76-8dcbe006f678	2737-111-1	apartment	\N	119.84	\N	352343.63
10527989-1a6c-4a7d-bff5-1f6bb702f3a8	496ff9e0-1728-46f0-be76-8dcbe006f678	2737-112-2	apartment	\N	168.52	\N	538370.14
928b2f9d-3844-4b36-a985-7682c9a002bb	4e76fcd7-181f-499c-89e6-b9d1bf4de598	2715-110-1	apartment	\N	43.95	\N	303449.73
266854cc-6b8f-4cd7-a6e7-58d1f14e3475	4e76fcd7-181f-499c-89e6-b9d1bf4de598	2715-111-2	apartment	\N	85.47	\N	407489.73
3f5bcf83-6a98-48df-a34e-73acc34776ae	4e76fcd7-181f-499c-89e6-b9d1bf4de598	2715-112-3	apartment	\N	135.64	\N	606899.73
b4330f51-c63b-4c5b-838c-7b0243fa1ec8	850b3656-ed2b-4f1b-a05b-59f1528838c5	2708-112-1	apartment	\N	110.55	\N	768097.54
b26fd6b2-1fb9-4422-91b2-381075643e61	850b3656-ed2b-4f1b-a05b-59f1528838c5	2708-113-2	apartment	\N	148.92	\N	1023233.54
c30482c5-b81d-43a6-b3c7-dd1be0acc108	e8946b48-2d15-4482-a41f-921399e55a70	2695-111-1	apartment	\N	139.08	\N	499254.91
9dea9fad-cbad-4624-95f4-461720f373e0	e8946b48-2d15-4482-a41f-921399e55a70	2695-112-2	apartment	\N	241.86	\N	705693.66
e9c2ecff-ca59-4e9a-9276-494aa1b69039	e8946b48-2d15-4482-a41f-921399e55a70	2695-113-3	apartment	\N	340.19	\N	954100.66
765685e5-4087-400c-98bd-6772bab4ea2b	36c65feb-2145-4106-a86a-6b13b42fabe0	2691-164-1	penthouse	\N	561.13	\N	16320000.00
e7d88b68-e718-435a-b687-92ee2b7bb824	5c44dfe2-7e21-47f3-b784-d7b1e67ad315	2689-110-1	apartment	\N	76.41	\N	719440.00
3809a1ff-fc76-4e00-a2e8-43d15ec92f73	5c44dfe2-7e21-47f3-b784-d7b1e67ad315	2689-111-2	apartment	\N	74.87	\N	631040.00
29c95a17-8939-4bd5-83ec-66df7e3f3462	5c44dfe2-7e21-47f3-b784-d7b1e67ad315	2689-112-3	apartment	\N	133.94	\N	855168.00
c24cf03f-0ea3-430a-81b0-bfde9d651961	5c44dfe2-7e21-47f3-b784-d7b1e67ad315	2689-113-4	apartment	\N	150.08	\N	1489744.00
10b258e8-73ec-4133-b386-63a422ba329b	5c44dfe2-7e21-47f3-b784-d7b1e67ad315	2689-114-5	penthouse	\N	186.68	\N	1915152.00
7ed9090a-b4f3-4bcc-a776-98662ad6fc1f	5c44dfe2-7e21-47f3-b784-d7b1e67ad315	2689-115-6	penthouse	\N	802.93	\N	8275056.00
2650dd0d-6dc8-4681-8187-b133e5ee1e1d	e6e048a8-5f1c-4e28-bda6-cb8438c9c434	2688-111-1	apartment	\N	129.35	\N	514324.80
8e91ad97-7f7f-4f8a-a55d-4b06838678ae	e6e048a8-5f1c-4e28-bda6-cb8438c9c434	2688-112-2	apartment	\N	118.77	\N	489484.94
ffc8f620-9a95-40ec-b5c4-24374f43b24e	e6e048a8-5f1c-4e28-bda6-cb8438c9c434	2688-113-3	apartment	\N	325.69	\N	1108691.86
811b071d-6949-4d8b-9a56-4a39d54e44f2	b3297240-6b20-4548-b583-8129f286113a	2675-111-1	apartment	\N	95.33	\N	544259.49
e44f6432-8343-4016-8fab-c339b9a91b9d	b3297240-6b20-4548-b583-8129f286113a	2675-112-2	apartment	\N	152.65	\N	581141.60
f80d8f76-dc2b-4398-947b-4c40d30ecd89	b3297240-6b20-4548-b583-8129f286113a	2675-113-3	apartment	\N	176.07	\N	1074805.82
99b0de7c-dc31-4785-ac8d-b2c4f592c1f7	e90d4cd3-ee2e-48e6-8530-87bcf6ca6f62	2670-111-1	apartment	\N	74.94	\N	431024.53
844ce933-3be2-42de-b9da-847b9c655f99	0ffbf9ca-72bd-4f9f-8c38-5c847b7a9d9d	2658-110-1	apartment	\N	44.17	\N	268770.00
7c8b1bad-a9e4-4533-bdd7-6b9ff1fffc9d	0ffbf9ca-72bd-4f9f-8c38-5c847b7a9d9d	2658-112-2	apartment	\N	131.28	\N	577999.73
405f3e77-cce4-4fd0-8468-c58af4472733	0ffbf9ca-72bd-4f9f-8c38-5c847b7a9d9d	2658-113-3	apartment	\N	227.83	\N	866999.73
661c0a56-e371-4b96-9dac-ae7fafc9760a	41fe7d42-e18f-41e1-bfb1-5f3a1c675ad8	2652-111-1	apartment	\N	193.93	\N	738118.78
3e3b8f7f-ca7a-4faf-b220-e70008f40742	41fe7d42-e18f-41e1-bfb1-5f3a1c675ad8	2652-112-2	apartment	\N	214.74	\N	447597.49
af14b8b2-b7c0-480f-b3b7-bdc6dc6a77eb	7734b06d-3332-461e-a45a-c1fc5602453a	2649-111-1	apartment	\N	105.05	\N	373710.86
1d2c40fc-808d-4563-b5c7-b858acfcfa1a	7734b06d-3332-461e-a45a-c1fc5602453a	2649-113-2	apartment	\N	151.59	\N	567003.86
bd2755e8-92a3-4c63-8cf2-007ea9bd4ddd	304ad027-8b76-4907-8958-3ba688ee4049	2636-112-1	apartment	\N	110.47	\N	462400.00
77f1d1b4-d103-438d-87fb-57f062f60dd7	e51794a7-a2b7-4bcc-b2a8-4d737e19246e	2635-110-1	apartment	\N	35.28	\N	193120.00
825ee98c-221c-452b-81ca-908d3b09cb4c	e51794a7-a2b7-4bcc-b2a8-4d737e19246e	2635-111-2	apartment	\N	63.29	\N	312800.00
bf6f0c51-e234-47d9-af16-a6c1c560c3a0	e51794a7-a2b7-4bcc-b2a8-4d737e19246e	2635-112-3	apartment	\N	143.38	\N	476000.00
5edff141-13bc-4387-be9d-063b88009cdc	e0c8640a-06d1-4785-a4b0-9d9492c728bc	2631-111-1	apartment	\N	104.01	\N	431196.98
4e7e54c0-e1bc-44ea-bfdd-6a790e831308	bed0fc3e-1574-4684-868c-dd8830caad58	2630-110-1	apartment	\N	47.19	\N	208188.80
12b9dd05-7283-4a21-8eb9-76956dec4016	bed0fc3e-1574-4684-868c-dd8830caad58	2630-111-2	apartment	\N	84.91	\N	322619.20
ab46ea05-d916-4c5f-b739-2fac54de8942	bed0fc3e-1574-4684-868c-dd8830caad58	2630-112-3	apartment	\N	162.67	\N	544584.80
df0bbef4-ee4f-44e6-97b8-af7a509c88b8	3060854a-9728-4248-9a7c-d316b52eb808	2629-112-1	apartment	\N	207.92	\N	563795.34
68ee4173-eaa3-464b-8aa8-900fb17c15e1	3060854a-9728-4248-9a7c-d316b52eb808	2629-113-2	apartment	\N	241.46	\N	716387.34
72edd618-430f-4b7c-a9a0-d69cb3ced3db	70a3d176-93b5-478d-913c-762949306371	2627-110-1	apartment	\N	38.37	\N	209440.00
9af401b7-8f80-4677-886b-e5cf2ecbbd90	70a3d176-93b5-478d-913c-762949306371	2627-111-2	apartment	\N	82.31	\N	299200.00
fd2823cf-824a-4c6d-bdc9-566a70dd5951	70a3d176-93b5-478d-913c-762949306371	2627-112-3	apartment	\N	103.49	\N	476000.00
a80476a1-8303-4875-a23d-91588ed64d76	bb05f778-55a0-4c28-b42e-5887096b4b0d	2624-110-1	apartment	\N	44.87	\N	243014.86
859258fc-2539-4c0c-a7b3-8ee1111bbc04	bb05f778-55a0-4c28-b42e-5887096b4b0d	2624-111-2	apartment	\N	88.26	\N	383196.32
3373bd85-cf59-422a-b366-17297b02ce31	d0026b34-8a4d-4377-b877-bceede4df19c	2603-112-1	apartment	\N	221.57	\N	1604256.00
db60502f-678a-4718-ba0c-6e9fcea9e940	d0026b34-8a4d-4377-b877-bceede4df19c	2603-113-2	apartment	\N	280.75	\N	2466161.44
60344cd0-87ef-45ad-828c-1951456b0a79	d0026b34-8a4d-4377-b877-bceede4df19c	2603-114-3	penthouse	\N	797.48	\N	5882304.64
04e961ea-1dcd-4d77-8e58-20e64b697525	0c372740-84e0-4d34-bee5-6782e311232c	2595-111-1	apartment	\N	83.61	\N	613060.80
132468b0-2a04-43a8-8a04-4dd902175c4a	0c372740-84e0-4d34-bee5-6782e311232c	2595-113-2	apartment	\N	171.25	\N	1047452.96
4fbcf4ec-285b-4bb4-a352-32b6520a5d28	0c372740-84e0-4d34-bee5-6782e311232c	2595-114-3	penthouse	\N	183.71	\N	1236628.96
a919de32-8ee9-47ea-a71a-566c6495fe4c	581ba022-ddd0-4814-a1cf-7521abb3733b	2573-112-1	apartment	\N	103.28	\N	612000.00
6b169e06-a57d-4e8b-8552-327ad4867463	eab8221b-6868-47b9-a8f7-afc0d4d0333a	2572-112-1	apartment	\N	166.55	\N	443568.90
f35709eb-257a-4e06-815a-01353f270f8c	51319992-73f8-413d-bf57-fc1bd22b3949	2570-111-1	apartment	\N	69.03	\N	252960.00
f32e7d70-5d05-4308-b5cf-36ace3eaed58	51319992-73f8-413d-bf57-fc1bd22b3949	2570-112-2	apartment	\N	125.14	\N	307360.00
dc972a22-68c1-4968-86f7-4e5243dd3470	51319992-73f8-413d-bf57-fc1bd22b3949	2570-114-3	penthouse	\N	255.30	\N	440640.00
28752fa4-ffa3-4417-9675-42b76c00e2fd	40e400e8-f5d2-4f0c-96cf-21dc9d96264e	2568-111-1	apartment	\N	108.81	\N	477857.76
60ecac8f-3bfd-4ea6-9190-e4350ee13d97	40e400e8-f5d2-4f0c-96cf-21dc9d96264e	2568-112-2	apartment	\N	102.04	\N	448126.80
0e967cb8-c44c-4514-a9a4-356988caac10	203a27f3-7e9c-4c1f-9bb9-e1872be285a1	2566-112-1	apartment	\N	103.64	\N	409637.44
2e5e90f6-5b4c-4428-a36a-0cceee703cd8	83588824-45d1-4519-8aed-0240c8649806	2565-110-1	apartment	\N	36.05	\N	190400.00
a0b699dd-9e60-4464-ad87-a108c1b79b06	83588824-45d1-4519-8aed-0240c8649806	2565-111-2	apartment	\N	73.39	\N	306000.00
ab060e03-cb7c-4a70-b13e-ef48e8328c4b	3d78d09d-ebe0-41a5-9396-c5a7ad6e241e	2562-110-1	apartment	\N	73.37	\N	231869.66
79fdb774-877a-4078-a6b7-eb10e7a352af	3d78d09d-ebe0-41a5-9396-c5a7ad6e241e	2562-111-2	apartment	\N	104.63	\N	398233.84
9cc71494-2500-4da3-bdc3-4d39719dbad2	3d78d09d-ebe0-41a5-9396-c5a7ad6e241e	2562-112-3	apartment	\N	162.20	\N	440976.46
4977c7ca-b793-4d43-9041-6b418295051c	be781f00-60e4-4478-8317-8ec8b8868cf6	2559-110-1	apartment	\N	65.10	\N	241268.35
ef849f71-6a7c-437c-b450-0ea22aef40d0	be781f00-60e4-4478-8317-8ec8b8868cf6	2559-111-2	apartment	\N	129.62	\N	471843.84
ec706f9c-1006-432a-8621-d6c19d22581c	be781f00-60e4-4478-8317-8ec8b8868cf6	2559-112-3	apartment	\N	116.95	\N	443375.50
6a030d2e-cb8c-40f5-848b-cd85936e8629	4a50ba16-2010-4b3e-a432-eaf7baeefe1f	2558-110-1	apartment	\N	40.59	\N	202027.18
dc5fbec8-9203-4ece-ac83-f5a9b393e5d5	4a50ba16-2010-4b3e-a432-eaf7baeefe1f	2558-111-2	apartment	\N	159.42	\N	411325.20
b0616d67-e779-4d47-970f-8807cf46ef1b	582847a7-5ce4-40db-b775-f1b318ce7216	2556-112-1	apartment	\N	188.87	\N	961883.66
d757acb5-3151-4fb1-b966-f9a997e7548e	582847a7-5ce4-40db-b775-f1b318ce7216	2556-113-2	apartment	\N	157.47	\N	1055551.49
c1efd449-c1a2-4151-a427-7ec0fb479875	7aae4884-2cf9-4cd3-8a7b-8d30fc5c4cef	2554-111-1	apartment	\N	69.42	\N	332780.58
47aebe09-df89-4c15-9b86-475544f35104	7aae4884-2cf9-4cd3-8a7b-8d30fc5c4cef	2554-112-2	apartment	\N	119.82	\N	501943.36
90695532-6275-4fc2-9cf4-83ba750c0a4e	7aae4884-2cf9-4cd3-8a7b-8d30fc5c4cef	2554-113-3	apartment	\N	222.37	\N	642759.39
abb224b3-ce00-4239-812c-06c588dcd5ae	103c3cad-02d5-4586-bc9c-d9c5864b4b4f	2540-111-1	apartment	\N	148.87	\N	356320.00
2b5c4a7d-417c-4bc1-89af-61dbb55e5d00	4599c287-ea7a-4339-a818-0e2ace09340f	2539-112-1	apartment	\N	141.96	\N	523858.94
00700dcd-a2ab-47e5-9ce3-d92489e97008	386c08a7-2ca6-4720-b69d-fdd40c7c6f46	2528-113-1	apartment	\N	192.50	\N	937281.54
6af215f1-f6ac-42d6-8b39-38a644d8fa0b	4116aeda-cda9-4eb4-aede-9cf837742d88	2519-111-1	apartment	\N	114.73	\N	247792.00
bc21f85d-dcbd-4366-a894-5f6e2a68aafe	4ac9a487-b698-481b-a91d-1780e8d7cc88	2494-111-1	apartment	\N	163.70	\N	372640.00
4368a3ff-c01b-4e0d-89d7-263359e6713c	4ac9a487-b698-481b-a91d-1780e8d7cc88	2494-112-2	apartment	\N	194.63	\N	658240.00
83a7d971-78bf-4374-9dd5-cb11ecf46c7a	4ac9a487-b698-481b-a91d-1780e8d7cc88	2494-164-3	penthouse	\N	325.53	\N	1985892.13
a5abaa1b-a3d7-4e26-a0fb-3f4219fce82f	fc2d01c4-183e-44cc-8dd5-716652ca087c	2484-112-1	apartment	\N	144.84	\N	753137.54
8449cac3-c7b9-488a-bd4e-75c8b3f122b8	fc2d01c4-183e-44cc-8dd5-716652ca087c	2484-113-2	apartment	\N	179.40	\N	1038465.54
582618ee-1e4e-4a14-9a97-6adf45d86c2a	e2c26585-34e1-4e10-9d77-f5168d9376a8	2477-112-1	apartment	\N	142.56	\N	964620.80
b1ebf0d8-d37a-4711-9e38-92350a18bb9e	e2c26585-34e1-4e10-9d77-f5168d9376a8	2477-113-2	apartment	\N	171.25	\N	1112936.96
c3ec29e1-5cf6-4d6c-978b-fcd3f623e9bb	e2c26585-34e1-4e10-9d77-f5168d9376a8	2477-114-3	penthouse	\N	183.41	\N	1251180.96
b9ca2d33-77e9-4925-9639-585df2dcb019	b0c60bde-d3ad-4c76-95ef-31bc7da8b5f4	2476-111-1	apartment	\N	101.17	\N	504916.05
a8a3b256-dafe-49f0-939b-762eafb8db00	9f241dac-737f-464f-9365-1951700b954b	2475-111-1	apartment	\N	97.29	\N	408000.00
54ff5285-96ba-43e0-b503-ef8edd1ba742	9f241dac-737f-464f-9365-1951700b954b	2475-112-2	apartment	\N	137.77	\N	537200.00
17c8041c-8804-4781-99ab-b7ac4c3fb4cf	a688263d-e131-4d24-b0fa-d8477a4791e2	2468-113-1	apartment	\N	179.02	\N	1085793.54
3c855221-4837-4db5-89ad-4ddfa15e9fda	bfdf7ece-d03f-4c58-8578-83ef4ede0eec	2467-111-1	apartment	\N	77.41	\N	619555.34
f4d4bf46-057c-43cf-ae21-14ee19336bb3	bfdf7ece-d03f-4c58-8578-83ef4ede0eec	2467-112-2	apartment	\N	124.07	\N	1018851.34
4793a667-6661-4d7d-bd4f-ecc8eb5dfea4	b8b7b47a-5a0c-4c59-9eec-60e4df1df395	2456-112-1	apartment	\N	184.97	\N	333472.00
895529d2-081b-4b21-89bc-a3410036d01f	81f82292-c68c-4d25-b81c-bc990754bde8	2455-110-1	apartment	\N	52.23	\N	414800.00
eae0df02-000d-4bc3-abd8-be0cfdc1ffd7	81f82292-c68c-4d25-b81c-bc990754bde8	2455-111-2	apartment	\N	78.32	\N	639200.00
83d00a9f-547d-449c-b548-d8f453a9c136	81f82292-c68c-4d25-b81c-bc990754bde8	2455-112-3	apartment	\N	131.14	\N	911200.00
af80f2d9-bc30-4bea-8c73-02de6f7fa0cc	f4cacdf8-a265-485e-92b9-df7c2fcc151e	2454-111-1	apartment	\N	74.53	\N	329459.73
d48838e3-d5aa-4e63-919c-9f194e3a5a6e	b49d6758-e8ef-4be2-9b0c-745d42eb602a	2449-110-1	apartment	\N	62.25	\N	183140.32
2717403b-eb90-4d51-badd-86636f72cbab	b49d6758-e8ef-4be2-9b0c-745d42eb602a	2449-112-2	apartment	\N	210.43	\N	387245.58
afcea133-47f3-4193-8aad-e09fdd27c715	1ad7e784-23be-4ac5-8724-e4efd4a382e3	2441-110-1	apartment	\N	33.35	\N	188496.00
86a79bb3-dede-4e69-8191-a63be2bb251d	8e32dd3a-b0cc-4fb1-acb0-f4cb3db3d25d	2431-114-1	penthouse	\N	985.80	\N	6419441.54
37c1f86a-7f8c-4cd0-9a3a-3b0c52fad489	ef2146a4-d35c-4dd3-9c3b-15c57895d60a	2429-111-1	apartment	\N	106.90	\N	517513.46
3c3d0100-3f23-4ed4-950b-ca8d6dd82afd	ef2146a4-d35c-4dd3-9c3b-15c57895d60a	2429-112-2	apartment	\N	190.67	\N	940623.60
89ed2f5c-8888-4eda-95c5-86eed5ede6c5	ef2146a4-d35c-4dd3-9c3b-15c57895d60a	2429-113-3	apartment	\N	259.18	\N	1097186.80
72318755-ff8c-415c-b4d3-0794ef76412e	ef2146a4-d35c-4dd3-9c3b-15c57895d60a	2429-114-4	penthouse	\N	268.17	\N	2113030.37
0154ff18-16fb-4546-9add-ede52045d214	452baa22-69fe-4e00-862c-db0e3406be05	2428-112-1	apartment	\N	191.48	\N	884231.20
434c7034-539f-48a4-af33-ec9aede488a0	6dfb11d0-72bb-4391-bd84-b03e99c743cd	2426-110-1	apartment	\N	43.69	\N	273377.95
8423b481-e66e-46c5-804c-078561e50bd0	6dfb11d0-72bb-4391-bd84-b03e99c743cd	2426-111-2	apartment	\N	93.93	\N	434576.85
f0479701-1e30-4475-955f-6db3f59c4985	6dfb11d0-72bb-4391-bd84-b03e99c743cd	2426-112-3	apartment	\N	409.33	\N	2144231.22
4b0dbec4-7efd-4e1c-acb7-06601bb3e57f	3780af90-e86f-4df8-a8e2-14b029c73f7a	2422-112-1	apartment	\N	116.81	\N	1127493.31
889dc2f9-93d4-4a64-8fa5-435e42d448cb	b46aa2eb-be17-4003-9eb1-2fc79ecfa208	2421-111-1	apartment	\N	59.22	\N	381007.26
129fed9e-245c-4b11-8b7f-48ea800bc111	b46aa2eb-be17-4003-9eb1-2fc79ecfa208	2421-112-2	apartment	\N	128.08	\N	598604.27
57bddca6-50e9-4e75-af32-2b73885cb558	8a42328a-5f7f-4e1d-8504-089f55d56734	2419-111-1	apartment	\N	64.11	\N	541280.00
37c78191-8a5a-48d7-a77c-3b7f29168dff	8a42328a-5f7f-4e1d-8504-089f55d56734	2419-112-2	apartment	\N	101.01	\N	816000.00
e5e69169-4fdb-43e2-b389-2e7792ddae36	fb926fd7-b211-446c-bea1-30033ac309a9	2414-110-1	apartment	\N	61.33	\N	234004.59
f7087af1-ba19-41f3-8a40-b284c4d9ffab	fb926fd7-b211-446c-bea1-30033ac309a9	2414-111-2	apartment	\N	110.90	\N	393227.14
100f1c70-87ef-48a9-8ce1-00a2b904f771	9e06fd43-85ef-405d-a386-ffb98ce4d208	2404-111-1	apartment	\N	110.18	\N	502486.82
6c23d305-8f1c-4515-8e45-4b0d037e71cb	9e06fd43-85ef-405d-a386-ffb98ce4d208	2404-112-2	apartment	\N	163.70	\N	766078.75
cd296537-a9e2-4437-a5e5-eeec134010a9	2cc60344-14af-424b-bf2a-5969db7320cd	2393-111-1	apartment	\N	104.74	\N	440200.45
b9caa9a5-e2a4-412e-8570-fa3aa0a2c9dc	2cc60344-14af-424b-bf2a-5969db7320cd	2393-112-2	apartment	\N	137.59	\N	554079.50
260c3ebe-8b3c-4468-b0b3-4bfc1d0c8e84	2cc60344-14af-424b-bf2a-5969db7320cd	2393-113-3	apartment	\N	459.52	\N	742574.42
a1889bcf-a579-420d-b202-2545edd59d48	2cc60344-14af-424b-bf2a-5969db7320cd	2393-114-4	penthouse	\N	620.19	\N	1354107.94
0d3ed2a4-ce47-45ce-bbb4-082d6242e5c9	5f8c993e-90d4-423e-bf5b-7f7cef2324a5	2391-111-1	apartment	\N	78.13	\N	483925.81
5a3c6bb5-699b-4e26-9bab-ad110f401a9f	5f8c993e-90d4-423e-bf5b-7f7cef2324a5	2391-113-2	apartment	\N	162.00	\N	1033600.00
ae605cae-6a62-47a0-b0ea-5a3780186bb0	86bdd8be-f3fa-4df1-b7c2-b664f76b498f	2373-110-1	apartment	\N	39.48	\N	178758.40
8b066281-8adc-4c4a-8609-203107833794	86bdd8be-f3fa-4df1-b7c2-b664f76b498f	2373-111-2	apartment	\N	96.71	\N	351777.60
09e3d320-823c-4575-98bf-a598986663ba	c95fbcd5-08b4-4d48-b014-5d92f35d98e4	2359-110-1	apartment	\N	34.84	\N	197200.00
9e900dac-4f23-40e1-a4fd-a0871437bac9	c95fbcd5-08b4-4d48-b014-5d92f35d98e4	2359-111-2	apartment	\N	83.15	\N	312800.00
f99d2f40-fcd8-4722-b2e0-7f5747f84eae	c95fbcd5-08b4-4d48-b014-5d92f35d98e4	2359-112-3	apartment	\N	104.27	\N	435200.00
7f293386-7f3a-456b-8369-1bc4ea93e1ca	c95fbcd5-08b4-4d48-b014-5d92f35d98e4	2359-113-4	apartment	\N	268.23	\N	816000.00
093df641-3594-4697-9d09-1ebbca29391f	577dc87a-7c8e-41d5-878b-247d20717f2e	2357-111-1	apartment	\N	79.53	\N	242080.00
53343dbe-3b88-412b-88f9-516559cf88b9	577dc87a-7c8e-41d5-878b-247d20717f2e	2357-112-2	apartment	\N	121.52	\N	314976.00
cc783095-6361-446d-b13a-cde80a3860ff	577dc87a-7c8e-41d5-878b-247d20717f2e	2357-114-3	penthouse	\N	171.22	\N	414528.00
bed903f7-f27d-4309-9c44-52262aa95db8	7bd6c281-970d-4200-83e7-d6d99876602b	2346-111-1	apartment	\N	86.21	\N	482769.54
a2649e40-de0f-4403-a9aa-0ef674902f3a	7bd6c281-970d-4200-83e7-d6d99876602b	2346-112-2	apartment	\N	149.76	\N	848337.54
8b68f203-dabe-4ef9-8167-2eacc9c29712	7bd6c281-970d-4200-83e7-d6d99876602b	2346-113-3	apartment	\N	192.03	\N	1115169.54
b9163ac8-5141-4091-862a-60cbf0f64659	23e7f4bc-4c23-497e-9ac1-99fe8435a321	2338-111-1	apartment	\N	92.13	\N	288276.48
64857b6d-09e3-42e0-bf85-7e868ee256ba	9d14ba03-23e0-426a-8fa3-a53a00ca879d	2335-110-1	apartment	\N	40.23	\N	229540.53
c10d1aa3-499c-4c23-9791-ec6ea349ff24	9d14ba03-23e0-426a-8fa3-a53a00ca879d	2335-111-2	apartment	\N	77.48	\N	366737.33
84468dfb-88c5-4106-b727-585a7bea8d95	73d4b8e1-004c-4b9b-b86c-c8263fc477c0	2331-111-1	apartment	\N	111.78	\N	329120.00
042700ee-5dc9-480e-b850-cfebf45a0260	73d4b8e1-004c-4b9b-b86c-c8263fc477c0	2331-112-2	apartment	\N	211.03	\N	473280.00
6e563d54-9c72-4fc4-b1cc-a5a91451a384	5be09fc4-1749-42ce-b9d8-2f777bd48305	2329-111-1	apartment	\N	106.23	\N	516062.88
88e6f4e8-653d-426a-a820-269dc01fa8dd	5be09fc4-1749-42ce-b9d8-2f777bd48305	2329-112-2	apartment	\N	189.12	\N	899456.67
161ddbd2-4c98-47a7-88fe-c5331defe0d4	5be09fc4-1749-42ce-b9d8-2f777bd48305	2329-113-3	apartment	\N	186.59	\N	1338424.42
1044d942-4567-450e-9a80-d16b7745b0b8	2eb2ee6b-35e3-4c4f-a5fd-014858a8acca	2328-112-1	apartment	\N	192.03	\N	979200.00
67f0fff9-8f05-4964-83bd-09cdfe44282f	2eb2ee6b-35e3-4c4f-a5fd-014858a8acca	2328-113-2	apartment	\N	287.16	\N	1387200.00
cb2131c3-4d16-4868-9182-1fa554da441d	9018ad1e-d821-4c3c-893e-b6dbbfb71142	2318-112-1	apartment	\N	0.11	\N	1224000.00
e9d97fe9-bc88-4f66-a305-dc70cc80684d	ae2f5586-f0e0-4c15-ad35-ddf5418df006	2314-111-1	apartment	\N	136.47	\N	1317840.00
b05129e6-05f9-4460-9546-41413a8b34b7	ae2f5586-f0e0-4c15-ad35-ddf5418df006	2314-112-2	apartment	\N	236.35	\N	2087600.00
cb37b45e-7063-45ee-b0ff-1dc106a4b018	ae2f5586-f0e0-4c15-ad35-ddf5418df006	2314-113-3	apartment	\N	322.47	\N	3351040.00
e20c1889-2541-417a-b8bf-2c3aec513e5c	ae2f5586-f0e0-4c15-ad35-ddf5418df006	2314-114-4	penthouse	\N	402.18	\N	4981680.00
139916ef-4ae1-4450-b3de-8699233a6b0b	ae2f5586-f0e0-4c15-ad35-ddf5418df006	2314-115-5	penthouse	\N	713.68	\N	11045920.00
793308a8-bdea-42dc-8916-a1a96bb46cfa	743a0243-bca2-4513-8fc0-ccbe974b7ba0	2311-111-1	apartment	\N	89.06	\N	355987.34
38811195-2eb3-4024-b21c-1c0fd55b7285	743a0243-bca2-4513-8fc0-ccbe974b7ba0	2311-112-2	apartment	\N	132.86	\N	574131.34
f4abd709-af6a-44c2-b951-2f818e147576	d15fb225-6e40-454d-865a-643f3802b5c9	2305-112-1	apartment	\N	109.90	\N	356592.00
a0cbd208-96f2-4528-9bd7-f9e542c16cce	fe6aabac-88b3-453a-a524-4c102aac9394	2302-110-1	apartment	\N	45.89	\N	220320.00
32ff877f-6528-42f5-a1b3-b0f9946435c0	fe6aabac-88b3-453a-a524-4c102aac9394	2302-111-2	apartment	\N	84.36	\N	333357.22
df604a3b-19bc-4998-87cf-1d3f6cadce58	fe6aabac-88b3-453a-a524-4c102aac9394	2302-112-3	apartment	\N	143.85	\N	580813.02
ca5d2b6f-647d-4272-8dc7-efabef3d5b5c	fe6aabac-88b3-453a-a524-4c102aac9394	2302-164-4	penthouse	\N	183.76	\N	1882725.79
fe10a4aa-cf3c-49c3-9558-f63991f6b245	50ae25fd-9b34-43ac-8822-04a8271c32fa	2299-111-1	apartment	\N	81.36	\N	319790.94
22196226-6f40-4a85-9e48-b615c2e305b7	50ae25fd-9b34-43ac-8822-04a8271c32fa	2299-112-2	apartment	\N	194.97	\N	453990.58
59d6e3e2-86fb-41ad-9baa-d2755f97bc82	fd3805de-ae77-4634-aadc-3650faf6c8df	2279-110-1	apartment	\N	42.46	\N	196656.00
76b9cad0-3a9e-460f-b310-be1001151875	fd3805de-ae77-4634-aadc-3650faf6c8df	2279-111-2	apartment	\N	123.10	\N	312800.00
bcef7951-ee92-4a1e-85d2-d2dbd4ffe6d2	fd3805de-ae77-4634-aadc-3650faf6c8df	2279-112-3	apartment	\N	158.86	\N	508990.06
bda45a39-897d-4b9e-890c-c1a38a78bb26	7bd8165a-6553-4855-ab9d-f0ca52edd4fd	2265-111-1	apartment	\N	90.71	\N	405552.00
c0ed6116-2fc8-45cf-9cc7-2ef3b55a3fdd	7bd8165a-6553-4855-ab9d-f0ca52edd4fd	2265-112-2	apartment	\N	185.04	\N	481440.00
931b9909-5561-4365-951d-a89939a24af1	7bd8165a-6553-4855-ab9d-f0ca52edd4fd	2265-113-3	apartment	\N	159.93	\N	632400.00
4e6786a7-6a1e-4ffb-be9c-a8a9984ad996	96a26791-bf02-4fc2-a887-a7deb049d901	2264-164-1	penthouse	\N	86.60	\N	784548.10
7c6814c1-2505-446e-8f86-53f811b3fbca	398d1e5c-70aa-440e-8e24-5db9a775e2a5	2259-110-1	apartment	\N	40.00	\N	340000.00
a057072b-129c-44e8-bd87-c29940e98573	398d1e5c-70aa-440e-8e24-5db9a775e2a5	2259-111-2	apartment	\N	116.52	\N	591600.00
7239fd2b-70ab-4e31-a4bb-2ac256cd5281	16b59005-a531-4ba8-883f-c4519ce0d325	2253-112-1	apartment	\N	130.44	\N	437335.20
ebe779bb-533b-4cea-9d3e-a490bc565748	16b59005-a531-4ba8-883f-c4519ce0d325	2253-164-2	penthouse	\N	289.11	\N	850788.80
1ed7696b-50b5-4043-ac1f-80995ab03010	2c072724-a42c-46fd-8b7f-e46394fd9b65	2251-111-1	apartment	\N	92.53	\N	695232.00
4f8978b8-2084-43e1-a9ff-d9e79952582e	2c072724-a42c-46fd-8b7f-e46394fd9b65	2251-112-2	apartment	\N	203.74	\N	1234608.00
c4f2101f-5aed-4115-bb31-bca3ba937074	2c072724-a42c-46fd-8b7f-e46394fd9b65	2251-113-3	apartment	\N	260.59	\N	2131392.00
53cbab17-e6ea-46de-a2c2-8e2bc8b79040	2c072724-a42c-46fd-8b7f-e46394fd9b65	2251-114-4	penthouse	\N	361.49	\N	4136576.00
b08f25f5-cf3e-4e21-b8f6-edbf92d1078c	451430d2-0ce5-4ce4-9005-f32933e66803	2245-111-1	apartment	\N	120.08	\N	303924.37
a257e9ba-8d0b-4a5c-a848-83687c7b370b	451430d2-0ce5-4ce4-9005-f32933e66803	2245-112-2	apartment	\N	77.76	\N	377364.37
af3e12d7-b1d4-4f67-b0f5-398805b6b30f	ba10157c-80eb-4978-ae0d-7d24c5a4f10f	2243-111-1	apartment	\N	107.14	\N	517648.10
4bf0c8bf-be5a-4571-b897-e7cdd3bedcb4	ba10157c-80eb-4978-ae0d-7d24c5a4f10f	2243-112-2	apartment	\N	191.62	\N	969479.81
2593c6c4-8d73-48f0-9924-e19b4c5b5632	ba10157c-80eb-4978-ae0d-7d24c5a4f10f	2243-113-3	apartment	\N	182.89	\N	1081302.00
8479050c-48c7-400f-9546-07b4c91b05f3	499083c3-e576-4225-9a2b-af341e6e731c	2241-110-1	apartment	\N	42.91	\N	409223.73
db9ff00c-0e71-4ad1-b417-6f66c17cd9e2	499083c3-e576-4225-9a2b-af341e6e731c	2241-111-2	apartment	\N	115.20	\N	589559.73
a8ba6bb2-fb21-4814-b95d-c5a4ffb799f5	499083c3-e576-4225-9a2b-af341e6e731c	2241-112-3	apartment	\N	148.48	\N	1040399.73
cad7b09a-b298-4637-bedf-03dae5720a5d	1d4f941e-0175-4034-a93a-670a4e8baef1	2240-111-1	apartment	\N	84.74	\N	728192.96
20319fd0-ef43-44c7-859c-02274fa9ebc5	1d4f941e-0175-4034-a93a-670a4e8baef1	2240-112-2	apartment	\N	145.89	\N	1001317.14
763a5e44-2f40-432f-a60d-138f1ee80a28	1d4f941e-0175-4034-a93a-670a4e8baef1	2240-113-3	apartment	\N	239.28	\N	1327502.53
50e239d9-0f68-402c-8c44-976a8002d2a4	1d4f941e-0175-4034-a93a-670a4e8baef1	2240-114-4	penthouse	\N	276.26	\N	2329289.95
c1feb2dd-3108-4657-ad5b-6e8b9b22dd59	58f9eff9-4cf4-4948-8cb2-11033f7e5cb9	2237-110-1	apartment	\N	62.52	\N	372560.85
e1d6e774-a9cb-404b-8130-49828311fd4e	58f9eff9-4cf4-4948-8cb2-11033f7e5cb9	2237-111-2	apartment	\N	90.49	\N	495248.35
5ef444f2-af8c-441e-801e-c14868c957d0	58f9eff9-4cf4-4948-8cb2-11033f7e5cb9	2237-112-3	apartment	\N	117.24	\N	767437.39
c41ade27-64d6-4764-9307-68bb11a295f6	f7146bca-b3a5-4608-ad4c-fdbf079472ca	2230-111-1	apartment	\N	78.97	\N	471920.00
b0f6a7cd-ef2b-4aef-b810-9a27de2d5ff5	f7146bca-b3a5-4608-ad4c-fdbf079472ca	2230-112-2	apartment	\N	89.09	\N	557600.00
0dffb0fb-4544-47c1-a8ff-a61ef4b621fb	f0455cdf-f2d8-49d0-8cba-3f25063c36b4	2228-111-1	apartment	\N	106.56	\N	383656.00
70dd804c-073d-411d-b842-5779e589f971	b2ae5271-54f6-4f22-ba31-84c9a688b36f	2222-114-1	penthouse	\N	614.15	\N	4655973.06
1d637092-75a1-4bd5-a82a-46c9800df3d7	64a1c03c-fa25-4fac-97cf-7cff99ce2665	2221-111-1	apartment	\N	93.74	\N	684803.79
d055f962-c967-4dc0-960b-3f00ced46aac	64a1c03c-fa25-4fac-97cf-7cff99ce2665	2221-112-2	apartment	\N	142.85	\N	1044108.45
fcbdb2b7-06c3-4827-87f8-01a929e1a1f9	64a1c03c-fa25-4fac-97cf-7cff99ce2665	2221-113-3	apartment	\N	160.80	\N	1245235.58
e7f5e286-a08a-428b-b908-31901a6ca49b	447f6d4e-1439-4f55-8658-f4bd285df6c3	2211-110-1	apartment	\N	62.57	\N	295120.00
f6c6c6be-17c4-4dab-8bf1-48eb3fd16018	447f6d4e-1439-4f55-8658-f4bd285df6c3	2211-111-2	apartment	\N	83.42	\N	385968.00
200c4eb7-cf32-4ad9-9c13-925288d988a0	447f6d4e-1439-4f55-8658-f4bd285df6c3	2211-112-3	apartment	\N	100.01	\N	493136.00
0345c73b-d0a7-4706-ab4a-2f34e53f096e	447f6d4e-1439-4f55-8658-f4bd285df6c3	2211-113-4	apartment	\N	208.82	\N	877472.00
ab04cef5-0e5e-4c06-ac35-a834c94615cb	52a67992-8b84-427d-b394-85f3ad2bfac1	2205-113-1	apartment	\N	158.03	\N	1064305.54
4efb87bd-ddd2-4a03-8c0b-cc685b2eafef	1259d9b0-e69a-4b92-b138-59ef7cec49d5	2195-112-1	apartment	\N	122.49	\N	527269.01
d567efd6-76a6-4c3a-93c8-9637749834d5	1259d9b0-e69a-4b92-b138-59ef7cec49d5	2195-114-2	penthouse	\N	305.58	\N	2277220.72
05c172c6-17bd-4cd4-9fb9-4b288c27bd08	4abf936c-a335-46bd-afe3-8b5b3d679ba0	2194-110-1	apartment	\N	101.36	\N	372096.00
d20ecbf9-3819-4b2a-875b-f1c516b4d3c3	4abf936c-a335-46bd-afe3-8b5b3d679ba0	2194-111-2	apartment	\N	181.63	\N	472160.99
ba50ba8d-dc8f-4d51-8fc7-1f9250ff8e7c	4abf936c-a335-46bd-afe3-8b5b3d679ba0	2194-112-3	apartment	\N	112.41	\N	834768.00
84f55e79-0add-420b-be26-69b0c957c673	700f4bb9-8301-4834-b84b-4c943d1e2621	2187-111-1	apartment	\N	194.92	\N	2002696.56
74cf3458-b5e8-4d0a-a58d-66c4a057a75a	700f4bb9-8301-4834-b84b-4c943d1e2621	2187-112-2	apartment	\N	219.05	\N	1893418.93
63dfe257-7330-4e4c-a3f6-5655c0d49f50	700f4bb9-8301-4834-b84b-4c943d1e2621	2187-113-3	apartment	\N	428.71	\N	3791665.58
f2b0dfe4-eec9-4d65-9177-d819837e4784	700f4bb9-8301-4834-b84b-4c943d1e2621	2187-114-4	penthouse	\N	404.60	\N	3293612.10
9f28ac61-3637-4166-a78f-92eb9af807c4	6e838a95-21ee-4bf3-9ca7-5970e79e811b	2184-111-1	apartment	\N	87.17	\N	267087.68
19d24560-9831-4534-a9b5-da65e2fd22d8	6e838a95-21ee-4bf3-9ca7-5970e79e811b	2184-112-2	apartment	\N	122.52	\N	449395.41
28a6aef4-8e09-4e09-b07d-d58bc88bac7a	dd5c3c23-3401-4e8d-afa3-751ae637a793	2182-110-1	apartment	\N	66.90	\N	228785.18
da6e285f-fe9e-4773-a8dd-a4d25ebe249a	dd5c3c23-3401-4e8d-afa3-751ae637a793	2182-111-2	apartment	\N	126.26	\N	319212.67
3a19deea-68cf-44ca-bd2d-caef05468a94	dd5c3c23-3401-4e8d-afa3-751ae637a793	2182-112-3	apartment	\N	184.67	\N	718554.91
d58c31ba-56b8-4198-9938-32c11c086907	4b1b1899-2930-4f1c-b9bc-2dc4c54d875f	2175-112-1	apartment	\N	166.94	\N	662048.00
1450a8ca-3997-4c5d-ab3b-88660493d1c0	27116770-c909-47d6-affa-42c0bebc735f	2173-111-1	apartment	\N	113.34	\N	607376.00
ea8cab44-6858-4653-9511-e6f6d7e16b02	27116770-c909-47d6-affa-42c0bebc735f	2173-112-2	apartment	\N	141.03	\N	907936.00
aa538138-87ba-4d46-957c-ea168d2b7e63	8d8b9472-9bcb-4d37-b800-6ed21ef6d9c2	2172-111-1	apartment	\N	77.76	\N	802400.00
2445063d-fa95-4f64-a8d8-0232928aa00b	53f0d6f6-7c5f-46bd-b9dd-586c34e5d5aa	2170-111-1	apartment	\N	73.67	\N	680000.00
eca86f24-00fc-4e73-b556-59a743bb2036	03449b24-2730-41b5-a97b-ac36da40648c	2164-114-1	penthouse	\N	935.02	\N	2815472.00
8669f1f0-2484-403a-be67-c8dc67dd957d	03449b24-2730-41b5-a97b-ac36da40648c	2164-115-2	penthouse	\N	1310.16	\N	34268572.80
90bc29d6-dbf4-4cef-bd13-24670c58887d	3d9f75e5-c837-420f-b3d1-bc951d5657fc	2160-111-1	apartment	\N	121.13	\N	438833.92
6b3937e5-e86c-4ba9-8d5c-9d59738584d2	6aeca256-2aaf-4ed1-8cc7-b494281a4cb6	2156-110-1	apartment	\N	55.92	\N	235108.37
777d3b15-e3f7-4cf4-8404-7081f18513b7	6aeca256-2aaf-4ed1-8cc7-b494281a4cb6	2156-111-2	apartment	\N	125.58	\N	279117.42
8fc646b9-1871-40a6-af71-8dfa37f7107c	6aeca256-2aaf-4ed1-8cc7-b494281a4cb6	2156-112-3	apartment	\N	165.58	\N	660959.73
ac051aa8-05a9-4c54-a37a-0b0bd5999239	221d8284-9b51-4169-bde9-da6f574288a0	2125-111-1	apartment	\N	76.46	\N	261664.00
61db72bd-2116-4065-8c4d-344ac6c55e99	221d8284-9b51-4169-bde9-da6f574288a0	2125-112-2	apartment	\N	99.13	\N	427040.00
3046e260-67e6-400f-a631-e834428a4d8f	f5f66a0a-ecd1-487d-8903-6b5b15a1ef42	2121-110-1	apartment	\N	45.34	\N	441728.00
42b6e758-88ff-43e3-9007-44f36bced980	f5f66a0a-ecd1-487d-8903-6b5b15a1ef42	2121-111-2	apartment	\N	76.18	\N	708832.00
85bb4a79-590b-434a-9c27-8474c7567410	f5f66a0a-ecd1-487d-8903-6b5b15a1ef42	2121-112-3	apartment	\N	115.94	\N	1083920.00
66a0d624-eb5f-499f-b112-b365b3d1191e	f5f66a0a-ecd1-487d-8903-6b5b15a1ef42	2121-164-4	penthouse	\N	28.27	\N	380800.00
124b1897-135b-421b-b536-90d2d6b61bbf	c2e29ef4-04da-4baa-98d5-de67147a84ef	2119-111-1	apartment	\N	69.92	\N	514080.00
d3b2b56f-0d1a-474a-b653-16d10e1cfd78	c2e29ef4-04da-4baa-98d5-de67147a84ef	2119-112-2	apartment	\N	102.87	\N	714000.00
f4ea293b-8cf8-4ed1-a77e-8fa9d7c49f89	c2e29ef4-04da-4baa-98d5-de67147a84ef	2119-113-3	apartment	\N	141.12	\N	992800.00
eb95161a-d869-484f-9079-e9099fe8a872	c2e29ef4-04da-4baa-98d5-de67147a84ef	2119-114-4	penthouse	\N	183.27	\N	1292000.00
2f5f067c-04b3-4161-a274-a42b0ecd8f34	427a88c1-805a-49dc-9ecb-f7293f159a5d	2114-113-1	apartment	\N	168.15	\N	1181265.54
c5518e69-bc77-4e66-88d6-c119a0841765	21f070d3-6012-44c2-8296-fa26afe87299	2113-111-1	apartment	\N	123.40	\N	497760.00
d3a0ec46-e659-4590-b7f1-10763efe7f72	21f070d3-6012-44c2-8296-fa26afe87299	2113-112-2	apartment	\N	313.18	\N	756160.00
3036469a-a648-4077-acdc-22514fee007a	00e3e3f3-ed20-4912-b855-a409c45fbfc3	2102-111-1	apartment	\N	98.09	\N	284494.32
a0034a80-8299-4378-a831-dd1aa73d11aa	dd5b2fc1-2d53-4d7f-8fb7-2d6332f274b9	2100-114-1	penthouse	\N	747.12	\N	19948318.98
e7ae159c-eef4-4a7b-bb74-3a2a9b8194f4	dd5b2fc1-2d53-4d7f-8fb7-2d6332f274b9	2100-115-2	penthouse	\N	934.99	\N	22021125.98
e2f96281-6e31-487b-aadc-61d32c9df7ce	c8d2c053-e9cc-4cd0-b6a6-8a9e6fc3c14c	2099-110-1	apartment	\N	36.88	\N	272000.00
c6610a8b-db33-4b0c-977f-99ef15bfbb3f	5f41a46a-7770-4e86-9802-16d549a09f0d	2088-112-1	apartment	\N	109.90	\N	356864.00
a09fd19d-927b-430e-bc78-2f3a3139f86a	14b4a9a4-7389-4209-b5ff-d5fc94ca5203	2084-111-1	apartment	\N	1216.00	\N	829600.00
89017eb4-68bb-4107-8002-573b6f6e44d6	14b4a9a4-7389-4209-b5ff-d5fc94ca5203	2084-112-2	apartment	\N	156.91	\N	1224000.00
4431400c-d25a-4478-871f-04c5665618ac	2bea7d8b-dae2-4c83-8b78-2f213e334b0b	2067-111-1	apartment	\N	104.79	\N	311168.00
a2863703-25ce-43f2-b9fa-e529a0604df6	2cd98180-0630-4747-934f-c52b91c16c34	2048-112-1	apartment	\N	96.98	\N	369376.00
765b4b49-d829-4cb2-8b42-678cfa96d948	e07a2535-76e2-46d9-82a5-f096216ba859	2047-110-1	apartment	\N	48.12	\N	254579.22
4c85ed74-3a36-4327-824c-09469d4e4d5b	e07a2535-76e2-46d9-82a5-f096216ba859	2047-111-2	apartment	\N	83.24	\N	351859.20
a5b62db0-0bc8-457f-8afc-e3b3d70cf5e3	e07a2535-76e2-46d9-82a5-f096216ba859	2047-112-3	apartment	\N	159.33	\N	490207.10
04ef13e4-7ad0-4e55-9516-1b046ad4c424	e07a2535-76e2-46d9-82a5-f096216ba859	2047-113-4	apartment	\N	157.75	\N	757542.85
253cffab-c611-4c94-929e-248a23fecac7	1f4c75a4-ad98-40ff-aff6-ce6b83f4fb70	2045-111-1	apartment	\N	127.99	\N	358165.79
0bc2abc2-369b-49cc-ba40-c1b098b18fd8	1a9fe80c-6f29-4375-baed-aad427bba73a	2032-112-1	apartment	\N	226.91	\N	701760.00
8c1c96ce-921e-4b4a-9252-ead380ec3c14	1a9fe80c-6f29-4375-baed-aad427bba73a	2032-113-2	apartment	\N	191.13	\N	1047200.00
5a17a56b-8ab9-4bf5-a2db-e47633ccf663	1a9fe80c-6f29-4375-baed-aad427bba73a	2032-164-3	penthouse	\N	64.72	\N	758064.00
1956ef88-6250-49dc-9723-d74175839d3e	1395be26-55c0-4ac2-b33f-15a094116e4d	2031-112-1	apartment	\N	458.94	\N	3420729.66
203c005b-273c-4858-967a-48961f2c62fd	1395be26-55c0-4ac2-b33f-15a094116e4d	2031-113-2	apartment	\N	749.54	\N	5090589.89
c1677502-777e-4410-8183-71a33d16c1f3	1395be26-55c0-4ac2-b33f-15a094116e4d	2031-114-3	penthouse	\N	1424.48	\N	13237380.75
d6222578-7b8a-46d7-aaf2-b46b1948d3e2	6f2117f3-4299-47e4-8831-5a62e5c9b2d1	2025-111-1	apartment	\N	75.32	\N	320960.00
4dc47ca7-c7a7-4fae-b589-c9e135434787	6f2117f3-4299-47e4-8831-5a62e5c9b2d1	2025-164-2	penthouse	\N	391.20	\N	2795099.74
73eec892-9678-4e36-80d1-a748eb8681bd	785b6bec-6266-486f-a23c-59b27bb3487d	2020-113-1	apartment	\N	132.39	\N	564400.00
aaa7233d-d9c1-4385-98f5-5b0538c18eb4	2b705d9c-5fe9-459b-adad-a62574dccdd0	1953-110-1	apartment	\N	50.82	\N	202368.00
d958af1f-9330-4661-94d9-002dcc96964d	2b705d9c-5fe9-459b-adad-a62574dccdd0	1953-111-2	apartment	\N	95.23	\N	303824.00
7d1b59dd-9267-4346-9f61-d7fbde81cf33	2b705d9c-5fe9-459b-adad-a62574dccdd0	1953-112-3	apartment	\N	114.09	\N	422688.00
b37c85cb-d339-43ad-91ac-99174dc29a56	2b705d9c-5fe9-459b-adad-a62574dccdd0	1953-113-4	apartment	\N	140.19	\N	549440.00
2344995f-2218-40a5-8d83-27f6d3ebcbd3	2b705d9c-5fe9-459b-adad-a62574dccdd0	1953-164-5	penthouse	\N	334.10	\N	603237.79
94fe6155-5772-4516-bafa-72ac7290add7	d6e15b10-cb7e-4bbd-9df4-c60e05cf4679	1952-112-1	apartment	\N	122.45	\N	402496.62
b251442f-6bec-414d-8c41-7e83ed59a811	d6e15b10-cb7e-4bbd-9df4-c60e05cf4679	1952-113-2	apartment	\N	273.69	\N	603845.44
d20ba8fb-cf90-4518-8128-ceba42da3fc2	5d8b1ae3-3780-45d1-af97-04a2bfa4748a	1950-114-1	penthouse	\N	398.78	\N	3400000.00
d0d665aa-292e-45c0-8040-335de38f36e9	d23aa050-f9bc-4cf8-b12d-171f95e697e3	1947-111-1	apartment	\N	83.71	\N	345029.55
7cca288f-4e37-4647-819c-86c04e82efe0	d23aa050-f9bc-4cf8-b12d-171f95e697e3	1947-112-2	apartment	\N	129.79	\N	476647.36
4b29dd23-c891-463e-a0c9-351e64958580	d23aa050-f9bc-4cf8-b12d-171f95e697e3	1947-113-3	apartment	\N	214.42	\N	732694.29
eb9dc74d-07bb-468b-b250-519b9322d00a	74f11e0f-2589-4361-a5e8-d3898f2e3842	1946-110-1	apartment	\N	39.67	\N	188223.73
ae906717-445a-4c6d-8fcf-fc336de64ea2	74f11e0f-2589-4361-a5e8-d3898f2e3842	1946-111-2	apartment	\N	79.53	\N	304639.73
66065659-fa90-47c4-b2e4-59a5e0971232	74f11e0f-2589-4361-a5e8-d3898f2e3842	1946-112-3	apartment	\N	121.98	\N	433839.73
0e58a1de-145a-45a1-a693-658a9f76afa0	74f11e0f-2589-4361-a5e8-d3898f2e3842	1946-113-4	apartment	\N	187.57	\N	618799.73
b129d64f-6853-4a5d-9b73-9db9a9a028e4	08f32391-146d-4ad2-b7ef-a4076754a032	1938-112-1	apartment	\N	147.90	\N	4705600.00
a9d826d7-d19f-4025-b1ed-03108cda84e5	08f32391-146d-4ad2-b7ef-a4076754a032	1938-113-2	apartment	\N	492.39	\N	7915200.00
a693feee-f916-4970-82de-7ebbb5a63b21	08f32391-146d-4ad2-b7ef-a4076754a032	1938-114-3	penthouse	\N	1393.55	\N	16864000.00
ec7bdd5c-13ea-41e1-a49a-2fdef5bfa877	6e88156c-b2a3-40c8-b00d-50d3ccb57ef3	1937-112-1	apartment	\N	137.96	\N	488784.00
674622e7-c557-4d10-b8c2-4d7fd0e1e04d	9819f75e-a921-42d8-8220-7a3199d39282	1936-113-1	apartment	\N	678.19	\N	10744000.00
030aec90-0e68-47f7-a10a-debb0f252cd9	9819f75e-a921-42d8-8220-7a3199d39282	1936-114-2	penthouse	\N	859.35	\N	13872000.00
dabc32a8-026f-43d5-a07b-18d3a3b30928	9819f75e-a921-42d8-8220-7a3199d39282	1936-115-3	penthouse	\N	975.48	\N	21760000.00
835ac19b-a9a4-4a32-8ea0-208276f30f3d	089ae4fa-2d7b-4e78-8103-f8b76e35675f	1935-113-1	apartment	\N	235.14	\N	2420800.00
f5cd6ede-7318-4f45-bbca-2d8a6b9afc08	089ae4fa-2d7b-4e78-8103-f8b76e35675f	1935-114-2	penthouse	\N	426.50	\N	3128000.00
524c6dfe-768f-4816-a660-d255bcb2d142	40d7d56b-b5b9-4e8f-8257-e683ffc0281d	1920-110-1	apartment	\N	37.17	\N	326400.00
6f73df1a-c181-4b50-b61a-b0193194a51e	40d7d56b-b5b9-4e8f-8257-e683ffc0281d	1920-111-2	apartment	\N	96.94	\N	576640.00
c20eb853-6509-4758-b634-f1788ce9ee20	40d7d56b-b5b9-4e8f-8257-e683ffc0281d	1920-112-3	apartment	\N	164.71	\N	821168.00
02ab40a8-46d4-4987-81d2-28f23fc697c0	40d7d56b-b5b9-4e8f-8257-e683ffc0281d	1920-113-4	apartment	\N	291.87	\N	4350096.00
c18854c0-8b00-458c-9e47-53fb26f2faee	25bfa7c7-a680-48dc-9e55-7676be0705ba	1916-111-1	apartment	\N	107.02	\N	280704.00
4a91e2d0-755d-4146-ab2e-2c1c682df383	25bfa7c7-a680-48dc-9e55-7676be0705ba	1916-112-2	apartment	\N	127.74	\N	385968.00
6a64f20a-1655-43fb-abc6-ebf81aadf9be	c7b63b0a-d1f6-4508-94e3-0ab73888d0d4	1910-111-1	apartment	\N	57.60	\N	197441.54
19d7aa5f-380b-4a62-a7db-b50fa621f9ae	c7b63b0a-d1f6-4508-94e3-0ab73888d0d4	1910-112-2	apartment	\N	94.58	\N	291281.54
6d3368f6-cbc1-4324-8b2a-f969739a5bef	fbc8877a-5e32-447a-9994-6d811684cbe3	1907-111-1	apartment	\N	84.82	\N	481440.00
990d6a31-2ba7-4fc6-b7d6-6d9d20512213	4d3351e1-b366-4a7c-8c48-2bcf11d69c64	1905-110-1	apartment	\N	36.14	\N	208351.46
d3edec4a-3d63-484c-9f1d-834359d162a5	5eef52ac-c863-4097-8fd0-3daf9dce928a	1904-111-1	apartment	\N	101.06	\N	356053.17
bd258788-f7a8-490f-b836-587bfa983d21	5eef52ac-c863-4097-8fd0-3daf9dce928a	1904-112-2	apartment	\N	192.46	\N	544000.00
ccbab906-b596-435f-ae7f-9d370071c0cb	0cd91901-3da6-44d7-b79a-34b335c2e667	1901-111-1	apartment	\N	77.26	\N	308949.57
3274d610-6a09-4bda-a768-4b72082972db	147e02ad-5a54-4dc6-9160-b582069cd05c	1897-164-1	penthouse	\N	102.89	\N	622608.00
f2a45239-8e6b-493e-9e03-5cef754c5ebb	60f7594e-c5cf-40ac-986b-d652b639d5fd	1890-110-1	apartment	\N	38.65	\N	356536.78
1e75204c-32e0-4556-9a07-d1a198327679	60f7594e-c5cf-40ac-986b-d652b639d5fd	1890-111-2	apartment	\N	71.54	\N	586115.12
2521df9f-2ec0-4ffd-b936-30cf13a88507	60f7594e-c5cf-40ac-986b-d652b639d5fd	1890-112-3	apartment	\N	98.29	\N	668557.50
364a170b-b209-4750-a7b9-e92e57ba15a4	70954d3b-b3ff-4549-9728-1cdca4e6eaf5	1887-111-1	apartment	\N	86.00	\N	481060.02
55bb5b6c-984b-4c46-baa7-2fe0a96937bf	70954d3b-b3ff-4549-9728-1cdca4e6eaf5	1887-112-2	apartment	\N	116.27	\N	548338.40
815b077c-9709-47cd-aef1-ca6bd5befbcf	563af705-9eaa-415d-bed1-9d2f8d8617da	1861-111-1	apartment	\N	75.00	\N	693600.00
a99ecee9-43bd-4899-86d3-295466008366	26bcf858-d9b7-4eda-bbf5-d4bf86d676bc	1856-164-1	penthouse	\N	149.67	\N	896240.00
daf08d64-a2c2-43e8-87d2-85c93622da1c	58932c6f-4db4-46d1-8338-6a8e82198bef	1849-110-1	apartment	\N	70.05	\N	184960.00
336d4197-50de-4377-bad1-89bdffa3d5d8	58932c6f-4db4-46d1-8338-6a8e82198bef	1849-111-2	apartment	\N	112.31	\N	265744.00
6d1d410f-47da-4514-8895-6c8087d0ec68	58932c6f-4db4-46d1-8338-6a8e82198bef	1849-112-3	apartment	\N	210.15	\N	402288.00
6c39d146-5056-404e-a8c3-f82c7973cc5a	58932c6f-4db4-46d1-8338-6a8e82198bef	1849-113-4	apartment	\N	343.97	\N	502928.00
5e3d7821-6afe-49c4-bde5-4b8e6e05b5a3	d776f032-ec3e-4fdf-9e1c-2f4a37c8679e	1848-110-1	apartment	\N	49.33	\N	259039.20
c01dab43-4e65-46db-b761-ea53e7e4b05c	d776f032-ec3e-4fdf-9e1c-2f4a37c8679e	1848-111-2	apartment	\N	82.50	\N	305020.80
5c41c7cb-a1c9-44e1-831e-d7f72e942db3	d776f032-ec3e-4fdf-9e1c-2f4a37c8679e	1848-112-3	apartment	\N	142.98	\N	484663.20
9a141a7e-2743-4bf4-9865-78c8a8f7e945	d776f032-ec3e-4fdf-9e1c-2f4a37c8679e	1848-113-4	apartment	\N	203.92	\N	656880.00
2fe3132c-c7af-4dd7-b1cd-cd352f84a8a4	8f4789d5-ebe1-464d-a311-8cc00ae1eda5	1845-111-1	apartment	\N	79.31	\N	287254.03
7a4cfab7-fb6d-4327-9797-c2d3751ee334	8f4789d5-ebe1-464d-a311-8cc00ae1eda5	1845-112-2	apartment	\N	94.68	\N	526465.79
dc765d5b-6c1e-43f2-8491-7e8ac0281ce3	8f4789d5-ebe1-464d-a311-8cc00ae1eda5	1845-113-3	apartment	\N	148.38	\N	868029.25
fa445330-6582-4940-a943-fbd486808d03	0b6a33f8-5010-4ce3-bafa-480e36b4d0c6	1843-111-1	apartment	\N	175.12	\N	2388704.00
a1b5ac1c-682c-420a-b3c8-e17c4a11748d	0b6a33f8-5010-4ce3-bafa-480e36b4d0c6	1843-112-2	apartment	\N	289.21	\N	4088160.00
5c7a9510-432c-42a4-b675-14db56d12470	0b6a33f8-5010-4ce3-bafa-480e36b4d0c6	1843-113-3	apartment	\N	188.87	\N	9672864.00
52fe321e-016b-474d-acc3-e622a9f92f46	3cf7afad-5c8b-44dd-aaf5-a3c2f3a41132	1840-112-1	apartment	\N	180.72	\N	485108.74
be2f5843-349f-4e79-9fbd-11f449e79189	aa2b837d-12e4-4ef3-b590-fe92efd22481	1829-111-1	apartment	\N	70.14	\N	263840.00
4fbb4a51-0fb3-4190-af4e-2a9e41189f04	681e8095-e0f8-4539-8044-8df558eac3a0	1818-111-1	apartment	\N	61.00	\N	217600.00
ac6a594f-6bbd-4717-8447-d378a044377b	3150263e-776b-4bab-a20c-ec5d247f36ea	1807-112-1	apartment	\N	213.12	\N	3061995.39
342154ee-4c94-4311-b497-762a352b9da2	3150263e-776b-4bab-a20c-ec5d247f36ea	1807-113-2	apartment	\N	311.97	\N	4136770.48
fc0f206f-a852-4e01-abaa-371c4920c2ea	7a193ee8-e26b-4767-bb3f-12f8397f49aa	1795-112-1	apartment	\N	119.75	\N	869825.54
2577726d-1752-4024-a6a9-ec0333fb6c99	ba099c63-96c4-4588-ab6e-175b6acca7dd	1789-111-1	apartment	\N	85.20	\N	306034.82
9509110f-6515-4e69-9616-9b7c46144a87	ba099c63-96c4-4588-ab6e-175b6acca7dd	1789-112-2	apartment	\N	85.71	\N	439945.58
3fcb9e53-bbff-438f-91a9-f1ce9e66b598	0c57ab09-4704-4f8e-b746-77eead1ce456	1783-110-1	apartment	\N	34.71	\N	326400.00
6332435d-4031-4273-bdaa-2c6a86e0f0e7	0c57ab09-4704-4f8e-b746-77eead1ce456	1783-111-2	apartment	\N	753.00	\N	576640.00
91119754-6aea-4487-8732-3a95a9268d09	0c57ab09-4704-4f8e-b746-77eead1ce456	1783-112-3	apartment	\N	118.57	\N	789888.00
f9b567fd-c5a8-487d-ae9d-3b12c4868420	0c57ab09-4704-4f8e-b746-77eead1ce456	1783-113-4	apartment	\N	138.61	\N	1253376.00
2558c41b-96f4-4184-b282-ab613966d89e	3ed4c923-2a62-4abe-970e-5617204f7e15	1769-110-1	apartment	\N	41.40	\N	171360.00
342668a8-d511-4add-beff-62b185a13109	b2aaebdd-b9bb-46c5-adef-7c2cb2dfba0a	1763-111-1	apartment	\N	56.21	\N	272000.00
b19937a8-a4bf-41fe-beb8-5feb99bb3e4e	b2aaebdd-b9bb-46c5-adef-7c2cb2dfba0a	1763-112-2	apartment	\N	95.78	\N	394400.00
998c3ae8-a2c0-4d3a-a888-e5e69a3918c3	652d6ef4-dd3e-45d6-8f72-bef2bcf8c2c3	1743-114-1	penthouse	\N	253.19	\N	2638400.00
ff16efc9-348f-48f0-b45c-bd850acbee73	652d6ef4-dd3e-45d6-8f72-bef2bcf8c2c3	1743-115-2	penthouse	\N	376.08	\N	5140800.00
8c50caea-bbd3-4e39-a1ef-48b616b122ae	0d392a00-ab5d-4191-8a27-55cc683d535b	1741-111-1	apartment	\N	933.00	\N	734897.22
9eb78ca4-7f82-4722-8be2-3177243ee1ef	0d392a00-ab5d-4191-8a27-55cc683d535b	1741-112-2	apartment	\N	156.12	\N	962561.22
17d8d0bd-cb93-4969-b66b-6a9ec9570553	0d392a00-ab5d-4191-8a27-55cc683d535b	1741-113-3	apartment	\N	240.58	\N	1707025.22
73d0ad5e-f252-44bc-858c-aeb7477c5440	937d2653-8834-4410-869e-9955cf88bd27	1735-111-1	apartment	\N	108.98	\N	798418.74
57461924-c5a5-4129-aa84-0b32367e3583	937d2653-8834-4410-869e-9955cf88bd27	1735-112-2	apartment	\N	219.61	\N	1208194.35
a015361f-60a2-4dfc-bddc-b376acbeb478	937d2653-8834-4410-869e-9955cf88bd27	1735-114-3	penthouse	\N	257.88	\N	2671265.49
e66b2ec2-9350-40c4-9316-a23ebbb82af5	5ee3e712-5b15-46b8-98a5-818386f38e18	1731-110-1	apartment	\N	49.89	\N	211324.96
17136572-976a-47f5-8b90-9fdabfa271e1	5ee3e712-5b15-46b8-98a5-818386f38e18	1731-111-2	apartment	\N	85.77	\N	337216.90
ba452eb5-f0b2-4882-a7af-019f57001c03	5ee3e712-5b15-46b8-98a5-818386f38e18	1731-112-3	apartment	\N	125.36	\N	468994.64
2d87de08-32c6-42e6-9b7b-404c118f774e	5ee3e712-5b15-46b8-98a5-818386f38e18	1731-113-4	apartment	\N	227.18	\N	1029099.76
bd8a3bef-8d36-47f5-9bf2-efe21cb31d41	f8bd2a87-6e8c-4839-a280-078b9627d834	1725-111-1	apartment	\N	102.87	\N	259751.84
5c350b4a-38de-42d8-acf4-80883aa743db	f955e7f3-bf4c-4f2a-8829-f73d43004e13	1721-112-1	apartment	\N	171.50	\N	2747200.00
b2cfa7a6-2ecc-4c5f-ae50-c523e88ad6fa	f955e7f3-bf4c-4f2a-8829-f73d43004e13	1721-113-2	apartment	\N	322.72	\N	5439999.73
031c043c-ff70-4bfc-99a0-12449d74eaee	f955e7f3-bf4c-4f2a-8829-f73d43004e13	1721-114-3	penthouse	\N	372.12	\N	8160000.00
fa0346b4-750d-4fdf-b85c-91480e91cbcd	7493c5c9-b3f7-4d0c-a002-140d8dafa85c	1719-112-1	apartment	\N	185.99	\N	2856000.00
381baeac-489e-4718-bfcb-0115e632af92	32e1ec4f-5194-40d7-bc8c-1302ab808643	1715-111-1	apartment	\N	65.58	\N	316149.41
24a236b4-9ac0-4088-b42c-43fedd224a0a	32e1ec4f-5194-40d7-bc8c-1302ab808643	1715-112-2	apartment	\N	117.35	\N	449903.23
89a3001f-7345-492f-8e72-366ff1e1eb7f	59119618-cd0f-42b4-9f83-28f0e131fec1	1712-112-1	apartment	\N	135.69	\N	940094.83
f435ced8-55d1-4730-b374-4b441b06d469	283d2b07-fbac-49e2-9fc4-51828612bf79	1709-111-1	apartment	\N	63.08	\N	272000.00
e80d5767-09dd-449b-b8a8-7b7c55021f22	8d6c00ca-d525-47c2-94a1-eb27351af8a5	1708-111-1	apartment	\N	84.16	\N	567468.70
ce9e71b6-295d-42c8-af44-20019a359f4a	8d6c00ca-d525-47c2-94a1-eb27351af8a5	1708-112-2	apartment	\N	182.33	\N	976707.66
cbc5df40-e613-4123-9f6e-247186e7aba9	8d6c00ca-d525-47c2-94a1-eb27351af8a5	1708-113-3	apartment	\N	182.04	\N	2927568.64
f5207881-971e-4958-9c59-f7f9aa396ccd	8d6c00ca-d525-47c2-94a1-eb27351af8a5	1708-114-4	penthouse	\N	229.09	\N	3157453.52
14187a44-f6a5-4ccd-84b2-1f8a7b8ae878	8d6c00ca-d525-47c2-94a1-eb27351af8a5	1708-115-5	penthouse	\N	421.87	\N	6841145.44
df31e2c8-cae0-4889-9e73-601dc154cbb8	9c9e6bb7-dec1-4631-8339-bd44a0a82351	1703-112-1	apartment	\N	358.79	\N	4896000.00
5702b093-dc9c-4586-9dd8-d35c1af7616d	9c9e6bb7-dec1-4631-8339-bd44a0a82351	1703-113-2	apartment	\N	322.84	\N	8160000.00
80c1a291-e632-4ebc-be52-7f2084d0a326	f81179b2-4e92-4d44-94d7-1c2d9b25cf4e	1691-111-1	apartment	\N	91.96	\N	408000.00
00f3956e-6eb2-4cb3-8c99-f8622247fdbd	f81179b2-4e92-4d44-94d7-1c2d9b25cf4e	1691-112-2	apartment	\N	182.49	\N	598400.00
6bd683a2-b669-40c3-9d40-1690880e46f4	10f605dd-5ed2-445d-8e2c-9adffb77696b	1689-111-1	apartment	\N	82.78	\N	299200.00
f496a898-c5de-48aa-822f-80ff2e6db4f3	10f605dd-5ed2-445d-8e2c-9adffb77696b	1689-112-2	apartment	\N	113.87	\N	435200.00
c7fab58f-e7c0-429c-98c3-e2bced0f949b	10f605dd-5ed2-445d-8e2c-9adffb77696b	1689-113-3	apartment	\N	169.10	\N	720800.00
51ece855-62c6-4ffe-b6ea-45db63c2a6c5	618bbd41-1deb-49de-8505-850b09e39d7f	1680-110-1	apartment	\N	37.72	\N	135972.80
64ef2cb2-1fc0-451e-8589-3d937ce7235f	618bbd41-1deb-49de-8505-850b09e39d7f	1680-111-2	apartment	\N	66.62	\N	190372.80
ae708e5d-f913-4466-9503-7a0ad446d421	618bbd41-1deb-49de-8505-850b09e39d7f	1680-112-3	apartment	\N	83.06	\N	312772.80
5d834c01-c519-4ea6-a644-d36ff8293976	27b4cf0c-4687-43ee-a6bd-7825322e6112	1678-111-1	apartment	\N	69.40	\N	257040.00
e49bcd34-5d5e-4d26-93e0-e04afed9d81f	e699656e-e27b-4b2a-bbc6-e8f9db1e03af	1677-113-1	apartment	\N	298.68	\N	5132878.54
1e9a8abf-e8c8-44f5-a08a-8a954c416cfa	fa80c8de-c160-42f1-a677-7878c1f1f3a2	1659-164-1	penthouse	\N	100.24	\N	1770992.00
1c7c29e6-c098-435b-b314-af166960cb71	edcc5aa2-ed73-4ce4-9008-7b18cc02a5b0	1657-111-1	apartment	\N	111.44	\N	762641.22
7a8b0906-c222-45dc-a0bd-72104cb346d4	edcc5aa2-ed73-4ce4-9008-7b18cc02a5b0	1657-112-2	apartment	\N	166.84	\N	953041.22
29f4a629-a17f-408f-b9e3-f257e05bd50c	edcc5aa2-ed73-4ce4-9008-7b18cc02a5b0	1657-114-3	penthouse	\N	518.05	\N	4401185.22
c680e1e1-c3ec-4d83-8420-1aeaf85f40e7	b7811d37-6d67-4bdb-916e-1f7121daf287	1656-111-1	apartment	\N	89.41	\N	281329.33
b77ae0f8-0396-4add-94ba-0702f118b9b1	b7811d37-6d67-4bdb-916e-1f7121daf287	1656-112-2	apartment	\N	115.76	\N	440666.66
79b92185-f545-4934-9908-e7d0aee3daf9	b7811d37-6d67-4bdb-916e-1f7121daf287	1656-113-3	apartment	\N	524.44	\N	1743422.62
ae848090-637f-48eb-9c0d-2971c9655622	a49a5885-c740-4879-bbc0-07239f804e55	1655-111-1	apartment	\N	83.24	\N	464651.07
d96d1203-56e6-46bc-bd33-78009ae18c49	a49a5885-c740-4879-bbc0-07239f804e55	1655-112-2	apartment	\N	130.55	\N	682009.54
bebcdb40-a368-45c6-84cc-9bc18d0bd40a	a49a5885-c740-4879-bbc0-07239f804e55	1655-113-3	apartment	\N	202.34	\N	958507.33
6ceef6bc-00cb-4137-955b-b43b36536e66	a49a5885-c740-4879-bbc0-07239f804e55	1655-114-4	penthouse	\N	257.65	\N	1075612.58
7b3337ef-bea9-4c66-9a46-8ba78d288d4d	0a65a5dd-673e-4714-9dc0-5ecafd5be7dd	1651-111-1	apartment	\N	68.66	\N	340000.00
75518785-0697-4c28-80e2-2850046bfec4	0a65a5dd-673e-4714-9dc0-5ecafd5be7dd	1651-113-2	apartment	\N	134.06	\N	625328.00
96d9b5b9-eea1-499e-8c55-7f4f97e826ae	9d621f5e-f737-4a12-8eac-86ee67a014a4	1650-112-1	apartment	\N	136.34	\N	930194.30
76c004d2-9fce-4b18-a74a-07008c3b5f6c	f017f1c4-c509-4b90-863d-fe04b1cab58c	1644-110-1	apartment	\N	50.90	\N	209075.25
7abc5127-7aa5-47cf-b940-86833dbacbda	f017f1c4-c509-4b90-863d-fe04b1cab58c	1644-111-2	apartment	\N	171.41	\N	203728.00
e810a52c-67c6-44cc-875d-d6cabee6fc82	f017f1c4-c509-4b90-863d-fe04b1cab58c	1644-112-3	apartment	\N	226.81	\N	527377.54
72d1e171-86f5-413b-9c98-df649ebfda56	f017f1c4-c509-4b90-863d-fe04b1cab58c	1644-113-4	apartment	\N	583.43	\N	714543.73
9002ac68-f9fe-4a9b-ac77-76a37f266f6f	636d5723-5653-4f84-92ef-a8ac8db6b274	1618-111-1	apartment	\N	154.68	\N	628864.00
35763336-3729-4cdf-a4e5-9911d53c390d	636d5723-5653-4f84-92ef-a8ac8db6b274	1618-112-2	apartment	\N	302.59	\N	1409504.00
fd9098f6-eb1f-4e50-bb53-8bd0a42e5cc6	636d5723-5653-4f84-92ef-a8ac8db6b274	1618-164-3	penthouse	\N	87.70	\N	1202240.00
4de53694-3eb3-41d6-ac70-3bf8f9a162ab	4cc579ea-c184-444e-bfe0-5ac0ab650b30	1616-111-1	apartment	\N	79.06	\N	768944.00
395d62e2-0299-4fcd-8b71-f8cd35e04b9f	c3d5e555-5597-4c25-90bb-df46f6bff6df	1614-110-1	apartment	\N	52.31	\N	271456.00
2e880afa-5aa5-4005-bc38-809a094c3982	c3d5e555-5597-4c25-90bb-df46f6bff6df	1614-111-2	apartment	\N	83.29	\N	374272.00
add00c5d-275f-4836-8774-402711fd1fc6	c3d5e555-5597-4c25-90bb-df46f6bff6df	1614-112-3	apartment	\N	155.48	\N	587520.00
2d47cc03-ff6a-498d-900e-6af77b7ce3b5	c3d5e555-5597-4c25-90bb-df46f6bff6df	1614-113-4	apartment	\N	174.64	\N	766768.00
6d95bb64-12a6-4f9d-aeb0-3264cc3dee6a	f70e06be-23c1-40bf-bb02-b0679dad2683	1613-110-1	apartment	\N	35.59	\N	183600.00
07fac12d-0098-4831-aab9-8c015965bbba	ae13bea3-6135-42b4-bdc6-0b218138f2a2	1610-112-1	apartment	\N	118.64	\N	456392.34
b3d7a4a7-d24a-4aa8-9df0-0c3bafbe3d0a	ae13bea3-6135-42b4-bdc6-0b218138f2a2	1610-113-2	apartment	\N	140.75	\N	602940.77
8ee2a2ac-e248-4f6f-a8e3-66f3cfd04105	99d6125b-7d03-4fd9-9854-24afc83aac77	1609-113-1	apartment	\N	125.88	\N	733553.54
2f87e19a-7a6f-49e1-a79e-cce806f58fed	397f3ede-2bcc-4d61-9b24-959e00f1e6b8	1607-110-1	apartment	\N	43.94	\N	340000.00
6b302cf7-2ab2-4cfd-b2a7-47d8732ffd04	397f3ede-2bcc-4d61-9b24-959e00f1e6b8	1607-111-2	apartment	\N	60.85	\N	443360.00
e094bed6-1c50-46f7-979c-ede83fc95b2b	aac97762-a5d2-4dd2-91e3-1bdb1cc3043a	1599-111-1	apartment	\N	131.55	\N	220320.00
b39ed6b1-4a03-40fd-bb54-ac2ed666a060	0e47e635-b927-4206-ba40-95fa658dc55b	1596-110-1	apartment	\N	33.35	\N	189040.00
ae4717bb-c680-4c1d-bccb-00e4e0eb45dd	0e47e635-b927-4206-ba40-95fa658dc55b	1596-111-2	apartment	\N	58.00	\N	236640.00
cba6fef1-1d74-406e-86d2-b02808f38cc6	ac4f7993-200f-40fa-b134-1b30f9dd187e	1593-112-1	apartment	\N	184.58	\N	882050.03
e8efedea-b920-4a41-9725-957e469292ba	36466891-925f-495d-bd7e-681ac2a6d6a9	1582-110-1	apartment	\N	41.62	\N	192009.70
fb85deb0-28fa-4aca-9297-3e09b701b6e8	36466891-925f-495d-bd7e-681ac2a6d6a9	1582-111-2	apartment	\N	89.19	\N	270557.86
bad75aae-77b5-4947-843e-0c1ec61d9f42	3150815f-d3c9-46d6-95ab-e9dd0e1b36a7	1578-110-1	apartment	\N	34.37	\N	195380.86
6ffe073c-71e3-4228-92a0-25da901f60e3	3150815f-d3c9-46d6-95ab-e9dd0e1b36a7	1578-111-2	apartment	\N	68.28	\N	249949.50
6a2d90c5-d5e3-4eb5-a0fc-361a5e05ed20	3150815f-d3c9-46d6-95ab-e9dd0e1b36a7	1578-164-3	penthouse	\N	188.22	\N	524453.81
0a273ef2-9657-4f13-a65a-08a2cedb33c8	3df4f198-df26-472f-b45c-031fe9b456c7	1576-111-1	apartment	\N	109.60	\N	337280.00
a7ea4184-636f-4dc7-8419-c38923eb67f9	3df4f198-df26-472f-b45c-031fe9b456c7	1576-112-2	apartment	\N	87.89	\N	734400.00
59b93819-143d-4d0c-9c93-a51665ef5c37	345bc4a0-1071-46f2-8035-a2772d1f9ea9	1575-111-1	apartment	\N	57.00	\N	299200.00
baf8085f-f487-4f1b-8779-193384f5dad3	345bc4a0-1071-46f2-8035-a2772d1f9ea9	1575-112-2	apartment	\N	121.24	\N	476000.00
d06fd50a-98f8-4177-a5b8-adc3767537b1	97f8c4fb-c0b8-4cf3-afba-5a9f237d8b05	1573-110-1	apartment	\N	38.65	\N	168640.00
9365245e-eb0f-45af-a140-45cb3e52d71b	97f8c4fb-c0b8-4cf3-afba-5a9f237d8b05	1573-111-2	apartment	\N	82.31	\N	301104.00
553d9864-2c7a-44f3-957a-9cabc9a4595a	97f8c4fb-c0b8-4cf3-afba-5a9f237d8b05	1573-112-3	apartment	\N	174.47	\N	461584.00
17e67f79-31d1-4a9c-bc40-116ebb2b7bfa	97f8c4fb-c0b8-4cf3-afba-5a9f237d8b05	1573-113-4	apartment	\N	261.71	\N	734400.00
cf1f74d7-0e12-492d-bf61-21dc0ed4e259	97f8c4fb-c0b8-4cf3-afba-5a9f237d8b05	1573-164-5	penthouse	\N	539.77	\N	613360.00
5e25b59f-aff2-4359-b2b8-62a10a63a843	8b6891a3-ecd2-462a-9175-7b92223b2bf8	1568-164-1	penthouse	\N	799.62	\N	3876068.00
6083c8de-e02d-468a-80b8-5333d3e379a2	1af04296-a88b-452a-b018-168ca9947a52	1564-111-1	apartment	\N	67.00	\N	312800.00
c13f5d15-4cd6-4e47-aaa0-7a6c61a66357	72102b5f-2a43-4d27-b965-acac64be4b1f	1562-111-1	apartment	\N	734.00	\N	448800.00
0606a714-80e7-4a97-810c-9d3fb228b00c	6611f726-7298-49b3-b792-86d9921603c8	1559-110-1	apartment	\N	58.10	\N	244803.26
096dcf76-cd9e-40c1-91f0-067bf0537148	6611f726-7298-49b3-b792-86d9921603c8	1559-111-2	apartment	\N	117.81	\N	258713.89
dc812295-b1b6-42c3-aeb7-461d4b6ba0f8	6611f726-7298-49b3-b792-86d9921603c8	1559-112-3	apartment	\N	170.74	\N	541132.85
ff605a01-2c7f-44e4-a173-79f5ddfdba30	51d2dcea-f5c1-4bf3-9980-8793a1d84a61	1555-111-1	apartment	\N	83.09	\N	530757.14
b99c4636-c288-4bbf-b34c-7c08b9119675	ddf44329-65fd-44bd-b50e-a51ce0d8c4a7	1554-111-1	apartment	\N	72.09	\N	225760.00
a611f800-31af-4ca6-8202-37e863413622	018e39c0-a1d3-41b6-809f-5ab497768438	1542-114-1	penthouse	\N	793.67	\N	26479200.00
e66b7027-3165-4cd7-a059-63a02b01d160	e0c6cfd1-6cbb-43fd-a527-0f529daaf6ef	1539-111-1	apartment	\N	99.71	\N	678912.00
4606d6a7-d3e7-4e53-a018-1c4a36ea8926	e0c6cfd1-6cbb-43fd-a527-0f529daaf6ef	1539-112-2	apartment	\N	134.03	\N	817632.00
2f60c664-5694-43ca-a5c7-66dc57a291c1	e0c6cfd1-6cbb-43fd-a527-0f529daaf6ef	1539-114-3	penthouse	\N	220.19	\N	1777520.00
ff564598-355f-42f2-8526-741729a5ff28	f4f59611-1a69-412e-bbfc-addd83a97589	1538-110-1	apartment	\N	55.90	\N	149600.00
711babc6-ec07-4f61-a5f4-97529d7f862e	ba263212-c742-4a61-8320-0f67eedc3e26	1535-111-1	apartment	\N	59.00	\N	544000.00
7bd1a029-f185-4ea1-8b88-8451abae214e	448f6b17-0669-44c7-9036-b5e8114dfe3e	1534-111-1	apartment	\N	62.84	\N	258400.00
e6dffd37-cf42-4b5f-9251-07f1ade91db9	448f6b17-0669-44c7-9036-b5e8114dfe3e	1534-112-2	apartment	\N	102.33	\N	353600.00
3183271a-a443-43cf-bb2b-3e909d63a113	c1ea064e-2012-4779-ac55-d78c6dee0871	1533-110-1	apartment	\N	37.19	\N	326400.00
ed0d1143-1442-499e-8827-d9adfd68cd2e	c1ea064e-2012-4779-ac55-d78c6dee0871	1533-111-2	apartment	\N	85.18	\N	540736.00
9a49693d-4ba5-477d-a217-ea8a3712f291	c1ea064e-2012-4779-ac55-d78c6dee0871	1533-112-3	apartment	\N	1184.00	\N	816000.00
9f8b2fcb-a6ca-4e3e-96d5-2e33f247bda2	c1ea064e-2012-4779-ac55-d78c6dee0871	1533-113-4	apartment	\N	176.00	\N	1278400.00
705fc307-0f1a-4680-aa56-fced30b56583	6d75046b-1bf4-4c20-bac7-7d227cd76b06	1532-111-1	apartment	\N	100.10	\N	326400.00
92a33946-7786-4655-b492-1c1e1feb8cc5	6d75046b-1bf4-4c20-bac7-7d227cd76b06	1532-112-2	apartment	\N	123.19	\N	731817.36
9d516601-5b20-4839-99d3-259eca8a5fbe	6d75046b-1bf4-4c20-bac7-7d227cd76b06	1532-113-3	apartment	\N	191.75	\N	1493806.32
409ec99f-ffa9-44e7-949c-68d221679b99	6d75046b-1bf4-4c20-bac7-7d227cd76b06	1532-164-4	penthouse	\N	261.49	\N	1377320.96
81c03298-7fee-41c1-9575-f5c5e88b45fd	b4120133-3bdf-43d8-ac2a-261bc4ef9901	1527-111-1	apartment	\N	78.01	\N	448800.00
0b1e3ce6-6437-4662-9112-50eb2d9eab49	0e980ff3-fab5-4f94-a090-fb478e97dad1	1526-112-1	apartment	\N	357.58	\N	3396355.20
d899c1a0-8cfc-4285-af13-94eb98c80695	0e980ff3-fab5-4f94-a090-fb478e97dad1	1526-113-2	apartment	\N	501.77	\N	6219111.36
0bb9b606-4d82-49ff-a2da-d2ad33e53845	0e980ff3-fab5-4f94-a090-fb478e97dad1	1526-114-3	penthouse	\N	592.81	\N	10066665.60
08f38770-8a78-4b37-99f7-a1b880767e22	0e980ff3-fab5-4f94-a090-fb478e97dad1	1526-115-4	penthouse	\N	825.72	\N	13538201.60
bb0dbcc8-97b3-4be6-8937-7d2e4c8205b2	58e7afb8-6795-4654-b613-48ef83437f86	1515-110-1	apartment	\N	38.68	\N	407456.00
955fc502-3268-4e9d-a2a3-5ddb5bbfdc22	58e7afb8-6795-4654-b613-48ef83437f86	1515-111-2	apartment	\N	54.60	\N	568480.00
041e4ff3-68ff-4a61-8bd5-18b69bb3ad79	bd641e6d-f4c8-4580-a35f-1c0af7cc0e17	1508-111-1	apartment	\N	60.47	\N	224400.00
21bf08a8-416e-44bc-b705-e6bfba929a36	a9817da7-4769-48bc-b3e8-2f5f62147d9c	1501-110-1	apartment	\N	37.89	\N	214880.00
ccae8801-8408-4f19-abd4-76fec6a43a09	b7cafe3a-7b48-4794-9f59-a737f42522d3	1499-112-1	apartment	\N	130.00	\N	938400.00
ae3cedd2-bc7a-40f3-96a0-365709b327dc	f2effd7d-6637-49eb-b717-669b512c6681	1498-112-1	apartment	\N	118.87	\N	509456.00
1f52708a-7078-46f0-ad6b-649d8f501974	c9329163-6f4b-45b1-a8ea-bef77b9c02ad	1494-112-1	apartment	\N	116.16	\N	456960.00
68c48738-f2ee-4d0c-be2e-63cf6d87e41d	1ec17e0f-c2bb-4c5c-9d69-44f17d813b9f	1487-110-1	apartment	\N	40.78	\N	365840.00
5d734637-2391-40b0-a98e-baddd1fa3d14	1ec17e0f-c2bb-4c5c-9d69-44f17d813b9f	1487-111-2	apartment	\N	68.38	\N	620160.00
876da892-282b-413f-a55e-040dbd85c8bc	1ec17e0f-c2bb-4c5c-9d69-44f17d813b9f	1487-164-3	penthouse	\N	94.58	\N	1482672.00
7b5bd71c-b673-4991-8018-b48625d48457	fb4c5f04-d790-4075-a06a-61944889d085	1480-111-1	apartment	\N	91.23	\N	470560.00
d3b65c64-04c7-418d-9834-af379804a0f3	85568b58-1fed-4f1e-9278-cec45ddeace0	1477-111-1	apartment	\N	72.74	\N	407969.54
503bc4f6-44c4-407b-aabe-7f248df80fb2	85568b58-1fed-4f1e-9278-cec45ddeace0	1477-112-2	apartment	\N	109.81	\N	677280.00
c1ba7111-df30-446f-8d6c-5baa3ae2970c	85568b58-1fed-4f1e-9278-cec45ddeace0	1477-113-3	apartment	\N	130.62	\N	899473.54
c00827c5-c63b-459d-8b3f-8d93e792d3aa	bcc168a9-9a72-41a5-8fed-ab31d606d474	1453-111-1	apartment	\N	68.73	\N	202640.00
432833f1-f72f-46af-86f6-24ca44f743aa	bcc168a9-9a72-41a5-8fed-ab31d606d474	1453-112-2	apartment	\N	156.82	\N	584528.00
4a95bc57-a61e-4e3e-a1f8-6cc4d1cd57e8	f7ab4ef9-deee-4720-8f01-2ca7c8860a44	1452-111-1	apartment	\N	125.98	\N	315661.98
635436f2-e3a9-47d2-970b-4e6cd51bf040	f7ab4ef9-deee-4720-8f01-2ca7c8860a44	1452-112-2	apartment	\N	101.08	\N	414192.35
0066a769-59ba-45d8-a94b-1da4cb8736e6	f7ab4ef9-deee-4720-8f01-2ca7c8860a44	1452-113-3	apartment	\N	218.51	\N	877471.73
73d499d3-d1f0-4b45-8d26-d8ab460cb4a4	e37b96ce-1d20-4dab-9fe4-e489859cd053	1415-112-1	apartment	\N	156.11	\N	1195984.00
16bb1531-349a-40d2-91ba-f0f25e562342	602b3a30-fb88-4772-ad15-d1ada6a5e68c	1412-111-1	apartment	\N	128.32	\N	1090992.00
a401bf8c-c7f0-4090-a3eb-af8c87a597aa	602b3a30-fb88-4772-ad15-d1ada6a5e68c	1412-112-2	apartment	\N	252.27	\N	1622752.00
a3b35450-aab7-45f3-bbb6-ac9e6f888ff6	602b3a30-fb88-4772-ad15-d1ada6a5e68c	1412-114-3	penthouse	\N	467.64	\N	5485424.00
972b99d2-4a13-48e4-8395-119decf191b1	3e83d6e3-d5b6-4050-a933-ccc56091c6bf	1403-110-1	apartment	\N	37.81	\N	243440.00
93b9c326-a776-46ba-8f08-bc308f119b62	bbf39092-07a2-4b26-83b9-10a053e023c7	1400-111-1	apartment	\N	65.37	\N	271184.00
1a0a44ba-fb16-4e25-bfed-25c9ee32fd58	ccdda552-8542-4124-a6fa-06440010e803	1365-111-1	apartment	\N	93.17	\N	613926.30
e27826b8-e5dd-4047-adf4-c02fb1585c95	ccdda552-8542-4124-a6fa-06440010e803	1365-112-2	apartment	\N	122.90	\N	827599.98
e51c23e8-1bc6-4fcf-8573-8a90770f100e	ccdda552-8542-4124-a6fa-06440010e803	1365-113-3	apartment	\N	165.92	\N	1033922.86
aa07eab3-c2d9-4eda-b009-9f256f112207	cd12ff61-40ed-4b65-907c-43adf655e384	1364-112-1	apartment	\N	272.48	\N	5032000.00
cac08a49-8a6d-4287-a8b3-7c68d4f9a541	cd12ff61-40ed-4b65-907c-43adf655e384	1364-113-2	apartment	\N	357.40	\N	6800000.00
b536e0d8-292f-43e7-8c8d-043ce9818517	e49be3ed-032a-4635-a103-a70a31835bd0	1363-111-1	apartment	\N	123.98	\N	1903728.00
b7d107ff-ef57-485a-b186-fb93d50439b2	e49be3ed-032a-4635-a103-a70a31835bd0	1363-112-2	apartment	\N	234.93	\N	1881696.00
12dc4822-14a3-4c7f-be98-7f575d1c0afd	e49be3ed-032a-4635-a103-a70a31835bd0	1363-113-3	apartment	\N	391.87	\N	5589600.00
c33613ca-5aa8-426c-a744-3dbbf9c6c940	aea0f147-a0fc-4992-9e94-a38b8f9d85ee	1359-111-1	apartment	\N	82.87	\N	257158.05
c0da3438-7cbb-4613-9ef7-f472d3ac248b	ae580e2e-990d-47ed-bbbd-15ee1d6aa66f	1358-111-1	apartment	\N	81.71	\N	379984.00
eacb0f53-254d-4ead-b10f-42330553ef19	ae580e2e-990d-47ed-bbbd-15ee1d6aa66f	1358-112-2	apartment	\N	126.38	\N	435200.00
4f38bf8d-8949-49ca-9f4e-3982688e6255	ae580e2e-990d-47ed-bbbd-15ee1d6aa66f	1358-113-3	apartment	\N	158.99	\N	734128.00
124ae1d6-2ca3-4eae-b5a2-fe01dbf15c32	21443a8a-817a-4963-b54f-40720e577c1c	1357-111-1	apartment	\N	94.08	\N	469744.00
e93aff69-3317-4509-b614-4287a257f940	21443a8a-817a-4963-b54f-40720e577c1c	1357-112-2	apartment	\N	242.93	\N	640288.00
26296ae5-0d3d-4e23-bf65-2e0089d2e344	21443a8a-817a-4963-b54f-40720e577c1c	1357-113-3	apartment	\N	445.07	\N	1343680.00
f6a9ff6c-2f6c-4ef6-8040-24c5ca91dad1	da534cb0-40f1-4eed-ad88-2937f77e5d2b	1352-110-1	apartment	\N	51.00	\N	217600.00
7654258d-c170-4e12-afbc-6f587b0e53e1	e5fac7de-6b78-4433-815e-3a89a8f41ba8	1351-113-1	apartment	\N	349.97	\N	9520000.00
df83d9f9-e903-4d02-b072-3d3a68a28c2c	e5fac7de-6b78-4433-815e-3a89a8f41ba8	1351-114-2	penthouse	\N	476.96	\N	11424000.00
13e6bb23-ea1a-48a4-adad-34f05daf9a1d	cfb80d4a-19ce-446c-804b-a49924f4dd1d	1350-113-1	apartment	\N	431.72	\N	6120000.00
57a64d5b-73ee-425c-862b-5d7e496c60a0	cfb80d4a-19ce-446c-804b-a49924f4dd1d	1350-114-2	penthouse	\N	1150.98	\N	8840000.00
cc3e3d76-5827-4849-be05-eab6d4f26209	cfb80d4a-19ce-446c-804b-a49924f4dd1d	1350-115-3	penthouse	\N	767.29	\N	13600000.00
892ce4a7-87c0-4816-a2cd-c9125dae7fa6	99f396e1-1f71-49a3-a9f4-def9d5603569	1349-113-1	apartment	\N	3064.00	\N	1278400.00
e13ec3a2-39d1-43cc-916e-3677e5f2ef92	69347719-4904-49e0-be59-30452b735e62	1347-112-1	apartment	\N	100.43	\N	666400.00
7e1136b5-46d0-45e2-ba17-815a15be9bc0	9d1688b6-89bd-4223-948c-fe2df20b1bda	1343-111-1	apartment	\N	72.09	\N	748000.00
4cf4feb6-c14d-4122-b31e-3f9394623185	7edc0b05-46ce-43d8-b07a-a6d2640b8660	1342-110-1	apartment	\N	58.03	\N	204000.00
3e47ec5d-4a49-435f-ab46-0578c705c3ea	7edc0b05-46ce-43d8-b07a-a6d2640b8660	1342-111-2	apartment	\N	70.05	\N	285600.00
dd420733-d8b9-4eb0-ab61-725c5c34cd6e	7edc0b05-46ce-43d8-b07a-a6d2640b8660	1342-113-3	apartment	\N	138.91	\N	625056.00
be799b1b-6e9e-49aa-bb09-94305453fa34	cc04b742-b1e1-4bae-9c19-95e14b414887	1331-112-1	apartment	\N	114.07	\N	421600.00
38ab0143-ce42-4432-9de7-2a6e9c399f10	f47ea7e0-e524-4ad0-9ef8-ac724bbd2a50	1324-111-1	apartment	\N	60.48	\N	489600.00
5af3a19f-c321-47b4-bf55-8722c050cfc7	8580c8d6-a20c-4a8a-9585-7512e57d3d38	1321-111-1	apartment	\N	62.80	\N	269280.00
bdec4b96-0e4e-41aa-865b-429815f0db25	2e933300-83ac-408f-8eb7-22b22f1e98c2	1320-110-1	apartment	\N	41.81	\N	244800.00
a7beef93-f6c5-40f0-823e-9dfd77c179e8	ef4b3e0c-1226-469e-b4e4-ea24f9d8f09d	1304-110-1	apartment	\N	39.13	\N	131748.37
f1957b28-1fbb-47b7-beff-537535aeb9e5	ef4b3e0c-1226-469e-b4e4-ea24f9d8f09d	1304-111-2	apartment	\N	86.00	\N	216933.60
4a6db152-b00e-4684-badf-4c126dd186aa	ef4b3e0c-1226-469e-b4e4-ea24f9d8f09d	1304-112-3	apartment	\N	207.70	\N	1133452.02
b09b9d31-9715-4c37-8ffd-9975a443fb70	ef4b3e0c-1226-469e-b4e4-ea24f9d8f09d	1304-113-4	apartment	\N	254.00	\N	1059072.53
18338fa3-a204-4eef-bcd1-fd3769c7c971	ef4b3e0c-1226-469e-b4e4-ea24f9d8f09d	1304-114-5	penthouse	\N	550.62	\N	1302880.00
52ef5162-eed9-4da7-a202-7bd6537870a5	7ad898f2-445b-48f8-9b67-4f354bb9b0ac	1295-110-1	apartment	\N	38.00	\N	163200.00
665c20ec-2f79-4870-9b30-cac2218db314	351daca5-8ec8-4b66-abff-2e90d17cc82b	1285-113-1	apartment	\N	322.84	\N	11696000.00
b666028a-aa6a-43c6-96be-06007a9c87cf	351daca5-8ec8-4b66-abff-2e90d17cc82b	1285-114-2	penthouse	\N	565.78	\N	17136000.00
735dfa35-17c3-44b2-9938-22269fb26bc0	2c75392e-98f3-4689-b5ee-97cd7085aa99	1279-110-1	apartment	\N	41.43	\N	155040.00
9a5794a0-d644-41e7-958f-54a72d11bdca	2c75392e-98f3-4689-b5ee-97cd7085aa99	1279-111-2	apartment	\N	64.52	\N	258400.00
8157447e-3d25-465a-98da-f02edd9e397c	15ed6c7b-e724-47c0-91ff-21aac0b054bd	1275-110-1	apartment	\N	35.78	\N	388960.00
235d8494-c6cc-422c-9619-3a3421c2e7fb	bba28692-2fd3-4d7a-9ec3-0353d7248750	1271-164-1	penthouse	\N	139.08	\N	1574880.00
097ebd52-11fc-4683-b26d-ce729e5d8f00	b9a465ba-08e1-42a0-9bc2-08001d0fdb22	1269-112-1	apartment	\N	500.96	\N	5276800.00
32f8d0bf-acad-46db-8563-1c4b69d5296a	b9a465ba-08e1-42a0-9bc2-08001d0fdb22	1269-113-2	apartment	\N	585.13	\N	9955200.00
9601857d-d313-49c7-9186-afb789037cfc	b9a465ba-08e1-42a0-9bc2-08001d0fdb22	1269-114-3	penthouse	\N	1215.73	\N	42160000.00
bb99a2b3-59c5-428e-b888-25322b95c66c	83a74ccc-70e7-4d0f-b095-7f38dde6dc94	1268-110-1	apartment	\N	74.66	\N	775200.00
5ad67603-901c-4d82-9eaf-23152f2e64c2	0927ca9d-48a5-4d2a-b07b-0f318581485a	1257-112-1	apartment	\N	291.81	\N	6256000.00
8e117932-4867-49d6-857f-80dcc4742f48	0927ca9d-48a5-4d2a-b07b-0f318581485a	1257-113-2	apartment	\N	531.78	\N	10336000.00
41491ef8-7b0a-4fbe-852e-5e0c7ef82214	0927ca9d-48a5-4d2a-b07b-0f318581485a	1257-114-3	penthouse	\N	652.92	\N	13872000.00
d15ddf06-8f74-4a90-bd78-383e53502d28	0927ca9d-48a5-4d2a-b07b-0f318581485a	1257-115-4	penthouse	\N	2943.17	\N	18360000.00
cab6b13d-1b2f-40b5-938b-1d05ebb35117	f4125cdb-0d29-4453-9bda-6d5ee85c5b3e	1252-110-1	apartment	\N	37.35	\N	165185.60
18e31e7b-a4c9-42b4-a479-48730e0cc81f	f4125cdb-0d29-4453-9bda-6d5ee85c5b3e	1252-111-2	apartment	\N	69.86	\N	250512.00
b5c21af5-8a1d-49ae-977c-02a553066640	ea91ed03-4ddc-4440-81b4-5cf9740996f6	1244-110-1	apartment	\N	28.89	\N	184960.00
00043a1b-de3c-42b1-82f7-cfe0a15ab5f3	ea91ed03-4ddc-4440-81b4-5cf9740996f6	1244-111-2	apartment	\N	59.83	\N	306000.00
5f8703d8-08c1-4c33-918c-4d0f0fa70f53	ea91ed03-4ddc-4440-81b4-5cf9740996f6	1244-112-3	apartment	\N	103.22	\N	458320.00
441afb43-1350-4ff0-863a-d7dba652b6db	637fba71-ceb7-495e-872c-74d347fb552b	1242-112-1	apartment	\N	306.81	\N	2358240.00
6b6f479f-dba1-4491-92ff-38f86021b045	637fba71-ceb7-495e-872c-74d347fb552b	1242-113-2	apartment	\N	303.22	\N	3922239.73
2a3d8dfe-604f-44c1-97a3-89a2619723b0	637fba71-ceb7-495e-872c-74d347fb552b	1242-115-3	penthouse	\N	1095.94	\N	47600000.00
17039034-71d4-4488-b4cd-2ba6ded58a26	309586e4-8109-431c-8a20-368aa58328a3	1240-111-1	apartment	\N	70.89	\N	639200.00
e45ba970-f66e-4476-b6a4-aed03d5a345e	360da4eb-1107-4d04-9796-4f8bb00ce364	1235-111-1	apartment	\N	129.85	\N	475798.18
15cfd02b-64f6-4635-b3f1-14737fa472ff	360da4eb-1107-4d04-9796-4f8bb00ce364	1235-112-2	apartment	\N	111.86	\N	398480.00
2000746e-6bca-467b-bb5e-68eafeecc7fa	5b472437-8ae7-4658-9e8f-da56ae2fe271	1231-164-1	penthouse	\N	187.10	\N	413228.11
e8a3463d-cfd0-4b2c-a2f2-99f28f58e569	944883a2-54c7-425f-b9c4-12931a0b7764	1228-112-1	apartment	\N	127.00	\N	421600.00
8d94448b-e1e9-4ddd-9a20-4dfd3b1c1152	0883815e-773e-4a12-bbe9-05b04a8a7898	1226-112-1	apartment	\N	112.70	\N	648961.54
449741f8-48d4-4241-9c8c-9b499e3fccc3	40113f05-0efd-45ff-a357-65458460d2e5	1225-112-1	apartment	\N	128.49	\N	1527521.54
2760adc9-ef30-4fba-8b50-c8f7f0a37ee6	ad5e731d-a09e-4d64-8244-36576396c6eb	1224-111-1	apartment	\N	49.75	\N	394400.00
8b31b22c-c9b2-44d0-b347-9963e29fbd20	ad5e731d-a09e-4d64-8244-36576396c6eb	1224-112-2	apartment	\N	68.82	\N	571200.00
703834d4-0231-4823-ab26-5b3ae61ba7b9	ad5e731d-a09e-4d64-8244-36576396c6eb	1224-164-3	penthouse	\N	81.10	\N	1652128.00
b38090d6-7e0b-400d-a017-c1889a632fa4	6e427985-4d49-4777-9977-642452dc6e6d	1223-111-1	apartment	\N	83.74	\N	378080.00
0c2ffcd1-33d1-4617-92c8-a937b51fc014	6e427985-4d49-4777-9977-642452dc6e6d	1223-112-2	apartment	\N	105.35	\N	589152.00
563438c6-0dec-436d-96a3-8e28dd2332e6	16810fe1-8b47-4b24-90ca-87d06d631bbf	1221-111-1	apartment	\N	94.00	\N	567702.08
be5e6c7e-711b-4d0e-89ee-eef2a62c2d59	16810fe1-8b47-4b24-90ca-87d06d631bbf	1221-112-2	apartment	\N	117.52	\N	913920.00
baf6f2be-98a5-465c-b4a2-126b88d61b5a	16810fe1-8b47-4b24-90ca-87d06d631bbf	1221-113-3	apartment	\N	307.04	\N	1799008.00
70eff7ee-cb39-4a77-9b08-2f5bf7bdd452	7bfcd560-87d4-419c-a02b-10603b704c09	1219-110-1	apartment	\N	37.81	\N	299200.00
19f0fcde-9855-4ab4-8f68-3e18c9e58fb3	7bfcd560-87d4-419c-a02b-10603b704c09	1219-112-2	apartment	\N	408.36	\N	949280.00
34971c6a-42f5-41af-ad3f-df2d79fe27dc	7bfcd560-87d4-419c-a02b-10603b704c09	1219-113-3	apartment	\N	187.09	\N	1761200.00
b5b405fb-660c-4971-8d73-da2728213828	65e5e9b5-9dfb-4780-bb5a-b42d0ef42e80	1218-112-1	apartment	\N	105.13	\N	614176.00
3cc46ba0-23e2-4080-a7b9-dddfc351d448	8902ba38-0c70-499c-83ed-998267ca9fad	1212-111-1	apartment	\N	84.16	\N	317696.00
fc71d94b-fd97-4fe9-acf0-92a2916cc918	f8bda7a3-be22-4503-b63b-d2b63440145b	1210-113-1	apartment	\N	881.65	\N	14394457.60
f6b48393-0eee-47da-9d49-e1d69c631a71	f8bda7a3-be22-4503-b63b-d2b63440145b	1210-114-2	penthouse	\N	956.81	\N	15744665.60
dd73878d-bcf1-4c29-a9f4-dc7d31257729	2b5c5c10-f45d-46e3-a936-25bc4cd715ce	1209-111-1	apartment	\N	57.98	\N	269280.00
91c46454-80f7-4ff4-b851-e524dd677257	bb2ab590-5abc-4035-810a-747e4ad84fc4	1207-110-1	apartment	\N	78.22	\N	888781.76
41f873e5-16b2-43c2-950e-61d5220c6c7e	bb2ab590-5abc-4035-810a-747e4ad84fc4	1207-342-2	townhouse	\N	640.00	\N	2720000.00
21e1da92-e822-4fc6-b877-1eabf879bd3f	34b7b282-11ba-4a31-8353-5a386b7ab715	1206-111-1	apartment	\N	73.50	\N	1003680.00
561fd42f-a160-4e13-ae8a-cff4b8dade02	34b7b282-11ba-4a31-8353-5a386b7ab715	1206-112-2	apartment	\N	247.31	\N	1981248.00
25351341-e344-4a0b-a7b1-f254b94d947e	34b7b282-11ba-4a31-8353-5a386b7ab715	1206-113-3	apartment	\N	577.11	\N	2267936.00
e82dd158-fa9b-4169-af83-c9ce6a9a0830	34b7b282-11ba-4a31-8353-5a386b7ab715	1206-114-4	penthouse	\N	562.86	\N	8108048.00
3fb9bc47-d8b3-46ab-b392-5f089f819a72	34b7b282-11ba-4a31-8353-5a386b7ab715	1206-115-5	penthouse	\N	711.22	\N	10245152.00
7d5f3172-e1bd-46f6-be04-ae9dc838d1e6	9fa4b0d6-92b4-4b7d-8549-689fa1675f3e	1205-110-1	apartment	\N	37.63	\N	340000.00
0afb41d7-a508-4aa6-915e-04869ccde995	9fa4b0d6-92b4-4b7d-8549-689fa1675f3e	1205-164-2	penthouse	\N	145.77	\N	836324.11
edb9fcc1-4ef1-493b-ac22-cb6848841b4f	6f66d05c-7876-4662-89d9-743a1c86b0e1	1201-110-1	apartment	\N	46.60	\N	450300.08
d375c113-a5bf-4d5d-9a18-6a17f42c8d8e	6f66d05c-7876-4662-89d9-743a1c86b0e1	1201-111-2	apartment	\N	104.65	\N	544834.22
db107dab-401d-46bf-a05d-3dfae78c63bd	6f66d05c-7876-4662-89d9-743a1c86b0e1	1201-112-3	apartment	\N	160.26	\N	860867.76
fd80770f-402c-4636-a667-b798f3a22596	149d14f2-3f4a-4558-bae9-d67fefb71a12	1199-111-1	apartment	\N	99.32	\N	579360.00
f6799570-f2ec-4cfa-96f2-fcb1fa0e6a4f	149d14f2-3f4a-4558-bae9-d67fefb71a12	1199-112-2	apartment	\N	130.62	\N	870400.00
fe9540ad-2c2a-48e9-b2d4-62b89ca87e8a	8b738a02-54e9-44d4-b76c-71e77fcdb359	1198-111-1	apartment	\N	81.10	\N	326400.00
63d8fe47-b48a-4df8-b4db-8ee8e85cba5d	8b738a02-54e9-44d4-b76c-71e77fcdb359	1198-112-2	apartment	\N	109.39	\N	487152.00
0492fa46-39c2-4215-813d-25ffd258a494	be56202f-fbd1-4726-a6c7-6eeb75ef644d	1195-112-1	apartment	\N	128.49	\N	1371393.54
d395a137-fede-439a-8da7-606a9c72fb74	c5cf1818-4341-4b30-8316-d98b36972215	1193-112-1	apartment	\N	132.00	\N	999009.22
7930f23f-823f-4300-a195-e85972acaff3	7650161f-7e15-46c6-aaf6-8b329ad83089	1192-111-1	apartment	\N	59.84	\N	212160.00
cc624ecd-e587-47fe-a764-d011e1896d3b	6a6dcd6d-f2ee-44e9-b69d-3ebb6e55b2da	1191-110-1	apartment	\N	40.20	\N	180984.72
578fbcde-b9bc-498d-ad38-04c4a2126908	6a6dcd6d-f2ee-44e9-b69d-3ebb6e55b2da	1191-111-2	apartment	\N	62.87	\N	285600.00
618d9e1f-ebbb-4aa6-ac16-3866fd3aa2a3	6a6dcd6d-f2ee-44e9-b69d-3ebb6e55b2da	1191-113-3	apartment	\N	302.59	\N	816000.00
3a0192f1-e0ee-4c40-bf37-cf3b43631d30	6d8cf74e-6dbc-4b91-994c-27d2d66797df	1186-111-1	apartment	\N	72.08	\N	472031.79
348ccbb4-a413-4168-a92a-515189e2a6c3	6d8cf74e-6dbc-4b91-994c-27d2d66797df	1186-112-2	apartment	\N	117.71	\N	748000.00
5392eb76-85a3-4903-84ea-efce86a504bb	f51749d9-54ed-4d89-8229-ae6c82cdf26d	1185-111-1	apartment	\N	81.20	\N	701488.00
a4f36750-c713-490b-8324-514b1b8b3443	f51749d9-54ed-4d89-8229-ae6c82cdf26d	1185-113-2	apartment	\N	203.20	\N	1630640.00
e91682f5-3dbd-4d19-a6f3-9a463ea5587d	5e4a8e19-8fd4-48a8-b172-8c4da2ca5677	1184-112-1	apartment	\N	190.55	\N	1813152.00
fefe8e9e-833f-449a-b99d-49de85513ec0	ac799b7f-cb51-459f-9413-ca6b998bb3be	1182-110-1	apartment	\N	42.63	\N	201280.00
cfbfd6d9-7f48-4b2b-8303-2ef136102113	ac799b7f-cb51-459f-9413-ca6b998bb3be	1182-111-2	apartment	\N	970.00	\N	346799.73
df81fb5b-0270-47e2-8077-79fcd62449ce	a5d246a5-60d4-4e46-baff-60b076c978a8	1179-111-1	apartment	\N	75.60	\N	677280.00
edb4ec86-73c6-4ddc-a7d0-5651bda4cd9b	a5d246a5-60d4-4e46-baff-60b076c978a8	1179-112-2	apartment	\N	111.48	\N	1123632.00
5467850f-4c51-4bba-8106-a6fb93595f04	a5d246a5-60d4-4e46-baff-60b076c978a8	1179-113-3	apartment	\N	220.55	\N	2366400.00
656280ec-910a-41c7-9985-27f32983a142	27a56b3a-43db-4f55-a261-09cf17591142	1174-111-1	apartment	\N	59.64	\N	516800.00
7fd02e4f-31d1-479f-a068-1b0570e97416	27a56b3a-43db-4f55-a261-09cf17591142	1174-112-2	apartment	\N	102.01	\N	788800.00
2e31db04-0360-430c-a468-ef2f59bf0f98	27a56b3a-43db-4f55-a261-09cf17591142	1174-113-3	apartment	\N	153.63	\N	1305600.00
17bed8ee-3e12-4b9d-8b58-1eb40ae90a64	002f74c5-e3fc-40f5-b090-e7026be4310b	1172-341-1	villa	\N	2090.32	\N	50320000.00
c810f60f-e90b-4988-acc5-e2aea515469f	a3bdccd8-c932-4c62-99bb-b11c9e0533c5	1170-111-1	apartment	\N	75.00	\N	421600.00
42732a36-0df0-4c4f-b648-9bfd8dde4f7c	4d1191fd-6692-4006-8664-3e27f2c9c466	1165-111-1	apartment	\N	61.59	\N	225760.00
db4705c7-22a8-4926-b336-817ea53d2dbd	67943fed-1b97-4b6a-a4b6-78bb579a0a88	1164-112-1	apartment	\N	123.32	\N	750176.00
a27e7090-00e0-4f36-9a9f-e4c70ab4d1a7	f102ac5a-c7b9-4b2c-b251-ba810ea7e503	1153-110-1	apartment	\N	394.00	\N	163200.00
60aecf30-9fee-4ee4-a371-ff7292849d3c	f102ac5a-c7b9-4b2c-b251-ba810ea7e503	1153-111-2	apartment	\N	65.19	\N	271728.00
12fc80ae-acea-44aa-bf57-fde4ea2c9ffa	9897322a-9afb-4408-8e33-3be7bfdd0ead	1151-110-1	apartment	\N	38.58	\N	195840.00
5d7f0e74-b1f6-4fb7-9aa0-2243fc95150b	1f768ecd-0a3e-4406-8897-d34365465aeb	1146-110-1	apartment	\N	41.58	\N	340000.00
50c282c1-e731-480e-bbd2-477a309f0a71	1f768ecd-0a3e-4406-8897-d34365465aeb	1146-114-2	penthouse	\N	542.09	\N	5440000.00
23b108a8-4bd4-4999-b633-d273d4900783	f2fb9ba9-7382-4d24-a3a0-3ebce598c90b	1143-110-1	apartment	\N	35.56	\N	293760.00
4aa94cc7-ef4c-445d-a6d6-f110a4119785	f2fb9ba9-7382-4d24-a3a0-3ebce598c90b	1143-111-2	apartment	\N	71.54	\N	406640.00
10523b9b-a504-456d-8129-2e3806f5535c	5c4f64c1-f842-47fd-98c2-55e7fc7e2b6e	1140-114-1	penthouse	\N	675.41	\N	3263877.06
f272a87d-f563-44fe-bb18-00965ec14ca8	5c4f64c1-f842-47fd-98c2-55e7fc7e2b6e	1140-115-2	penthouse	\N	1418.63	\N	17951877.06
8254e334-4b1b-436b-af25-733a7e2962f9	1f474edf-21ab-44ba-8bc2-7d41ad927147	1133-111-1	apartment	\N	98.76	\N	571200.00
d16a133d-edc0-46b1-9325-342873ff822a	1f474edf-21ab-44ba-8bc2-7d41ad927147	1133-112-2	apartment	\N	380.05	\N	934048.00
3788b471-8773-400a-8aea-52fc69bca1ec	1f474edf-21ab-44ba-8bc2-7d41ad927147	1133-113-3	apartment	\N	308.30	\N	1566992.00
78bdef50-3937-4758-99be-18f21d4a8774	d8a3f48b-e69a-4f24-87a7-89cb677fbc5f	1132-110-1	apartment	\N	42.27	\N	326400.00
72402733-b796-4d2c-a237-cbdc2565fbd8	d8a3f48b-e69a-4f24-87a7-89cb677fbc5f	1132-112-2	apartment	\N	148.34	\N	598400.00
e308a46c-c1f5-475b-8e9c-fe696262f647	a6beac06-f685-421a-aa8e-656d8e00717d	1130-111-1	apartment	\N	74.51	\N	816000.00
9fe0f6f4-538e-4591-87f0-8ee405d80c81	a6beac06-f685-421a-aa8e-656d8e00717d	1130-114-2	penthouse	\N	268.00	\N	5140800.00
0484c178-ce5b-4cdf-8021-b7b4fffd56d7	249e78ab-2c9d-4589-916d-1e5b1147d9a8	1122-111-1	apartment	\N	84.91	\N	519520.00
a3e4c474-e2d9-47cb-a0d7-494bd4c2956d	885b3c83-154a-49c1-adbd-616b46f7b678	1119-112-1	apartment	\N	153.75	\N	788800.00
61732b66-344a-434f-af72-059c24e5b93f	98460df4-2727-4b19-bb52-a328440fd037	1118-110-1	apartment	\N	44.17	\N	144799.20
639a1776-8d03-41da-9430-15374e12f0e2	98460df4-2727-4b19-bb52-a328440fd037	1118-111-2	apartment	\N	73.19	\N	186496.80
9da0b177-787d-4924-b39c-415077354d7a	f569ef1d-3e4e-40de-9e72-6b7bfb8330ae	1117-111-1	apartment	\N	1222.11	\N	856528.00
43dca4b8-5111-4fd5-a17c-ca2558416ddb	f569ef1d-3e4e-40de-9e72-6b7bfb8330ae	1117-112-2	apartment	\N	143.07	\N	1466080.00
ba054405-e171-40c5-b1cc-d48a0845dcc8	f569ef1d-3e4e-40de-9e72-6b7bfb8330ae	1117-114-3	penthouse	\N	932.32	\N	18181296.00
f7ab68a7-10bb-4f6e-ad85-5818e26b258f	f569ef1d-3e4e-40de-9e72-6b7bfb8330ae	1117-115-4	penthouse	\N	933.96	\N	19865792.00
343e81e2-158d-420b-9992-11d6d7eeec8f	0418e37e-af34-4adf-b121-b3a10e12ee97	1116-110-1	apartment	\N	54.12	\N	430001.54
ed860b39-a4db-40de-ae8d-4042ff9a587b	0418e37e-af34-4adf-b121-b3a10e12ee97	1116-111-2	apartment	\N	61.23	\N	545057.54
562a1e87-233c-4603-bd2f-0380a2a22801	5800bdf3-9cbe-4514-8e91-35236503681e	1114-111-1	apartment	\N	72.09	\N	462400.00
15deed59-a1e3-480f-aa4a-b596cd1426fe	c4d086d1-66eb-4681-885e-c83dc542b555	1113-113-1	apartment	\N	158.03	\N	1133121.54
cbae3213-1384-4600-8222-3efb6df508c7	e7fb78a2-7491-42bf-8d70-25844bf6da15	1112-113-1	apartment	\N	157.10	\N	1128769.54
30eb7544-0d2f-40de-a28a-e5057d6bb3de	17901d59-37d1-4b9d-9495-63b97403d116	1110-111-1	apartment	\N	674.57	\N	367200.00
3bc1ac4e-36f8-4e8d-b02b-8a65e4934295	17901d59-37d1-4b9d-9495-63b97403d116	1110-112-2	apartment	\N	81.66	\N	788800.00
5546c5f2-538c-4d8b-ba8f-689c50b36476	52b17edc-8fc0-4714-9d32-37d10ffcf3f6	1108-111-1	apartment	\N	95.13	\N	323680.00
36623b93-1a4b-4375-a803-d498fd8cd818	52b17edc-8fc0-4714-9d32-37d10ffcf3f6	1108-112-2	apartment	\N	109.90	\N	443904.00
c5344f2b-0484-42f6-9250-2732d9faafe5	e26efd42-4b7c-4d03-82ce-daadd21bd5e1	1107-111-1	apartment	\N	65.40	\N	448800.00
9e278bd1-67a2-48e8-a250-191304bd4d9a	e26efd42-4b7c-4d03-82ce-daadd21bd5e1	1107-112-2	apartment	\N	106.10	\N	652956.67
a1504878-69ef-4b53-95b3-6a1c8f0a636f	3f5ec8c3-a9df-48ab-9db6-31179d47c85a	1106-110-1	apartment	\N	39.48	\N	156400.00
7b63d283-939c-4e86-a926-97b3be313d6e	3f5ec8c3-a9df-48ab-9db6-31179d47c85a	1106-111-2	apartment	\N	88.00	\N	312800.00
73716460-7bb4-43aa-baea-15af1324d380	8841e765-98e1-4c17-b506-d4a54d1e8d59	1105-111-1	apartment	\N	75.90	\N	557600.00
e5b9942c-0516-40df-a52b-74e403f881be	383399aa-a28f-43df-bdac-347e398865a7	1102-111-1	apartment	\N	83.15	\N	280179.58
097f1f21-3c96-4531-b7a1-e4428b3fe0f9	44baac96-0782-4555-a2c2-4aece0a70c96	1100-111-1	apartment	\N	96.00	\N	433024.00
97dd7fdf-d7a7-45d8-8a96-0d9a9a2ac280	44baac96-0782-4555-a2c2-4aece0a70c96	1100-112-2	apartment	\N	99.16	\N	565759.46
b67c510c-2062-491c-b339-f84d9aae3a36	108aa867-e7c0-4dc8-9632-f9aa5d186e21	1099-111-1	apartment	\N	65.00	\N	312800.00
8b870f3e-a267-4e7b-b80a-b709bf6b2549	5ac34360-74a5-4547-a1a5-339f3682d642	1097-110-1	apartment	\N	38.46	\N	217790.40
06134895-e0bb-4d86-bd49-7efa8bf80b89	5ac34360-74a5-4547-a1a5-339f3682d642	1097-111-2	apartment	\N	100.99	\N	299200.00
86c2f238-a956-4060-831a-f6b1eb3084f0	5ac34360-74a5-4547-a1a5-339f3682d642	1097-112-3	apartment	\N	105.72	\N	408000.00
80fe0d8d-7954-4635-9830-cb088eca148a	5ac34360-74a5-4547-a1a5-339f3682d642	1097-113-4	apartment	\N	73.22	\N	299200.00
edfae193-247c-4d60-8d33-26b4155f223e	838d8893-c298-498b-be86-086e5ecaa58e	1096-111-1	apartment	\N	881.35	\N	271728.00
e8a6cd6d-4ef4-407d-b786-c7538329ead9	06672797-ced6-4e6f-b2fc-a41cf90ee67f	1095-111-1	apartment	\N	115.54	\N	992054.72
d6f72958-4fe7-41e8-a88e-07a9bf295589	06672797-ced6-4e6f-b2fc-a41cf90ee67f	1095-112-2	apartment	\N	159.44	\N	1820544.96
4385ff8e-0071-4e5e-a11d-29851ce91990	06672797-ced6-4e6f-b2fc-a41cf90ee67f	1095-113-3	apartment	\N	348.30	\N	4792811.09
d11ba04d-6110-4c13-9493-f6692a57936e	06672797-ced6-4e6f-b2fc-a41cf90ee67f	1095-114-4	penthouse	\N	676.79	\N	6049509.84
6069196b-916d-4a45-b111-eddef403e9d1	06672797-ced6-4e6f-b2fc-a41cf90ee67f	1095-115-5	penthouse	\N	751.23	\N	13923255.14
2b55dca7-6855-4f53-88df-fa27b83b8707	06672797-ced6-4e6f-b2fc-a41cf90ee67f	1095-341-6	villa	\N	2266.70	\N	28649980.32
e56d7928-af5d-4bfa-b5e5-c854994aa1df	2375329f-5c0d-4088-ab48-6682f4ebeadd	1094-111-1	apartment	\N	70.89	\N	671296.00
2b7283fd-708a-4516-9dc1-c80535e71c1b	2375329f-5c0d-4088-ab48-6682f4ebeadd	1094-113-2	apartment	\N	718.33	\N	9668512.00
bd3f7fdb-cea1-41a7-90e1-9d929d3b5fd1	2375329f-5c0d-4088-ab48-6682f4ebeadd	1094-164-3	penthouse	\N	182.93	\N	3914624.00
e16099d2-02c7-4d2b-8af8-0e566a56c085	b6c47b3d-7138-4db7-8572-763fcb76358d	1091-110-1	apartment	\N	323.67	\N	144160.00
70044911-b353-4425-81ac-8aec06852fb8	c87ae554-3568-48e0-82aa-c84a35e9ccf7	1088-110-1	apartment	\N	39.02	\N	271728.00
99730c54-c390-45c6-b800-291d0f74e882	c87ae554-3568-48e0-82aa-c84a35e9ccf7	1088-111-2	apartment	\N	68.46	\N	450840.00
83b977c4-1775-4a80-b233-60ba60e96c47	c87ae554-3568-48e0-82aa-c84a35e9ccf7	1088-114-3	penthouse	\N	312.11	\N	2263040.00
61568640-5540-4f4d-bcbc-96a140488f4a	c87ae554-3568-48e0-82aa-c84a35e9ccf7	1088-115-4	penthouse	\N	535.61	\N	4086800.00
a903e936-a3ae-49e3-8db3-2934eb1f44c4	51fd77d8-befb-4035-a927-b800ea7cc9be	1086-110-1	apartment	\N	54.84	\N	217056.00
38777783-acf0-41f1-a665-39be8a3303bc	51fd77d8-befb-4035-a927-b800ea7cc9be	1086-111-2	apartment	\N	140.82	\N	209440.00
081c689e-5a37-46f2-a506-28fff051ca43	51fd77d8-befb-4035-a927-b800ea7cc9be	1086-112-3	apartment	\N	135.72	\N	558416.00
9d8687dd-2c34-4314-832b-6d7460d99a5f	43c2b54b-92d2-458d-8481-8a8bfe663658	1085-111-1	apartment	\N	88.00	\N	435200.00
f62e76ee-5f5e-43be-9b17-8ebf93abfe7a	43c2b54b-92d2-458d-8481-8a8bfe663658	1085-112-2	apartment	\N	130.30	\N	622336.00
9129e060-02fd-445c-adf7-55b59bc0de50	8e9c034b-8471-4ec2-868e-894359935978	1077-110-1	apartment	\N	57.69	\N	220320.00
e7db3ba0-c8ef-4946-8199-f31be24f939b	8e9c034b-8471-4ec2-868e-894359935978	1077-111-2	apartment	\N	68.84	\N	318240.00
7a68979a-c88d-45ac-9f25-82479e99c33a	8e9c034b-8471-4ec2-868e-894359935978	1077-112-3	apartment	\N	98.00	\N	462400.00
46672a47-1080-4737-856d-cb94c9dee2e4	01f86b90-1f59-4c42-8f42-dd73cde92f86	1075-110-1	apartment	\N	1350.00	\N	298384.00
00c81b83-69eb-4de3-9931-c5284c652b8a	01f86b90-1f59-4c42-8f42-dd73cde92f86	1075-111-2	apartment	\N	81.62	\N	543184.00
7fff6054-6b63-44df-ba90-bc95d418a076	01f86b90-1f59-4c42-8f42-dd73cde92f86	1075-112-3	apartment	\N	111.85	\N	788528.00
7f24b213-ed70-4309-8c3e-d236c5152dcd	01f86b90-1f59-4c42-8f42-dd73cde92f86	1075-113-4	apartment	\N	160.08	\N	1063792.00
726f70e8-94b5-4814-ac95-b77a7dc79940	62df81b8-3642-404c-bc42-06691d838a84	1074-112-1	apartment	\N	391.36	\N	2475200.00
dc8bd233-2a01-4f78-b095-77347d248b0b	62df81b8-3642-404c-bc42-06691d838a84	1074-114-2	penthouse	\N	924.06	\N	13405473.22
58eea775-2c5f-4fd0-874f-83611d86b904	fe77a9ad-902c-4ff5-b53c-6995d93d9a82	1069-111-1	apartment	\N	74.14	\N	409360.00
89c7e017-81a6-4260-b17c-54773593b766	fe77a9ad-902c-4ff5-b53c-6995d93d9a82	1069-112-2	apartment	\N	150.00	\N	557600.00
0ee9f0a0-c046-4f44-8d39-87a2b1d1bb24	29bd3b7f-b18a-477c-a63e-a527e072306b	1066-111-1	apartment	\N	538.73	\N	380800.00
e9e299db-cbdc-4abc-ba27-d5e240ac6334	29bd3b7f-b18a-477c-a63e-a527e072306b	1066-112-2	apartment	\N	87.70	\N	705568.00
cfbaf3ab-4554-4389-839e-b98e418d4a8b	6d077e14-bdc5-4694-a154-8974a8cc99d7	1050-112-1	apartment	\N	100.00	\N	1088000.00
97196fe4-4db4-4234-a408-9504f5c234a4	e05249ec-eca3-4d29-a295-f9d2f16a3a37	1043-113-1	apartment	\N	501.58	\N	13328000.00
4fe777ee-a97a-4406-866f-730f4f11c19d	e05249ec-eca3-4d29-a295-f9d2f16a3a37	1043-114-2	penthouse	\N	696.68	\N	14144000.00
d1a48262-2dfd-4768-bce8-d92a092cfed2	82418342-ba93-4590-befc-661bd439d04c	1024-111-1	apartment	\N	74.79	\N	484160.00
6c6a47ae-7cf7-47ae-ae2f-ca5c4c33d35d	c03745a7-3cd9-4289-9ec4-761d6d99aa72	1021-110-1	apartment	\N	30.00	\N	149600.00
6e959f52-af4d-4c8e-a0d2-1d2ff7d0cba5	c03745a7-3cd9-4289-9ec4-761d6d99aa72	1021-112-2	apartment	\N	748.00	\N	285600.00
d0454988-7438-4963-aa85-774e33889241	99425d04-683b-483b-9d8f-2e87496bb320	1013-111-1	apartment	\N	70.98	\N	476000.00
89aae3ef-34ed-4e16-b204-7f50f0f0561d	99425d04-683b-483b-9d8f-2e87496bb320	1013-112-2	apartment	\N	109.00	\N	748000.00
a622ad12-9fba-47da-a4ab-f3e8c66a6826	86319fbe-c92d-4202-ba22-be51cd3680dd	1010-110-1	apartment	\N	41.06	\N	163200.00
9c9b12c9-74ca-4a1a-abbe-64870b402a96	3779ba2a-e60f-4d70-8df0-317880f89af2	1008-111-1	apartment	\N	176.98	\N	616896.00
1dfed683-a86e-4fcd-89fe-443447daa1ee	3779ba2a-e60f-4d70-8df0-317880f89af2	1008-112-2	apartment	\N	276.11	\N	783360.00
9f948701-971d-442a-9f6e-a4a2b6827555	769a61b0-4827-486a-b442-33ae5ff1d588	1007-111-1	apartment	\N	109.63	\N	288903.17
964224dd-7fff-47a2-ac65-f5223e2b17d3	2db6dfbe-133b-4c56-92d1-b5c0564f139d	998-110-1	apartment	\N	43.00	\N	299200.00
6832edcb-6fa2-4589-a4b7-2e477b85e5ae	2db6dfbe-133b-4c56-92d1-b5c0564f139d	998-111-2	apartment	\N	64.02	\N	333200.00
c1380dac-cec5-42f2-a2df-a3c4e7c14c73	168dff19-de72-435e-80d9-a0f9e66cb4e4	996-111-1	apartment	\N	110.66	\N	626688.00
a7849509-0c2f-42cd-ba3e-dd5a1370ef94	168dff19-de72-435e-80d9-a0f9e66cb4e4	996-112-2	apartment	\N	149.47	\N	806480.00
5dc74d3d-bb42-49de-978a-770d6bdd5200	6f1ffd6e-3ed6-4033-965d-5926d48146ba	981-112-1	apartment	\N	104.05	\N	339982.05
b0edb655-adbd-407b-8ad0-7e0fdf1f4465	73d401c3-c80e-4d92-b892-579c49db3fbe	979-111-1	apartment	\N	150.50	\N	466208.00
9b701ab4-2888-4048-98de-ad6caed39442	73d401c3-c80e-4d92-b892-579c49db3fbe	979-112-2	apartment	\N	125.98	\N	652800.00
03439a08-ee72-4325-bec8-f76b7e59a411	9f005675-3a04-4ae3-bef8-89b48b97f08c	978-111-1	apartment	\N	75.48	\N	429760.00
a536ca83-2879-40b4-8e5c-5692fe5ba842	9f005675-3a04-4ae3-bef8-89b48b97f08c	978-164-2	penthouse	\N	257.80	\N	985836.80
aa24f9e0-7fd3-43a0-9a73-de2da64d43cd	2e4e1bca-0606-422e-83bb-59eb73ad0069	976-112-1	apartment	\N	101.73	\N	1047200.00
388b7c7c-83c7-4a3d-aa65-3b7042eb175d	f27ee6c5-0af0-41ca-865c-805e82080120	975-110-1	apartment	\N	44.60	\N	209440.00
f8171a6d-4244-4cdd-aadc-c05a164ed754	f27ee6c5-0af0-41ca-865c-805e82080120	975-111-2	apartment	\N	64.49	\N	285600.00
38da2f2f-a8a5-4be6-b03e-4a1ec402964f	af070710-bf6b-47b1-8279-211ea1f12f40	968-112-1	apartment	\N	147.81	\N	1942865.54
49e18288-bef9-4a71-b7b1-67d716213955	9d134e3e-11a8-4481-bdc6-1693928e15dd	966-111-1	apartment	\N	63.02	\N	748000.00
85898c98-612c-4382-b97d-2bf4b8ac889d	dfd87bf2-bbab-4bef-b5bc-f34de4e197c8	962-110-1	apartment	\N	44.89	\N	168640.00
19019867-f302-4cc1-8165-3c261914672d	dfd87bf2-bbab-4bef-b5bc-f34de4e197c8	962-111-2	apartment	\N	74.85	\N	266560.00
eb9216d1-2166-41fb-9387-b76691c0e1ad	215df368-2544-4a81-89d3-6030028d4f5e	957-112-1	apartment	\N	87.70	\N	380256.00
949e5dda-5c53-4e27-b983-129c263ddbb4	87fc0a56-278e-43e5-9b00-bb36272b036d	954-111-1	apartment	\N	57.95	\N	230928.00
64492a3f-0361-4abc-a51c-a6fb2ab7b67d	f329e459-531d-4663-ae84-40940e818fda	950-111-1	apartment	\N	128.95	\N	518160.00
6e678679-581f-46aa-9b48-2caf2bf60f09	f329e459-531d-4663-ae84-40940e818fda	950-112-2	apartment	\N	157.01	\N	992800.00
8320351e-698a-45f1-ac24-4b095f233742	f329e459-531d-4663-ae84-40940e818fda	950-114-3	penthouse	\N	277.77	\N	2069104.00
de60463a-4dcb-407c-8bbb-d50dd1623a82	e1fac8c6-8dc6-4f33-be50-5812a38918ac	943-112-1	apartment	\N	123.07	\N	870400.00
5badb459-2014-4b21-bbb4-8ab9e8e60db7	3f6deca2-42c7-4855-a5c6-a056bfae7192	941-112-1	apartment	\N	2038.04	\N	1686400.00
ce84699e-3cc6-419d-b8da-461e827d2b14	3f6deca2-42c7-4855-a5c6-a056bfae7192	941-113-2	apartment	\N	532.80	\N	5712000.00
50a287c7-a112-4815-bf38-09b032994ed6	c49210be-0e6a-4b29-a8db-b58b7fb3c07b	935-112-1	apartment	\N	72.20	\N	296480.00
5d3ac673-7fe4-44e0-9719-e79d845a17b2	cabf0b04-b982-48bf-907b-8a1ab74e5822	928-111-1	apartment	\N	804.00	\N	660960.00
20d25a40-4926-48cd-8d2d-f7aa9e8329e7	cabf0b04-b982-48bf-907b-8a1ab74e5822	928-113-2	apartment	\N	211.54	\N	2176000.00
0da225f6-9b8c-46d2-976d-5d0f8fbb9025	f72fb721-5a55-473e-8585-fd7051771940	918-112-1	apartment	\N	118.08	\N	1768000.00
6bcf6926-bc01-4833-937a-670cf23ec1e2	a78b4d3d-5f18-4424-a9da-a432efd64ee4	916-110-1	apartment	\N	47.20	\N	456031.12
58978df5-a61c-46e1-b2b8-2751861dbd1c	a78b4d3d-5f18-4424-a9da-a432efd64ee4	916-111-2	apartment	\N	88.07	\N	604353.54
83dc82cf-3643-43a5-8ede-80c05a4d22d6	a78b4d3d-5f18-4424-a9da-a432efd64ee4	916-112-3	apartment	\N	107.23	\N	957535.20
bf6caad8-1cb6-4eeb-882e-5ef59c66b425	a78b4d3d-5f18-4424-a9da-a432efd64ee4	916-114-4	penthouse	\N	562.39	\N	8232841.60
1099b882-1ebb-4c3a-b5dc-3529d4c49583	97631918-a0a0-42f1-8d6c-a5492a13bee5	915-112-1	apartment	\N	112.88	\N	1088000.00
02985c16-6232-47e2-974b-f3ad60cea576	02aefe3b-7ad6-4f3e-8ba5-618819b13e69	904-112-1	apartment	\N	371.08	\N	1387200.00
f9058c6e-9701-4ba4-b37d-859ba8234662	eb711164-d540-4985-a591-3ab870cb86c0	893-112-1	apartment	\N	122.73	\N	1087877.06
7e8b0cb5-2dd0-430a-8a46-12d02f2bbd02	7eb596ce-7130-4162-b88b-f566025dbfaf	892-112-1	apartment	\N	121.52	\N	1264677.06
96f2d4a0-e74d-4106-b6c9-841bb3be88ab	7eb596ce-7130-4162-b88b-f566025dbfaf	892-114-2	penthouse	\N	847.65	\N	12783877.06
81801ddf-8b27-4a3a-a510-4190b53af43c	72428705-80c9-4bd0-a0d4-94d6232a0747	884-112-1	apartment	\N	122.26	\N	1767999.73
1b2f984a-f0cf-4237-b198-69a63114ac10	72428705-80c9-4bd0-a0d4-94d6232a0747	884-114-2	penthouse	\N	464.79	\N	6799999.73
9c82054f-3e9d-42b2-b9a8-330c37298e58	82f81557-8780-4f88-8fce-d3586635706a	881-110-1	apartment	\N	32.61	\N	244800.00
1c5eeff8-8519-4c88-8183-fae45150a9f6	2fee53ac-cb7d-49ee-8437-7c0c219f2982	874-110-1	apartment	\N	40.00	\N	299200.00
5b07682f-dace-4e28-a17f-cdd36d73a7be	38bb72d6-ced1-4410-b201-f232ec66c83a	868-112-1	apartment	\N	129.55	\N	1033600.00
dad4fbd1-bd24-4490-8980-9f9c8f434259	11cf1966-6cac-421d-99bc-0a7ab63c8777	867-112-1	apartment	\N	124.80	\N	254808.24
ab947232-0ec1-4701-a072-4289a838313d	11cf1966-6cac-421d-99bc-0a7ab63c8777	867-113-2	apartment	\N	134.92	\N	332935.34
8d6929f6-3e9a-48a6-869e-e0f36aac14ea	9b8bcf41-74e8-4af8-b113-4c2111a110ba	862-111-1	apartment	\N	55.00	\N	388960.00
8b2fa721-fc55-451f-a098-b31194bbc487	a8581e8c-0025-4005-b298-36263a9de59e	854-111-1	apartment	\N	963.26	\N	544000.00
f2fe3d50-1619-42d4-a49a-70f921fd2ee9	9475f76d-b664-461e-8052-72f8b2adbc97	847-111-1	apartment	\N	133.20	\N	544000.00
6e682ddf-fc06-46d6-8233-27dd0567a0a0	9475f76d-b664-461e-8052-72f8b2adbc97	847-164-2	penthouse	\N	225.74	\N	865130.82
25bdaece-e7e9-4206-9e40-95f9e57dfbb4	da5b1346-0f7f-4c7a-aa9a-71ffafc956c7	842-112-1	apartment	\N	10.22	\N	612000.00
83058bfb-f263-4594-8d6f-9df576651aab	709de45c-8af9-46a0-8bfc-1109f3b9e144	841-111-1	apartment	\N	48.68	\N	380800.00
97dab92e-8d34-44be-9daf-6dd587b8052e	2cbc9d87-4493-48ce-9abe-3f38935d5ff9	840-111-1	apartment	\N	513.00	\N	326400.00
a058bf5f-bf27-4f7d-baa2-55764c8d766e	2cbc9d87-4493-48ce-9abe-3f38935d5ff9	840-112-2	apartment	\N	75.09	\N	530400.00
59bf8369-3702-4474-987b-4d8a6e670f7e	b90b17f4-1575-4c4b-a0eb-64f12cf581dd	839-112-1	apartment	\N	108.56	\N	707200.00
fb2b6171-7b35-4293-a287-363803146179	ca434548-bd03-4f14-ba37-c4ae9ea26e50	838-110-1	apartment	\N	44.95	\N	255680.00
bc903bd1-f87b-42d2-b04c-9cdc1daf6b67	7eeb2ced-a9b2-4d96-b3db-0387d16feb01	835-111-1	apartment	\N	87.98	\N	402560.00
7e81d838-4041-44c3-8584-e8765e4da464	7eeb2ced-a9b2-4d96-b3db-0387d16feb01	835-112-2	apartment	\N	123.56	\N	701760.00
05b05392-7f90-4e0b-b12a-14e336a9fe21	1c11e9b6-2a76-4298-a9d8-ed1a310fc070	833-111-1	apartment	\N	50.67	\N	348160.00
d59d7924-960e-4521-9dca-fc0126e256a3	814e075f-e81c-443b-9d9b-1aebfc67b45e	831-111-1	apartment	\N	611.00	\N	394400.00
a5ac47fa-f3ea-4b21-960b-8788cb49e3c1	814e075f-e81c-443b-9d9b-1aebfc67b45e	831-112-2	apartment	\N	89.65	\N	554062.91
ae537ddd-2036-4abf-96f4-b32afd084403	6917c729-e5ae-4926-a8d3-3438b23a8a69	827-110-1	apartment	\N	33.72	\N	188659.20
70136c62-7fcf-46dd-92ff-a4e0e88dfb3b	8a8ca2d4-fa7c-4e82-8138-57125825efe3	821-112-1	apartment	\N	2440.00	\N	4896000.00
bf699c53-905b-443c-aaeb-420be8af0b81	8a8ca2d4-fa7c-4e82-8138-57125825efe3	821-113-2	apartment	\N	330.36	\N	6664000.00
048af05c-4d28-4ea0-9d9a-00d35a1bb6b6	8a8ca2d4-fa7c-4e82-8138-57125825efe3	821-114-3	penthouse	\N	424.00	\N	10336000.00
d833fe16-7861-4fe7-afe7-899017212dcc	5de448df-978f-4ddc-8c8f-480072e6c97c	798-110-1	apartment	\N	38.46	\N	416160.00
25e63524-5840-49a9-a5ea-5e9efbd9b2d3	5de448df-978f-4ddc-8c8f-480072e6c97c	798-113-2	apartment	\N	155.00	\N	1577600.00
2a87c0bc-f6fc-40f9-80dc-9fb35c3dd98e	bada2f6b-307e-4692-885e-32f4db327aa6	797-110-1	apartment	\N	386.00	\N	176800.00
27101410-243b-4348-82d8-4ac55b36b3e1	bada2f6b-307e-4692-885e-32f4db327aa6	797-111-2	apartment	\N	775.00	\N	312800.00
5cb65f95-cb27-4c58-b8ea-99abe999359e	bada2f6b-307e-4692-885e-32f4db327aa6	797-113-3	apartment	\N	1517.00	\N	543728.00
f89605d8-406e-4e88-a5ac-23905a75159e	a3de5ac6-38a1-4531-9a6f-349219094109	793-113-1	apartment	\N	512.81	\N	6745600.00
ffce8f0d-f08d-4197-b65f-4d5e47cb1421	91f18bb3-cc6d-4e24-a841-f985969a4b24	792-114-1	penthouse	\N	607.31	\N	13600000.00
c678569a-e3d5-4174-a34f-689167cf870f	08c1ace8-58b3-440b-9f76-b9527509f325	781-112-1	apartment	\N	102.66	\N	516800.00
53dd2e38-d5fa-478e-95ee-45733eaa33bf	bb8c74c9-84b6-4037-87e3-c320e756b37a	780-112-1	apartment	\N	55.00	\N	233920.00
9e27d9a0-9c10-4998-8749-20a186d7ea84	b1447e6f-4866-40ce-9a5d-4f1ba9f39329	755-111-1	apartment	\N	43.80	\N	326400.00
06953de0-a172-454a-810b-2d5d02c45a34	2b89a573-c3ca-4344-b789-6667e845eab0	748-110-1	apartment	\N	41.34	\N	269280.00
3fa27e0e-7346-47be-a5ae-6b1e4c15524c	2b89a573-c3ca-4344-b789-6667e845eab0	748-112-2	apartment	\N	202.99	\N	1067600.00
df75cb5e-656b-4999-a8b4-5dfd3155cba0	e011fac7-a55e-46a8-9348-4ca2d0c96d4b	689-110-1	apartment	\N	40.13	\N	149600.00
ce981065-2bef-49fb-bf57-55f3173e7a1a	4329c50f-d095-4511-a2f4-0652e52b1ada	668-110-1	apartment	\N	38.01	\N	307360.00
3898b53c-dffe-439b-8e7b-2e8ed6f1c212	44a55ccf-94c7-4361-9f9e-64ec550015d2	665-110-1	apartment	\N	46.51	\N	340000.00
051fce3b-01bd-45b2-a2e2-fe4a31b3c074	44a55ccf-94c7-4361-9f9e-64ec550015d2	665-111-2	apartment	\N	87.57	\N	557600.00
ce72c5ad-3dfe-4d4e-9e91-c05d93191174	44a55ccf-94c7-4361-9f9e-64ec550015d2	665-112-3	apartment	\N	135.08	\N	952000.00
5aab8c73-b269-4b64-b8b3-8b5be782f629	938b16aa-d36f-4e2f-a731-52b6f88f6223	663-111-1	apartment	\N	97.18	\N	350880.00
7fc44e58-d0a6-4587-bc89-a3febde66965	670a72c6-99cd-4a3b-b1bf-a3b51de388b0	657-113-1	apartment	\N	146.00	\N	924800.00
6b66afcc-4ba7-463c-adef-459e9344bdb5	52824e6f-4975-4843-bb0a-55d37baaf30e	648-110-1	apartment	\N	48.33	\N	217600.00
6d8b975e-6b1f-48fc-8f90-4b74cda802bf	52824e6f-4975-4843-bb0a-55d37baaf30e	648-111-2	apartment	\N	97.49	\N	570914.40
66247ca0-4f06-40e6-9608-4ec6132a3269	3fd1ab36-28d7-46d3-90cd-2f1d1399976b	639-111-1	apartment	\N	108.60	\N	952000.00
f4344e0b-b563-4286-b281-b08b5933117a	3fd1ab36-28d7-46d3-90cd-2f1d1399976b	639-112-2	apartment	\N	125.99	\N	1496000.00
9b734cb2-7f27-4f18-b6aa-4d3f02b2200b	3fd1ab36-28d7-46d3-90cd-2f1d1399976b	639-113-3	apartment	\N	255.11	\N	2312000.00
071110ac-876e-4312-91b3-eded4d76d3ae	3fd1ab36-28d7-46d3-90cd-2f1d1399976b	639-114-4	penthouse	\N	1412.31	\N	16539993.60
8874ce6b-ce3a-4698-8cc6-89f1b93a7bfa	74435ce9-04e6-48cd-a709-8d8c14982aca	625-113-1	apartment	\N	863.35	\N	20672000.00
90c4b7c5-05da-4bd9-86fe-c80edf3d1272	74435ce9-04e6-48cd-a709-8d8c14982aca	625-114-2	penthouse	\N	977.99	\N	14144000.00
48c7023b-8450-41d8-99ba-af34138a6852	713286cc-4bc9-465d-84f1-33c115b6c41f	622-110-1	apartment	\N	43.30	\N	195111.04
38a9a03a-0a32-405a-8352-7d0fc92777da	0dccdd31-fc25-4044-9b00-d7d77ff6f823	619-110-1	apartment	\N	139.73	\N	2584000.00
be79af0e-1e38-4dbc-8301-17bb2e5a8d98	0dccdd31-fc25-4044-9b00-d7d77ff6f823	619-111-2	apartment	\N	79.43	\N	1604800.00
3b183c51-6587-4cec-a109-01736bfbffbc	0dccdd31-fc25-4044-9b00-d7d77ff6f823	619-112-3	apartment	\N	205.10	\N	2080800.00
27010ad4-ec44-422e-8a8e-154956f51d48	b41a5875-1dd3-4a12-b7b3-219c05d1f0a9	618-114-1	penthouse	\N	464.79	\N	8840000.00
9092b609-35d3-4226-a1ad-7a28072cab83	8a62e849-eaae-4345-a285-9a5a7446761f	598-110-1	apartment	\N	41.75	\N	225760.00
8e6d1117-178e-4473-95f2-7d77519d9e1d	23e0868e-e635-4297-9b2b-7209b4db9d5e	595-111-1	apartment	\N	84.54	\N	455056.00
b55c35e3-79fd-4fe3-a038-aab8a146480b	23e0868e-e635-4297-9b2b-7209b4db9d5e	595-112-2	apartment	\N	124.49	\N	802400.00
dfa252bc-0d44-4abe-b5bd-aa9fb8155bb0	2761bf02-a02a-4f96-be31-2f3dca138813	582-110-1	apartment	\N	34.47	\N	231200.00
d486896d-48d9-4eeb-b21f-5cf3ad178b91	a8e58df9-684f-46cd-ae28-a58e31faf550	576-114-1	penthouse	\N	445.19	\N	7195569.60
f14e87e0-ccdb-4f28-ab8a-efe18d6af483	a8e58df9-684f-46cd-ae28-a58e31faf550	576-115-2	penthouse	\N	626.63	\N	9306715.82
c7c464b7-1dcf-405a-bd26-92d43fd4e333	7584f284-f239-470b-bee5-fd088df784e5	574-114-1	penthouse	\N	468.51	\N	1414400.00
0f7f0d86-4b75-4e84-a9f0-dd2650b072a6	502f8214-525b-4c99-8085-ab07f002d7b0	573-114-1	penthouse	\N	541.00	\N	14960000.00
3ba82e66-c168-4455-add7-6ace02d87a4b	8c4313ee-0d37-48cd-8668-d67e75b21c44	568-112-1	apartment	\N	171.87	\N	765151.78
2770079f-2031-4621-8146-cc2df6b1583d	8c4313ee-0d37-48cd-8668-d67e75b21c44	568-113-2	apartment	\N	171.87	\N	1221385.54
35de9be7-acd5-4942-8534-65ae79ab0987	8c4313ee-0d37-48cd-8668-d67e75b21c44	568-114-3	penthouse	\N	250.84	\N	2748021.98
90c28ed7-db12-4823-9618-f43b152010e4	cba7ac68-bde0-4803-88bf-c0543d554ff0	522-113-1	apartment	\N	209.96	\N	1278400.00
1f4a9638-7dee-45d1-9c39-3fdc336ac7a7	c52c82b2-3d68-47ac-82c1-02959100c1ad	513-112-1	apartment	\N	121.12	\N	462400.00
ca04e5d9-40b0-4b84-bbb9-1e2f08365fc5	7b602d8e-0eb5-45ae-92a7-2b9d9d4c4fe3	512-164-1	penthouse	\N	85.38	\N	874993.54
9dd5bffd-d05e-4316-82c6-bfe96af5ada6	0643ef9a-7a13-4387-82c0-f49a44518b31	509-111-1	apartment	\N	744.00	\N	802400.00
1867ae1b-668d-4dec-8ca1-9279a6c3305a	0643ef9a-7a13-4387-82c0-f49a44518b31	509-112-2	apartment	\N	103.03	\N	1496000.00
850bb8ce-bbaf-4263-8449-8bac473f6a0a	0643ef9a-7a13-4387-82c0-f49a44518b31	509-113-3	apartment	\N	157.94	\N	2040000.00
8959d6fc-abdc-4d9d-9dc8-b45aa4d740d8	b003aad8-1fe2-45d6-acfe-d8e1433a9c4e	483-112-1	apartment	\N	109.97	\N	788800.00
b84fe106-721d-415f-8856-dee604d8abf6	b003aad8-1fe2-45d6-acfe-d8e1433a9c4e	483-114-2	penthouse	\N	293.02	\N	2856000.00
c4b03371-03b1-49f0-8f35-9ee40599dd67	7f6ef1ea-51b9-4e4b-b098-61dcbd6c199a	481-111-1	apartment	\N	66.78	\N	350880.00
40217c49-3000-4f1c-b1fe-0820a9c3896e	996668a5-1990-460b-8599-7adba639eb9a	477-111-1	apartment	\N	79.88	\N	258400.00
e99a1767-ce40-4a9d-b7d8-1fd434a7a9e0	2eea67a6-67ad-4778-a7f3-6e0623542ce0	466-112-1	apartment	\N	189.46	\N	2584000.00
a1224188-6d05-4fe8-8423-09de64eb0759	9999f1e2-373b-4491-a5b5-900bd3422dc6	455-111-1	apartment	\N	71.96	\N	350880.00
3ddcf89a-5194-4ef5-ba32-14326811526a	9165060a-7e27-43fa-8a5b-48d03cc807d5	450-111-1	apartment	\N	70.33	\N	693600.00
4f4d2b85-1839-402e-ab79-a5226a581e10	9165060a-7e27-43fa-8a5b-48d03cc807d5	450-112-2	apartment	\N	109.35	\N	1087997.28
95cec2e3-f725-4a6b-8ab0-be98c0a5bdee	b918590e-d569-4f85-8e64-d74c52981475	425-111-1	apartment	\N	62.71	\N	408000.00
5903eef0-0d31-4e8a-80a9-a55bcc835207	3e78e08e-682a-4c53-b4cb-64e5c9d48801	418-111-1	apartment	\N	709.00	\N	516800.00
17924745-d132-412b-a3c0-fae3f14fabd1	af8d45f0-856a-44bf-8ef5-2ab71cc9aac1	416-112-1	apartment	\N	1164.00	\N	775200.00
551527de-508e-4361-8d1b-4b80c6edab8b	313ac1af-3c7d-4bc4-bff7-1c22a49085ec	386-111-1	apartment	\N	62.68	\N	244800.00
4bc266cf-afc7-4e77-973e-2c05989464c8	98fb2117-586c-4f68-973d-bda7fc50ca85	384-111-1	apartment	\N	115.27	\N	548624.00
a8bc0f9d-b534-4377-8a10-214991a0f547	98fb2117-586c-4f68-973d-bda7fc50ca85	384-112-2	apartment	\N	115.00	\N	534480.00
1df11923-63f1-4aaa-b692-3d4ae7cfee20	cd2246e8-2c71-41bc-a180-60482a0ec1f7	377-113-1	apartment	\N	1672.00	\N	1305600.00
487a021e-0346-430b-97ee-627f3bb5f27a	98711a64-ab95-441c-96ea-f06197427624	375-110-1	apartment	\N	49.06	\N	271999.73
92619c14-b83d-4fad-bb85-5641596f1a99	c620da31-9289-48f0-b7e3-c9e29f80f705	371-164-1	penthouse	\N	155.95	\N	640079.92
7cfd4e82-80ef-4fa4-af7c-8b8895610dc6	8c11ad58-a537-420b-8707-ac4f27fa3f8d	370-164-1	penthouse	\N	830.70	\N	311609.46
82c43caf-4a78-431a-ae2b-e68640ca0d8b	75dc2754-4aca-4162-b46b-789d2c5be1ad	363-110-1	apartment	\N	33.04	\N	224400.00
15a33a6d-086e-4f75-b18a-4395f12e95a1	d126c9e5-b270-4bde-aba2-50e2781b2dc0	361-112-1	apartment	\N	110.47	\N	484160.00
66a6987a-1cb4-4d3e-a1b2-cf1b861664e4	8f5104a2-93d8-4fba-a596-f1b2f0d78d16	348-110-1	apartment	\N	38.09	\N	184960.00
9d1dd608-d4f6-4688-a961-e391d0d207bf	b75d2e03-bce2-491d-9694-7a13eff9f0f9	346-111-1	apartment	\N	106.00	\N	1521838.64
095f5ffe-ba29-4e3d-93ab-43396294c357	b75d2e03-bce2-491d-9694-7a13eff9f0f9	346-112-2	apartment	\N	165.00	\N	2126953.23
3012bee8-8fbb-4188-8ae0-7d6d9d3210c7	b75d2e03-bce2-491d-9694-7a13eff9f0f9	346-113-3	apartment	\N	190.00	\N	3400000.00
4a58082b-4071-4e0b-8e29-19bd309d5eff	8b625f9f-87e3-46cb-971d-0c62a4b6c949	342-110-1	apartment	\N	47.98	\N	337280.00
bda36388-4836-465b-ab2f-13b563afc94a	8b625f9f-87e3-46cb-971d-0c62a4b6c949	342-111-2	apartment	\N	93.56	\N	571200.00
0c1c2568-2514-4910-872b-bf45f887b648	c3f6ae6d-37c9-4ebc-97a7-b20f4b553ee4	332-111-1	apartment	\N	815.00	\N	598400.00
66909144-640d-40d6-9e6b-696dbee501a3	ea95774f-dd5f-43b2-80c7-d48da30253ae	311-112-1	apartment	\N	111.21	\N	897600.00
7dfdc3ec-0850-45c8-ba15-89af131a233b	0e211dc3-13c2-4b55-a9f1-ebae01dffcdf	293-110-1	apartment	\N	59.20	\N	320443.20
0a7d22e8-3117-445b-a873-18e472fbbe97	0e211dc3-13c2-4b55-a9f1-ebae01dffcdf	293-111-2	apartment	\N	107.28	\N	435200.00
5e6d4e00-35d4-4ca0-ae19-c9f97e860487	0e211dc3-13c2-4b55-a9f1-ebae01dffcdf	293-112-3	apartment	\N	140.73	\N	793424.00
ce58c0a1-05d4-445d-a9aa-0ce34b1355cf	0e211dc3-13c2-4b55-a9f1-ebae01dffcdf	293-113-4	apartment	\N	187.11	\N	1123904.00
fc29c762-ff01-4ed0-950a-995c76751952	0e211dc3-13c2-4b55-a9f1-ebae01dffcdf	293-114-5	penthouse	\N	260.21	\N	1500080.00
9e2c8f78-2097-45a0-b3c5-41c5607c1ede	249233b1-08e4-4ade-984c-c119a95e3d7b	280-110-1	apartment	\N	53.16	\N	248757.60
e35133eb-fc59-424b-8813-853a286af758	249233b1-08e4-4ade-984c-c119a95e3d7b	280-111-2	apartment	\N	105.03	\N	291312.00
745891af-af22-4c65-b065-56b6c41a0e5c	249233b1-08e4-4ade-984c-c119a95e3d7b	280-112-3	apartment	\N	121.92	\N	601188.00
4523bf83-ccdb-4a43-afeb-75e550ac7eda	178acd50-5962-4285-a7d7-28b441b20b8b	274-112-1	apartment	\N	324.52	\N	753788.16
ae2576d6-e1bd-4805-879f-f8a63ea920a1	178acd50-5962-4285-a7d7-28b441b20b8b	274-113-2	apartment	\N	449.09	\N	2663696.00
6728c370-1ceb-460d-a04a-7839fb2ce0f1	178acd50-5962-4285-a7d7-28b441b20b8b	274-114-3	penthouse	\N	552.97	\N	7042624.00
071dcd7d-1fdb-48ef-8413-eedbaa1f9843	54b5c173-66c6-4a87-864c-d96b3962b740	269-113-1	apartment	\N	148.27	\N	953873.54
4fb7ede8-48fa-4b68-a892-410a68666d7a	33245d67-336d-4731-8d11-d20596063507	268-112-1	apartment	\N	1107.00	\N	783360.00
fec1b35a-9d87-427b-af8c-bf743bcf0c83	3ee9f2f0-9216-4606-829a-c58f96c5cf96	264-113-1	apartment	\N	138.98	\N	1202209.54
3846d5e9-920b-4a11-a56e-e2f5edab3ee5	5b8d3414-7e51-4f8c-a7e2-8886e20b1bfa	263-111-1	apartment	\N	65.79	\N	516800.00
ac2f4faa-9ac7-4936-b454-f911db38d79a	dfee8951-3c4a-4edf-9eb9-c3042ba4573e	262-111-1	apartment	\N	63.55	\N	516800.00
eb73feda-bcf9-48c4-86c0-0b86cf13cd85	dfee8951-3c4a-4edf-9eb9-c3042ba4573e	262-112-2	apartment	\N	104.93	\N	584800.00
b1b53274-1043-4020-83ad-20510ae2cd69	c08dda70-bcce-4b2e-bb19-694009b68d40	252-111-1	apartment	\N	129.97	\N	375734.54
15703c2e-bf5a-4be4-af90-bfdfe02d4da4	c08dda70-bcce-4b2e-bb19-694009b68d40	252-112-2	apartment	\N	87.42	\N	516628.10
6663e152-e55c-4cd7-8f6c-02520969deed	c08dda70-bcce-4b2e-bb19-694009b68d40	252-113-3	apartment	\N	192.71	\N	902768.00
9fe66554-4bd9-4a6b-9d73-ff1138569e4a	5b5d13ef-bcaa-455d-b5aa-d1bb4729e1a4	248-111-1	apartment	\N	70.07	\N	598400.00
dd732d37-27b4-41e2-a27f-a601961b46be	5b5d13ef-bcaa-455d-b5aa-d1bb4729e1a4	248-112-2	apartment	\N	108.52	\N	1006400.00
ef31005d-d536-4e55-b672-2c70f2a82a23	5b5d13ef-bcaa-455d-b5aa-d1bb4729e1a4	248-113-3	apartment	\N	135.92	\N	1496000.00
13f271a1-aa7c-4712-83ef-53d24d25627f	6f2a4322-b100-4a18-ab7c-3beda4bc4da4	244-111-1	apartment	\N	72.65	\N	338640.00
b0594424-a17e-4bfd-8ba2-5f81511b58e1	ed93a3bb-9402-46de-99ea-dd880199b0bd	243-110-1	apartment	\N	43.63	\N	312800.00
cbf970c6-4754-4fdb-8d26-dad9bfe363cf	ed93a3bb-9402-46de-99ea-dd880199b0bd	243-111-2	apartment	\N	183.31	\N	529856.00
b23c5d07-7270-4a8e-8821-2e1776a30656	ed93a3bb-9402-46de-99ea-dd880199b0bd	243-114-3	penthouse	\N	772.59	\N	7505296.00
cee47036-3caa-4e53-9897-5aeda628c943	1d57b29c-0cc0-4ece-af23-4fc653af5bfe	234-112-1	apartment	\N	122.00	\N	971040.00
cfd3c280-2c0a-4490-b109-5d9944d980ba	f64e27b6-acb8-4ee7-885c-c9e7e8af4079	232-113-1	apartment	\N	620.47	\N	5957888.00
93f0e1ed-2c24-4907-ab9e-ee62ef109a41	f64e27b6-acb8-4ee7-885c-c9e7e8af4079	232-114-2	penthouse	\N	656.15	\N	7404112.00
23609972-edff-49ee-a5b6-f94abafea502	f64e27b6-acb8-4ee7-885c-c9e7e8af4079	232-115-3	penthouse	\N	716.34	\N	11245840.00
a213787e-7ea9-4612-90df-4ddcab612b57	fe0a51ea-2260-49ff-b37b-3b05691821c7	231-112-1	apartment	\N	120.23	\N	859519.73
d8fe36e4-247d-4076-afef-3e6427e84246	fe0a51ea-2260-49ff-b37b-3b05691821c7	231-113-2	apartment	\N	304.00	\N	4637534.72
d85a5f1d-32e5-4c8c-b225-2837e5761c77	a9a3de60-9b10-40e0-b6da-1fa4d5c3da95	221-111-1	apartment	\N	93.62	\N	707200.00
96df07df-a204-4186-b443-b7760a321992	a9a3de60-9b10-40e0-b6da-1fa4d5c3da95	221-112-2	apartment	\N	167.97	\N	1077120.00
bc68e57b-6aa6-437c-8758-25ffb137fa9e	a9a3de60-9b10-40e0-b6da-1fa4d5c3da95	221-113-3	apartment	\N	172.71	\N	1824488.96
15bd2cf7-a71f-4e77-ae2a-65259e1a0616	44880829-324b-40d7-98eb-f140fb28ba75	206-111-1	apartment	\N	55.00	\N	544000.00
28a70bfc-7e90-40f0-a55f-9754483f342b	586f35cd-a740-41a5-8071-c349227dc903	204-112-1	apartment	\N	2109.00	\N	1414400.00
f8e01330-c364-49be-9f0b-56c9aa9b99fe	9bb8174d-7748-4074-bd33-9f11635aa7fc	185-111-1	apartment	\N	58.92	\N	233920.00
8371d350-a547-454a-b28a-2962efdf90be	e394900c-b033-4a45-b541-cd9332f792c9	181-111-1	apartment	\N	58.79	\N	244800.00
95ccc85f-d656-410e-b6fb-9b94ca589078	73083f2c-6df6-43ee-845e-b99c75dd1bfa	179-110-1	apartment	\N	41.81	\N	333200.00
39825d54-7475-445f-bc1e-c097a4757278	73083f2c-6df6-43ee-845e-b99c75dd1bfa	179-111-2	apartment	\N	45.40	\N	408000.00
de43a321-addf-4ec0-b725-dcf7e9ed7e7c	09f0eebf-366b-492e-a127-e5beda172742	175-111-1	apartment	\N	88.57	\N	595680.00
0dd343e2-35de-4622-ac5e-3945556829d6	d340e31d-0122-464a-a59e-6afa025955c0	165-110-1	apartment	\N	105.35	\N	1332800.00
41415fc1-7213-4a39-8fdb-dcc5532ab24a	78709f68-c1cf-4c72-8823-3712e2e9ab68	164-113-1	apartment	\N	157.01	\N	2040000.00
6ba49d0f-56ab-4626-a37c-30d1db56eebf	25193a86-3cd8-4b1f-a66c-870275163f2c	163-111-1	apartment	\N	71.04	\N	802400.00
2c755e34-6c0a-4e45-8699-a8067902e6bd	2e625f94-bde7-45cd-af6a-31575c1f7a9e	155-111-1	apartment	\N	79.62	\N	502928.00
0a08ce45-f094-428b-a430-13531814e42e	3983fef4-3404-4a9f-8172-197684c2d5a0	141-111-1	apartment	\N	114.46	\N	896784.00
dd7ae242-1a21-464f-a90c-84c5463db058	3983fef4-3404-4a9f-8172-197684c2d5a0	141-112-2	apartment	\N	141.40	\N	1388288.00
1e968217-c1d0-49a4-9ff0-07fb1682dbe6	3983fef4-3404-4a9f-8172-197684c2d5a0	141-113-3	apartment	\N	151.44	\N	1889584.00
74af9069-5422-4bb7-ac58-2acee46533b1	3983fef4-3404-4a9f-8172-197684c2d5a0	141-114-4	penthouse	\N	433.02	\N	5344800.00
d01315c5-c165-47d3-935c-ad8b6efd197a	3983fef4-3404-4a9f-8172-197684c2d5a0	141-164-5	penthouse	\N	311.50	\N	2298672.00
9d2eb579-dd88-4f28-874f-195693f757b3	c19318a2-ed28-4d38-9723-13bbf8449fc6	140-110-1	apartment	\N	39.67	\N	236640.00
a7a949b5-5cf0-49fd-b38c-0d9f3d1db3d8	c19318a2-ed28-4d38-9723-13bbf8449fc6	140-111-2	apartment	\N	88.82	\N	722160.00
b8c4f747-a509-4d3b-9455-4238b9191cf0	c19318a2-ed28-4d38-9723-13bbf8449fc6	140-112-3	apartment	\N	104.89	\N	1124992.00
f61aa620-1e2c-4a7d-8e16-da507b73a120	c19318a2-ed28-4d38-9723-13bbf8449fc6	140-164-4	penthouse	\N	296.55	\N	3464736.00
04998684-487d-4cad-b604-2e30da02f28f	6dbef49f-7f89-4ae0-a88b-732c4824098d	127-110-1	apartment	\N	415.70	\N	244800.00
395fd7e9-e110-47b6-98ec-e82d29613a63	1ef36346-f971-465e-b2e6-d03388f7d04b	121-110-1	apartment	\N	31.96	\N	190400.00
a32a4193-f345-468b-8339-480e68be102d	1f1b5c73-4911-468a-b825-94e151ac1cbe	120-110-1	apartment	\N	34.47	\N	217600.00
dc581438-0c59-4eb9-8f50-89ed2ca7908b	cc72680c-3a69-47b2-802d-70a6507ef2a2	117-110-1	apartment	\N	29.00	\N	176800.00
e5105f25-e4d3-4e00-a3bc-1ed0f33a8c5c	3095ef0a-93d0-40af-965b-ab90f0de2a7f	104-110-1	apartment	\N	29.00	\N	176800.00
a4054c30-1df8-4c87-bb54-07cc8172618b	d90da4db-77f7-4e2e-8632-de6a6af53c5f	89-111-1	apartment	\N	112.88	\N	1072768.00
d64b9d8e-177d-4955-9cc1-e971f3699dcd	a91a6374-6f36-4ae3-a7ee-c231d5bf3876	78-111-1	apartment	\N	115.66	\N	489600.00
c61c4529-9b36-499f-88a2-30d03af6630f	a91a6374-6f36-4ae3-a7ee-c231d5bf3876	78-112-2	apartment	\N	241.99	\N	1146752.00
144ab88e-40f6-4835-aad8-8a5cba8ff8d9	a91a6374-6f36-4ae3-a7ee-c231d5bf3876	78-113-3	apartment	\N	212.16	\N	1219920.00
bc12f15d-e1f7-4a0d-8cf8-b0da4042c5e2	a91a6374-6f36-4ae3-a7ee-c231d5bf3876	78-115-4	penthouse	\N	1359.36	\N	13748784.00
af183a3a-cf70-467f-bd49-b6737b3e5806	4a8f9d0d-efba-4e63-86c5-7277d39a770a	76-110-1	apartment	\N	40.00	\N	217600.00
17d44ac9-9236-497f-bf9c-ef6b52813288	4a8f9d0d-efba-4e63-86c5-7277d39a770a	76-111-2	apartment	\N	76.55	\N	430453.60
c018a3f4-f37c-4550-93c3-322f71030851	391c4ea4-8da5-4a48-9185-20f603875239	64-112-1	apartment	\N	100.41	\N	367200.00
00a8c3aa-98c0-4dee-bcf7-766a08f72ff2	338a5bce-974d-468f-b520-c65674dc3c28	50-111-1	apartment	\N	71.46	\N	285600.00
5c697d3b-f806-48dd-9cae-979a3e11120c	0d604793-e674-493b-bdbf-0ece3c34b3a4	38-111-1	apartment	\N	70.00	\N	584800.00
3edf4741-a33f-4ac7-bbd4-398fb95d178d	0d604793-e674-493b-bdbf-0ece3c34b3a4	38-112-2	apartment	\N	110.18	\N	1033599.73
985ebbff-20b8-4227-a063-84aa960a4953	b2119d98-f819-4ccf-b2d9-db6e973b391f	29-111-1	apartment	\N	83.00	\N	231200.00
7a5b19e8-d4bf-4020-b3a0-6423d92812dd	b0a66ede-a4c5-405c-a9f2-5ef0e451df43	19-111-1	apartment	\N	78.00	\N	204000.00
df4c0596-d831-47e0-a3d1-31cbae3814ea	d51f7e45-1d76-4fe4-950f-b58d69afb023	17-111-1	apartment	\N	78.04	\N	870400.00
74b36d77-c932-47dc-8cb5-06ca581f2cdf	b734b38a-c98d-495c-81de-db101d2c9b1b	16-111-1	apartment	\N	780.00	\N	788800.00
fd9d0ec3-6b27-467b-a04e-c0a45cb578a7	97c4b05d-65e4-4c5d-9201-a54eca43dc7a	14-111-1	apartment	\N	126.00	\N	212704.00
9f870c9d-2592-41c1-aa11-391f0a93564c	56dced7f-ca06-4432-9e26-f9eb770ec21e	7-111-1	apartment	\N	87.00	\N	584800.00
1491c2e3-0fe6-4136-9767-d409bf8f3145	56dced7f-ca06-4432-9e26-f9eb770ec21e	7-113-2	apartment	\N	160.63	\N	1194291.34
57da6396-0dc5-4280-8d38-e84e435a9984	4d8168f2-b2a8-45bd-98e8-d308319ddfb9	6-111-1	apartment	\N	736.00	\N	462400.00
\.


--
-- Data for Name: support_requests; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.support_requests (id, "userId", subject, message, status, priority, "createdAt", "updatedAt") FROM stdin;
ca922894-6ef2-45f8-9d48-a32a8b497c9b	123e4567-e89b-12d3-a456-426614174000	Need Help	I need assistance	in-progress	high	2025-11-01 14:38:50.420906	2025-11-01 14:39:01.360011
\.


--
-- Data for Name: support_responses; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.support_responses (id, "supportRequestId", "userId", message, "isFromAdmin", "createdAt") FROM stdin;
b4b15ed0-ce78-4638-b2d8-177e477d3955	ca922894-6ef2-45f8-9d48-a32a8b497c9b	\N	Thank you for contacting us. We will help you.	t	2025-11-01 14:39:01.342535
98560999-3448-4efe-b595-9fee64bee4aa	ca922894-6ef2-45f8-9d48-a32a8b497c9b	\N	hello	t	2025-11-02 11:23:55.421806
b663e1fc-54cd-4e1b-974f-f960790cc817	ca922894-6ef2-45f8-9d48-a32a8b497c9b	\N	hello	t	2025-11-02 11:30:06.210873
eaeeb5d3-c9d4-46be-bcdb-862b80d0b5ab	ca922894-6ef2-45f8-9d48-a32a8b497c9b	\N	фіахьів\n	t	2025-11-02 11:37:49.948832
be3cfcc5-ee4e-4006-9677-a2a3cf9d27fb	ca922894-6ef2-45f8-9d48-a32a8b497c9b	\N	іфа лд іф	t	2025-11-02 11:37:52.895831
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.users (id, email, phone, password_hash, first_name, last_name, role, status, license_number, google_id, apple_id, avatar, created_at, updated_at) FROM stdin;
9c417a85-ead0-42e6-9c18-0827a9e610a3	dvytvgf@gmail.com	+34662636210	$2b$10$pw0bQjCj9XH6S9iWLB1ToOWwRGsmH4h.gCETRVcFw7MvZ1JtaPVNm	test 	user	INVESTOR	ACTIVE		\N	\N		2025-11-02 13:49:11.724219	2025-11-02 13:49:26.671978
\.


--
-- Name: properties_facilities_facilities PK_210a269572eb965e05e0f637e6f; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.properties_facilities_facilities
    ADD CONSTRAINT "PK_210a269572eb965e05e0f637e6f" PRIMARY KEY ("propertiesId", "facilitiesId");


--
-- Name: developers PK_247719240b950bd26dec14bdd21; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.developers
    ADD CONSTRAINT "PK_247719240b950bd26dec14bdd21" PRIMARY KEY (id);


--
-- Name: properties PK_2d83bfa0b9fcd45dee1785af44d; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT "PK_2d83bfa0b9fcd45dee1785af44d" PRIMARY KEY (id);


--
-- Name: facilities PK_2e6c685b2e1195e6d6394a22bc7; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.facilities
    ADD CONSTRAINT "PK_2e6c685b2e1195e6d6394a22bc7" PRIMARY KEY (id);


--
-- Name: news PK_39a43dfcb6007180f04aff2357e; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT "PK_39a43dfcb6007180f04aff2357e" PRIMARY KEY (id);


--
-- Name: courses PK_3f70a487cc718ad8eda4e6d58c9; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.courses
    ADD CONSTRAINT "PK_3f70a487cc718ad8eda4e6d58c9" PRIMARY KEY (id);


--
-- Name: cities PK_4762ffb6e5d198cfec5606bc11e; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT "PK_4762ffb6e5d198cfec5606bc11e" PRIMARY KEY (id);


--
-- Name: areas PK_5110493f6342f34c978c084d0d6; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT "PK_5110493f6342f34c978c084d0d6" PRIMARY KEY (id);


--
-- Name: news_contents PK_939203e226eb820e06d62ff0f83; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.news_contents
    ADD CONSTRAINT "PK_939203e226eb820e06d62ff0f83" PRIMARY KEY (id);


--
-- Name: users PK_a3ffb1c0c8416b9fc6f907b7433; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "PK_a3ffb1c0c8416b9fc6f907b7433" PRIMARY KEY (id);


--
-- Name: support_responses PK_a74703c8911f3b61b4787e9ef50; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.support_responses
    ADD CONSTRAINT "PK_a74703c8911f3b61b4787e9ef50" PRIMARY KEY (id);


--
-- Name: support_requests PK_a9ce3cdbad0970597a07ab5db97; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.support_requests
    ADD CONSTRAINT "PK_a9ce3cdbad0970597a07ab5db97" PRIMARY KEY (id);


--
-- Name: countries PK_b2d7006793e8697ab3ae2deff18; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT "PK_b2d7006793e8697ab3ae2deff18" PRIMARY KEY (id);


--
-- Name: course_links PK_bef3d05d53fee19d67459bfd39c; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.course_links
    ADD CONSTRAINT "PK_bef3d05d53fee19d67459bfd39c" PRIMARY KEY (id);


--
-- Name: property_units PK_c7d7d8f633643123e9f9e0a0c83; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.property_units
    ADD CONSTRAINT "PK_c7d7d8f633643123e9f9e0a0c83" PRIMARY KEY (id);


--
-- Name: course_contents PK_e56de21b785ba03619207ce8f58; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.course_contents
    ADD CONSTRAINT "PK_e56de21b785ba03619207ce8f58" PRIMARY KEY (id);


--
-- Name: users UQ_97672ac88f789774dd47f7c8be3; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_97672ac88f789774dd47f7c8be3" UNIQUE (email);


--
-- Name: users UQ_a000cca60bcf04454e727699490; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UQ_a000cca60bcf04454e727699490" UNIQUE (phone);


--
-- Name: countries UQ_b47cbb5311bad9c9ae17b8c1eda; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT "UQ_b47cbb5311bad9c9ae17b8c1eda" UNIQUE (code);


--
-- Name: api_keys api_keys_apiKey_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT "api_keys_apiKey_key" UNIQUE ("apiKey");


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: IDX_05e3417270bb75313feb2459aa; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IDX_05e3417270bb75313feb2459aa" ON public.properties_facilities_facilities USING btree ("facilitiesId");


--
-- Name: IDX_d1cdba3c3e2725e394bbfa1c55; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX "IDX_d1cdba3c3e2725e394bbfa1c55" ON public.properties_facilities_facilities USING btree ("propertiesId");


--
-- Name: idx_api_keys_api_key; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_api_keys_api_key ON public.api_keys USING btree ("apiKey");


--
-- Name: idx_api_keys_is_active; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_api_keys_is_active ON public.api_keys USING btree ("isActive");


--
-- Name: properties_facilities_facilities FK_05e3417270bb75313feb2459aa0; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.properties_facilities_facilities
    ADD CONSTRAINT "FK_05e3417270bb75313feb2459aa0" FOREIGN KEY ("facilitiesId") REFERENCES public.facilities(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: course_contents FK_308255fad7fad91decc0851b680; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.course_contents
    ADD CONSTRAINT "FK_308255fad7fad91decc0851b680" FOREIGN KEY ("courseId") REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: properties FK_53f964539cd963cd63d82ca096c; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT "FK_53f964539cd963cd63d82ca096c" FOREIGN KEY ("countryId") REFERENCES public.countries(id);


--
-- Name: areas FK_56145036ce252af4f8e62631ed0; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.areas
    ADD CONSTRAINT "FK_56145036ce252af4f8e62631ed0" FOREIGN KEY ("cityId") REFERENCES public.cities(id);


--
-- Name: course_links FK_610983f17a3635ed06f03f14f00; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.course_links
    ADD CONSTRAINT "FK_610983f17a3635ed06f03f14f00" FOREIGN KEY ("courseId") REFERENCES public.courses(id) ON DELETE CASCADE;


--
-- Name: properties FK_90cce1dd836cf0af866da355a2d; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT "FK_90cce1dd836cf0af866da355a2d" FOREIGN KEY ("developerId") REFERENCES public.developers(id);


--
-- Name: property_units FK_99e3f071b6c5b3c50e712534bee; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.property_units
    ADD CONSTRAINT "FK_99e3f071b6c5b3c50e712534bee" FOREIGN KEY ("propertyId") REFERENCES public.properties(id) ON DELETE CASCADE;


--
-- Name: cities FK_b5f9bef6e3609b50aac3e103ab3; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT "FK_b5f9bef6e3609b50aac3e103ab3" FOREIGN KEY ("countryId") REFERENCES public.countries(id);


--
-- Name: support_responses FK_c3aaa2cf1d1ca747d7369230895; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.support_responses
    ADD CONSTRAINT "FK_c3aaa2cf1d1ca747d7369230895" FOREIGN KEY ("supportRequestId") REFERENCES public.support_requests(id) ON DELETE CASCADE;


--
-- Name: properties FK_c6ccfafd33ade95a869018a0441; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT "FK_c6ccfafd33ade95a869018a0441" FOREIGN KEY ("areaId") REFERENCES public.areas(id);


--
-- Name: news_contents FK_c81529f8cd6213f0f8a515145ed; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.news_contents
    ADD CONSTRAINT "FK_c81529f8cd6213f0f8a515145ed" FOREIGN KEY ("newsId") REFERENCES public.news(id) ON DELETE CASCADE;


--
-- Name: properties_facilities_facilities FK_d1cdba3c3e2725e394bbfa1c55f; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.properties_facilities_facilities
    ADD CONSTRAINT "FK_d1cdba3c3e2725e394bbfa1c55f" FOREIGN KEY ("propertiesId") REFERENCES public.properties(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: properties FK_da388a01cf39d5e33e46e0a60e6; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.properties
    ADD CONSTRAINT "FK_da388a01cf39d5e33e46e0a60e6" FOREIGN KEY ("cityId") REFERENCES public.cities(id);


--
-- PostgreSQL database dump complete
--

\unrestrict ZKc0HVN5alacYfjtbFZivdZbISJihwSyAvXr4KOEsz3yFDPdzeXzdb8riin2aRQ

