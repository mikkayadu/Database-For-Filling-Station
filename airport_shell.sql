--
-- PostgreSQL database dump
--

-- Dumped from database version 10.21
-- Dumped by pg_dump version 10.21

-- Started on 2023-05-02 19:28:53

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
-- TOC entry 2913 (class 0 OID 0)
-- Dependencies: 2912
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- TOC entry 2 (class 3079 OID 12924)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2915 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 1 (class 3079 OID 16384)
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- TOC entry 2916 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- TOC entry 218 (class 1255 OID 17071)
-- Name: notify_manager_diesel(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_manager_diesel() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.currentvolume < 50.00 THEN
        PERFORM pg_notify('fuel_level_low', 'Diesel fuel level is low, please order more fuel.');
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.notify_manager_diesel() OWNER TO postgres;

--
-- TOC entry 217 (class 1255 OID 17069)
-- Name: notify_manager_petrol(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_manager_petrol() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.currentvolume < 50.00 THEN
        PERFORM pg_notify('fuel_level_low', 'Petrol fuel level is low, please order more fuel.');
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.notify_manager_petrol() OWNER TO postgres;

--
-- TOC entry 219 (class 1255 OID 17095)
-- Name: reduce_quantity(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.reduce_quantity() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE mall_products
    SET quantity = quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.reduce_quantity() OWNER TO postgres;

--
-- TOC entry 216 (class 1255 OID 17051)
-- Name: validate_employee_fingerprint(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.validate_employee_fingerprint() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM employee_biometrics
        WHERE employeeid = NEW.employee_id
        AND fingerprint = NEW.fingerprint_template_text
    ) THEN
        RAISE EXCEPTION 'Fingerprint does not belong to this employee';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.validate_employee_fingerprint() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 211 (class 1259 OID 17063)
-- Name: diesel_tank; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.diesel_tank (
    id integer NOT NULL,
    tankid integer,
    currentvolume numeric(10,2) NOT NULL,
    daterecorded date NOT NULL
);


ALTER TABLE public.diesel_tank OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 17061)
-- Name: diesel_tank_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.diesel_tank_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.diesel_tank_id_seq OWNER TO postgres;

--
-- TOC entry 2917 (class 0 OID 0)
-- Dependencies: 210
-- Name: diesel_tank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.diesel_tank_id_seq OWNED BY public.diesel_tank.id;


--
-- TOC entry 205 (class 1259 OID 17011)
-- Name: employee_biometrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee_biometrics (
    employeeid integer NOT NULL,
    fingerprint text NOT NULL
);


ALTER TABLE public.employee_biometrics OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 17037)
-- Name: employee_sign_in; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee_sign_in (
    sign_in_id integer NOT NULL,
    employee_id integer NOT NULL,
    sign_in_time timestamp without time zone NOT NULL,
    sign_out_time timestamp without time zone,
    fingerprint_template_text text
);


ALTER TABLE public.employee_sign_in OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 17035)
-- Name: employee_sign_in_sign_in_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employee_sign_in_sign_in_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.employee_sign_in_sign_in_id_seq OWNER TO postgres;

--
-- TOC entry 2918 (class 0 OID 0)
-- Dependencies: 206
-- Name: employee_sign_in_sign_in_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employee_sign_in_sign_in_id_seq OWNED BY public.employee_sign_in.sign_in_id;


--
-- TOC entry 200 (class 1259 OID 16922)
-- Name: fuel_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fuel_products (
    productid integer NOT NULL,
    productname character varying(100) NOT NULL,
    category character varying(50) NOT NULL,
    price numeric(10,2) NOT NULL
);


ALTER TABLE public.fuel_products OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 16946)
-- Name: fuel_sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fuel_sales (
    salesid integer NOT NULL,
    salesdate date NOT NULL,
    staffid integer,
    productid integer,
    unitprice numeric(10,2) NOT NULL,
    totalprice numeric(10,2) NOT NULL,
    paymentmethod character varying(50) NOT NULL
);


ALTER TABLE public.fuel_sales OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 17075)
-- Name: mall_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mall_products (
    product_id integer NOT NULL,
    product_name character varying(50) NOT NULL,
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL,
    date_added date NOT NULL,
    date_updated date,
    supplier character varying(50) NOT NULL
);


ALTER TABLE public.mall_products OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 17073)
-- Name: mall_products_product_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mall_products_product_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mall_products_product_id_seq OWNER TO postgres;

--
-- TOC entry 2919 (class 0 OID 0)
-- Dependencies: 212
-- Name: mall_products_product_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mall_products_product_id_seq OWNED BY public.mall_products.product_id;


--
-- TOC entry 209 (class 1259 OID 17055)
-- Name: petrol_tank; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.petrol_tank (
    id integer NOT NULL,
    tankid integer,
    currentvolume numeric(10,2) NOT NULL,
    daterecorded date NOT NULL
);


ALTER TABLE public.petrol_tank OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 17053)
-- Name: petrol_tank_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.petrol_tank_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.petrol_tank_id_seq OWNER TO postgres;

--
-- TOC entry 2920 (class 0 OID 0)
-- Dependencies: 208
-- Name: petrol_tank_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.petrol_tank_id_seq OWNED BY public.petrol_tank.id;


--
-- TOC entry 199 (class 1259 OID 16920)
-- Name: products_productid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.products_productid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_productid_seq OWNER TO postgres;

--
-- TOC entry 2921 (class 0 OID 0)
-- Dependencies: 199
-- Name: products_productid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.products_productid_seq OWNED BY public.fuel_products.productid;


--
-- TOC entry 203 (class 1259 OID 16944)
-- Name: sales_salesid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_salesid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sales_salesid_seq OWNER TO postgres;

--
-- TOC entry 2922 (class 0 OID 0)
-- Dependencies: 203
-- Name: sales_salesid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sales_salesid_seq OWNED BY public.fuel_sales.salesid;


--
-- TOC entry 215 (class 1259 OID 17083)
-- Name: shopping_sales; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shopping_sales (
    sale_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    price numeric(10,2) NOT NULL,
    sale_date date NOT NULL,
    cashier_name character varying(50) NOT NULL,
    payment_method character varying(50) NOT NULL
);


ALTER TABLE public.shopping_sales OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 17081)
-- Name: shopping_sales_sale_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shopping_sales_sale_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.shopping_sales_sale_id_seq OWNER TO postgres;

--
-- TOC entry 2923 (class 0 OID 0)
-- Dependencies: 214
-- Name: shopping_sales_sale_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shopping_sales_sale_id_seq OWNED BY public.shopping_sales.sale_id;


--
-- TOC entry 198 (class 1259 OID 16914)
-- Name: staff; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staff (
    staffid integer NOT NULL,
    firstname character varying(50) NOT NULL,
    lastname character varying(50) NOT NULL,
    contactnumber character varying(20) NOT NULL,
    email character varying(100) NOT NULL,
    staff_role character varying(50) NOT NULL,
    salary numeric(10,2) NOT NULL
);


ALTER TABLE public.staff OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 16912)
-- Name: staff_staffid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.staff_staffid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.staff_staffid_seq OWNER TO postgres;

--
-- TOC entry 2924 (class 0 OID 0)
-- Dependencies: 197
-- Name: staff_staffid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.staff_staffid_seq OWNED BY public.staff.staffid;


--
-- TOC entry 202 (class 1259 OID 16938)
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    supplierid integer NOT NULL,
    companyname character varying(100) NOT NULL,
    contactname character varying(50) NOT NULL,
    contactnumber character varying(20) NOT NULL,
    email character varying(100) NOT NULL,
    address character varying(100) NOT NULL
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 16936)
-- Name: suppliers_supplierid_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suppliers_supplierid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.suppliers_supplierid_seq OWNER TO postgres;

--
-- TOC entry 2925 (class 0 OID 0)
-- Dependencies: 201
-- Name: suppliers_supplierid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suppliers_supplierid_seq OWNED BY public.suppliers.supplierid;


--
-- TOC entry 2735 (class 2604 OID 17066)
-- Name: diesel_tank id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diesel_tank ALTER COLUMN id SET DEFAULT nextval('public.diesel_tank_id_seq'::regclass);


--
-- TOC entry 2733 (class 2604 OID 17040)
-- Name: employee_sign_in sign_in_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_sign_in ALTER COLUMN sign_in_id SET DEFAULT nextval('public.employee_sign_in_sign_in_id_seq'::regclass);


--
-- TOC entry 2730 (class 2604 OID 16925)
-- Name: fuel_products productid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fuel_products ALTER COLUMN productid SET DEFAULT nextval('public.products_productid_seq'::regclass);


--
-- TOC entry 2732 (class 2604 OID 16949)
-- Name: fuel_sales salesid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fuel_sales ALTER COLUMN salesid SET DEFAULT nextval('public.sales_salesid_seq'::regclass);


--
-- TOC entry 2736 (class 2604 OID 17078)
-- Name: mall_products product_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mall_products ALTER COLUMN product_id SET DEFAULT nextval('public.mall_products_product_id_seq'::regclass);


--
-- TOC entry 2734 (class 2604 OID 17058)
-- Name: petrol_tank id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.petrol_tank ALTER COLUMN id SET DEFAULT nextval('public.petrol_tank_id_seq'::regclass);


--
-- TOC entry 2737 (class 2604 OID 17086)
-- Name: shopping_sales sale_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_sales ALTER COLUMN sale_id SET DEFAULT nextval('public.shopping_sales_sale_id_seq'::regclass);


--
-- TOC entry 2729 (class 2604 OID 16917)
-- Name: staff staffid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff ALTER COLUMN staffid SET DEFAULT nextval('public.staff_staffid_seq'::regclass);


--
-- TOC entry 2731 (class 2604 OID 16941)
-- Name: suppliers supplierid; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN supplierid SET DEFAULT nextval('public.suppliers_supplierid_seq'::regclass);


--
-- TOC entry 2902 (class 0 OID 17063)
-- Dependencies: 211
-- Data for Name: diesel_tank; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.diesel_tank VALUES (1, 1008779, 1200.50, '2023-04-01');
INSERT INTO public.diesel_tank VALUES (2, 1008780, 1350.75, '2023-04-01');
INSERT INTO public.diesel_tank VALUES (3, 1008779, 1140.25, '2023-04-02');
INSERT INTO public.diesel_tank VALUES (4, 1008780, 1295.00, '2023-04-02');
INSERT INTO public.diesel_tank VALUES (5, 1008779, 1085.75, '2023-04-03');
INSERT INTO public.diesel_tank VALUES (6, 1008780, 1245.50, '2023-04-03');
INSERT INTO public.diesel_tank VALUES (7, 1008779, 1027.25, '2023-04-04');
INSERT INTO public.diesel_tank VALUES (8, 1008780, 1175.00, '2023-04-04');
INSERT INTO public.diesel_tank VALUES (9, 1008779, 973.75, '2023-04-05');
INSERT INTO public.diesel_tank VALUES (10, 1008780, 1100.50, '2023-04-05');
INSERT INTO public.diesel_tank VALUES (11, 1008779, 919.25, '2023-04-06');
INSERT INTO public.diesel_tank VALUES (12, 1008780, 1025.00, '2023-04-06');
INSERT INTO public.diesel_tank VALUES (13, 1008779, 865.75, '2023-04-07');
INSERT INTO public.diesel_tank VALUES (14, 1008780, 950.50, '2023-04-07');
INSERT INTO public.diesel_tank VALUES (15, 1008779, 802.25, '2023-04-08');
INSERT INTO public.diesel_tank VALUES (16, 1008780, 875.00, '2023-04-08');
INSERT INTO public.diesel_tank VALUES (17, 1008779, 737.75, '2023-04-09');
INSERT INTO public.diesel_tank VALUES (18, 1008780, 800.50, '2023-04-09');
INSERT INTO public.diesel_tank VALUES (19, 1008779, 674.25, '2023-04-10');
INSERT INTO public.diesel_tank VALUES (20, 1008780, 725.00, '2023-04-10');
INSERT INTO public.diesel_tank VALUES (21, 1008779, 610.75, '2023-04-11');
INSERT INTO public.diesel_tank VALUES (22, 1008780, 650.50, '2023-04-11');
INSERT INTO public.diesel_tank VALUES (23, 1008779, 548.25, '2023-04-12');
INSERT INTO public.diesel_tank VALUES (24, 1008780, 575.00, '2023-04-12');
INSERT INTO public.diesel_tank VALUES (25, 1008779, 484.75, '2023-04-13');


--
-- TOC entry 2896 (class 0 OID 17011)
-- Dependencies: 205
-- Data for Name: employee_biometrics; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.employee_biometrics VALUES (1, 'AABBCCDDEEFF');
INSERT INTO public.employee_biometrics VALUES (2, '112233445566');
INSERT INTO public.employee_biometrics VALUES (3, 'FFEEDDCCBBAA');
INSERT INTO public.employee_biometrics VALUES (4, '001122334455');
INSERT INTO public.employee_biometrics VALUES (5, '556677889900');
INSERT INTO public.employee_biometrics VALUES (6, 'CCBBAA998877');
INSERT INTO public.employee_biometrics VALUES (7, '445566778899');
INSERT INTO public.employee_biometrics VALUES (8, '113355779922');
INSERT INTO public.employee_biometrics VALUES (9, 'FFDDBBAA9988');
INSERT INTO public.employee_biometrics VALUES (10, '0022446688AA');
INSERT INTO public.employee_biometrics VALUES (11, '88AA66CC44DD');
INSERT INTO public.employee_biometrics VALUES (12, '778899AA5566');
INSERT INTO public.employee_biometrics VALUES (13, 'BBCCDDEEFFAA');
INSERT INTO public.employee_biometrics VALUES (14, '4455778899AA');
INSERT INTO public.employee_biometrics VALUES (15, 'FFDDEEBBCCAA');


--
-- TOC entry 2898 (class 0 OID 17037)
-- Dependencies: 207
-- Data for Name: employee_sign_in; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.employee_sign_in VALUES (1, 1, '2023-04-29 08:00:00', '2023-04-29 17:00:00', 'AABBCCDDEEFF');
INSERT INTO public.employee_sign_in VALUES (2, 2, '2023-04-29 07:45:00', '2023-04-29 16:30:00', '112233445566');
INSERT INTO public.employee_sign_in VALUES (3, 3, '2023-04-29 08:15:00', '2023-04-29 17:15:00', 'FFEEDDCCBBAA');
INSERT INTO public.employee_sign_in VALUES (4, 4, '2023-04-29 08:30:00', '2023-04-29 17:30:00', '001122334455');
INSERT INTO public.employee_sign_in VALUES (5, 5, '2023-04-29 07:30:00', '2023-04-29 16:45:00', '556677889900');
INSERT INTO public.employee_sign_in VALUES (6, 6, '2023-04-29 08:00:00', '2023-04-29 16:30:00', 'CCBBAA998877');
INSERT INTO public.employee_sign_in VALUES (7, 7, '2023-04-29 08:15:00', '2023-04-29 17:15:00', '445566778899');
INSERT INTO public.employee_sign_in VALUES (8, 8, '2023-04-29 08:30:00', '2023-04-29 17:30:00', '113355779922');
INSERT INTO public.employee_sign_in VALUES (9, 9, '2023-04-29 07:45:00', '2023-04-29 16:30:00', 'FFDDBBAA9988');
INSERT INTO public.employee_sign_in VALUES (10, 10, '2023-04-29 08:00:00', '2023-04-29 17:00:00', '0022446688AA');
INSERT INTO public.employee_sign_in VALUES (11, 11, '2023-04-29 08:15:00', '2023-04-29 17:15:00', '88AA66CC44DD');
INSERT INTO public.employee_sign_in VALUES (12, 12, '2023-04-29 08:30:00', '2023-04-29 17:30:00', '778899AA5566');
INSERT INTO public.employee_sign_in VALUES (13, 13, '2023-04-29 07:30:00', '2023-04-29 16:45:00', 'BBCCDDEEFFAA');
INSERT INTO public.employee_sign_in VALUES (14, 14, '2023-04-29 08:00:00', '2023-04-29 16:30:00', '4455778899AA');
INSERT INTO public.employee_sign_in VALUES (15, 15, '2023-04-29 08:15:00', '2023-04-29 17:15:00', 'FFDDEEBBCCAA');


--
-- TOC entry 2891 (class 0 OID 16922)
-- Dependencies: 200
-- Data for Name: fuel_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.fuel_products VALUES (1, 'Premium Petrol', 'Fuel', 6.00);
INSERT INTO public.fuel_products VALUES (2, 'Regular Petrol', 'Fuel', 5.80);
INSERT INTO public.fuel_products VALUES (3, 'Diesel', 'Fuel', 6.20);
INSERT INTO public.fuel_products VALUES (4, 'Kerosene', 'Fuel', 4.50);
INSERT INTO public.fuel_products VALUES (5, 'LPG Cylinder', 'Gas', 55.00);
INSERT INTO public.fuel_products VALUES (6, 'Engine Oil', 'Accessories', 30.00);
INSERT INTO public.fuel_products VALUES (7, 'Brake Fluid', 'Accessories', 10.00);
INSERT INTO public.fuel_products VALUES (8, 'Windshield Wiper Fluid', 'Accessories', 8.00);
INSERT INTO public.fuel_products VALUES (9, 'Coolant', 'Accessories', 12.00);
INSERT INTO public.fuel_products VALUES (10, 'Air Freshener', 'Accessories', 5.00);


--
-- TOC entry 2895 (class 0 OID 16946)
-- Dependencies: 204
-- Data for Name: fuel_sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.fuel_sales VALUES (51, '2023-04-01', 5, 10, 5.50, 55.00, 'Cash');
INSERT INTO public.fuel_sales VALUES (52, '2023-04-01', 2, 9, 8.25, 74.25, 'Credit Card');
INSERT INTO public.fuel_sales VALUES (53, '2023-04-02', 7, 1, 9.50, 95.00, 'Cash');
INSERT INTO public.fuel_sales VALUES (54, '2023-04-02', 3, 3, 12.75, 255.00, 'Cash');
INSERT INTO public.fuel_sales VALUES (55, '2023-04-03', 4, 8, 7.50, 112.50, 'Credit Card');
INSERT INTO public.fuel_sales VALUES (56, '2023-04-03', 6, 2, 3.75, 37.50, 'Cash');
INSERT INTO public.fuel_sales VALUES (57, '2023-04-04', 1, 5, 11.00, 110.00, 'Credit Card');
INSERT INTO public.fuel_sales VALUES (58, '2023-04-04', 9, 6, 6.00, 72.00, 'Cash');
INSERT INTO public.fuel_sales VALUES (59, '2023-04-05', 8, 7, 5.25, 78.75, 'Credit Card');
INSERT INTO public.fuel_sales VALUES (60, '2023-04-05', 2, 3, 13.50, 270.00, 'Cash');
INSERT INTO public.fuel_sales VALUES (61, '2023-04-06', 3, 4, 8.00, 88.00, 'Cash');
INSERT INTO public.fuel_sales VALUES (62, '2023-04-06', 4, 10, 6.25, 62.50, 'Credit Card');
INSERT INTO public.fuel_sales VALUES (63, '2023-04-07', 6, 2, 3.25, 32.50, 'Cash');
INSERT INTO public.fuel_sales VALUES (64, '2023-04-07', 5, 1, 10.75, 107.50, 'Credit Card');
INSERT INTO public.fuel_sales VALUES (65, '2023-04-08', 7, 9, 7.00, 63.00, 'Cash');
INSERT INTO public.fuel_sales VALUES (66, '2023-04-08', 1, 8, 5.50, 82.50, 'Credit Card');
INSERT INTO public.fuel_sales VALUES (67, '2023-04-09', 2, 5, 11.50, 115.00, 'Cash');
INSERT INTO public.fuel_sales VALUES (68, '2023-04-09', 8, 4, 8.25, 99.00, 'Credit Card');
INSERT INTO public.fuel_sales VALUES (69, '2023-04-10', 3, 3, 12.50, 250.00, 'Cash');
INSERT INTO public.fuel_sales VALUES (70, '2023-04-10', 6, 6, 5.75, 69.00, 'Credit Card');
INSERT INTO public.fuel_sales VALUES (71, '2023-04-11', 4, 7, 6.75, 101.25, 'Cash');
INSERT INTO public.fuel_sales VALUES (72, '2023-04-11', 9, 1, 9.25, 92.50, 'Credit Card');
INSERT INTO public.fuel_sales VALUES (73, '2023-04-12', 5, 2, 4.50, 45.00, 'Cash');
INSERT INTO public.fuel_sales VALUES (74, '2023-04-12', 1, 10, 5.75, 57.50, 'Credit Card');
INSERT INTO public.fuel_sales VALUES (75, '2023-04-13', 7, 9, 7.50, 67.50, 'Cash');
INSERT INTO public.fuel_sales VALUES (76, '2022-02-03', 6, 2, 8.50, 34.00, 'cash');
INSERT INTO public.fuel_sales VALUES (77, '2022-02-05', 7, 1, 13.00, 26.00, 'credit card');
INSERT INTO public.fuel_sales VALUES (78, '2022-02-06', 2, 3, 6.50, 65.00, 'cash');
INSERT INTO public.fuel_sales VALUES (79, '2022-02-07', 5, 4, 5.00, 25.00, 'mobile money');
INSERT INTO public.fuel_sales VALUES (80, '2022-02-08', 4, 2, 8.50, 34.00, 'cash');
INSERT INTO public.fuel_sales VALUES (81, '2022-02-09', 1, 1, 13.00, 26.00, 'credit card');
INSERT INTO public.fuel_sales VALUES (82, '2022-02-11', 3, 3, 6.50, 65.00, 'cash');
INSERT INTO public.fuel_sales VALUES (83, '2022-02-12', 8, 4, 5.00, 25.00, 'mobile money');
INSERT INTO public.fuel_sales VALUES (84, '2022-02-13', 9, 2, 8.50, 34.00, 'cash');
INSERT INTO public.fuel_sales VALUES (85, '2022-02-14', 10, 1, 13.00, 26.00, 'credit card');
INSERT INTO public.fuel_sales VALUES (86, '2022-02-15', 11, 3, 6.50, 65.00, 'cash');
INSERT INTO public.fuel_sales VALUES (87, '2022-02-16', 12, 4, 5.00, 25.00, 'mobile money');
INSERT INTO public.fuel_sales VALUES (88, '2022-02-17', 13, 2, 8.50, 34.00, 'cash');
INSERT INTO public.fuel_sales VALUES (89, '2022-02-18', 14, 1, 13.00, 26.00, 'credit card');
INSERT INTO public.fuel_sales VALUES (90, '2022-02-19', 15, 3, 6.50, 65.00, 'cash');
INSERT INTO public.fuel_sales VALUES (91, '2022-02-20', 1, 4, 5.00, 25.00, 'mobile money');
INSERT INTO public.fuel_sales VALUES (92, '2022-02-21', 2, 2, 8.50, 34.00, 'cash');
INSERT INTO public.fuel_sales VALUES (93, '2022-02-22', 3, 1, 13.00, 26.00, 'credit card');
INSERT INTO public.fuel_sales VALUES (94, '2022-02-23', 4, 3, 6.50, 65.00, 'cash');
INSERT INTO public.fuel_sales VALUES (95, '2022-02-24', 5, 4, 5.00, 25.00, 'mobile money');
INSERT INTO public.fuel_sales VALUES (96, '2022-02-25', 6, 2, 8.50, 34.00, 'cash');
INSERT INTO public.fuel_sales VALUES (97, '2022-02-26', 7, 1, 13.00, 26.00, 'credit card');
INSERT INTO public.fuel_sales VALUES (98, '2022-02-27', 8, 3, 6.50, 65.00, 'cash');
INSERT INTO public.fuel_sales VALUES (99, '2022-02-28', 9, 4, 5.00, 25.00, 'mobile money');
INSERT INTO public.fuel_sales VALUES (100, '2022-03-01', 10, 2, 8.50, 34.00, 'cash');


--
-- TOC entry 2904 (class 0 OID 17075)
-- Dependencies: 213
-- Data for Name: mall_products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.mall_products VALUES (1, 'Coca-Cola', 100, 1.99, '2023-04-29', '2023-04-29', 'Coca-Cola Company');
INSERT INTO public.mall_products VALUES (3, 'Sprite', 120, 1.99, '2023-04-29', '2023-04-29', 'Coca-Cola Company');
INSERT INTO public.mall_products VALUES (4, 'Red Bull', 50, 2.99, '2023-04-29', '2023-04-29', 'Red Bull GmbH');
INSERT INTO public.mall_products VALUES (5, 'Monster Energy', 70, 2.99, '2023-04-29', '2023-04-29', 'Monster Beverage Corporation');
INSERT INTO public.mall_products VALUES (6, 'Nestle Pure Life Water', 150, 0.99, '2023-04-29', '2023-04-29', 'Nestle Waters');
INSERT INTO public.mall_products VALUES (7, 'Pepsi', 90, 1.99, '2023-04-29', '2023-04-29', 'PepsiCo');
INSERT INTO public.mall_products VALUES (8, 'Mountain Dew', 60, 1.99, '2023-04-29', '2023-04-29', 'PepsiCo');
INSERT INTO public.mall_products VALUES (9, 'Gatorade', 100, 1.49, '2023-04-29', '2023-04-29', 'PepsiCo');
INSERT INTO public.mall_products VALUES (10, 'Lays Classic Chips', 120, 1.29, '2023-04-29', '2023-04-29', 'Frito-Lay');
INSERT INTO public.mall_products VALUES (11, 'Doritos Nacho Cheese Chips', 80, 1.29, '2023-04-29', '2023-04-29', 'Frito-Lay');
INSERT INTO public.mall_products VALUES (12, 'Cheetos Crunchy Cheese Flavored Snacks', 90, 1.29, '2023-04-29', '2023-04-29', 'Frito-Lay');
INSERT INTO public.mall_products VALUES (13, 'Starbucks Coffee', 40, 1.99, '2023-04-29', '2023-04-29', 'Starbucks Corporation');
INSERT INTO public.mall_products VALUES (14, 'Nescafe Instant Coffee', 60, 1.49, '2023-04-29', '2023-04-29', 'Nestle');
INSERT INTO public.mall_products VALUES (15, 'Tropicana Orange Juice', 70, 1.99, '2023-04-29', '2023-04-29', 'Tropicana Products');
INSERT INTO public.mall_products VALUES (16, 'Minute Maid Apple Juice', 50, 1.99, '2023-04-29', '2023-04-29', 'The Coca-Cola Company');
INSERT INTO public.mall_products VALUES (17, 'Budweiser Beer', 80, 2.49, '2023-04-29', '2023-04-29', 'Anheuser-Busch InBev');
INSERT INTO public.mall_products VALUES (18, 'Heineken Beer', 60, 2.49, '2023-04-29', '2023-04-29', 'Heineken International');
INSERT INTO public.mall_products VALUES (19, 'Coors Light Beer', 90, 2.49, '2023-04-29', '2023-04-29', 'Coors Brewing Company');
INSERT INTO public.mall_products VALUES (2, 'Fanta', 74, 1.99, '2023-04-29', '2023-04-29', 'Coca-Cola Company');


--
-- TOC entry 2900 (class 0 OID 17055)
-- Dependencies: 209
-- Data for Name: petrol_tank; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.petrol_tank VALUES (1, 1008779, 100.25, '2022-04-01');
INSERT INTO public.petrol_tank VALUES (2, 1008780, 110.80, '2022-04-01');
INSERT INTO public.petrol_tank VALUES (3, 1008779, 97.76, '2022-04-02');
INSERT INTO public.petrol_tank VALUES (4, 1008780, 105.50, '2022-04-02');
INSERT INTO public.petrol_tank VALUES (5, 1008779, 93.50, '2022-04-03');
INSERT INTO public.petrol_tank VALUES (6, 1008780, 102.45, '2022-04-03');
INSERT INTO public.petrol_tank VALUES (7, 1008779, 90.25, '2022-04-04');
INSERT INTO public.petrol_tank VALUES (8, 1008780, 99.20, '2022-04-04');
INSERT INTO public.petrol_tank VALUES (9, 1008779, 87.50, '2022-04-05');
INSERT INTO public.petrol_tank VALUES (10, 1008780, 96.70, '2022-04-05');
INSERT INTO public.petrol_tank VALUES (11, 1008779, 85.05, '2022-04-06');
INSERT INTO public.petrol_tank VALUES (12, 1008780, 94.30, '2022-04-06');
INSERT INTO public.petrol_tank VALUES (13, 1008779, 82.90, '2022-04-07');
INSERT INTO public.petrol_tank VALUES (14, 1008780, 92.00, '2022-04-07');
INSERT INTO public.petrol_tank VALUES (15, 1008779, 80.55, '2022-04-08');
INSERT INTO public.petrol_tank VALUES (16, 1008780, 89.70, '2022-04-08');
INSERT INTO public.petrol_tank VALUES (17, 1008779, 78.20, '2022-04-09');
INSERT INTO public.petrol_tank VALUES (18, 1008780, 87.35, '2022-04-09');
INSERT INTO public.petrol_tank VALUES (19, 1008779, 76.05, '2022-04-10');
INSERT INTO public.petrol_tank VALUES (20, 1008780, 85.20, '2022-04-10');
INSERT INTO public.petrol_tank VALUES (21, 1008779, 29.35, '2023-04-29');
INSERT INTO public.petrol_tank VALUES (22, 1008779, 20.35, '2023-04-30');
INSERT INTO public.petrol_tank VALUES (23, 1008779, 18.35, '2023-04-30');
INSERT INTO public.petrol_tank VALUES (24, 1008779, 15.35, '2023-05-04');
INSERT INTO public.petrol_tank VALUES (25, 1008779, 15.35, '2023-05-05');
INSERT INTO public.petrol_tank VALUES (26, 1008779, 15.35, '2023-05-07');


--
-- TOC entry 2906 (class 0 OID 17083)
-- Dependencies: 215
-- Data for Name: shopping_sales; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.shopping_sales VALUES (1, 2, 3, 4.50, '2023-04-28', 'John Doe', 'Cash');
INSERT INTO public.shopping_sales VALUES (2, 7, 1, 12.99, '2023-04-27', 'Jane Smith', 'Credit Card');
INSERT INTO public.shopping_sales VALUES (3, 10, 2, 9.99, '2023-04-26', 'Bob Johnson', 'Debit Card');
INSERT INTO public.shopping_sales VALUES (4, 5, 5, 2.99, '2023-04-26', 'Sarah Lee', 'Cash');
INSERT INTO public.shopping_sales VALUES (5, 3, 1, 5.99, '2023-04-25', 'Michael Chen', 'Cash');
INSERT INTO public.shopping_sales VALUES (6, 8, 3, 6.50, '2023-04-24', 'Emily Wang', 'Credit Card');
INSERT INTO public.shopping_sales VALUES (7, 4, 2, 3.99, '2023-04-23', 'David Lee', 'Cash');
INSERT INTO public.shopping_sales VALUES (8, 12, 1, 8.50, '2023-04-22', 'Lily Chen', 'Debit Card');
INSERT INTO public.shopping_sales VALUES (9, 1, 4, 1.50, '2023-04-21', 'Kevin Liu', 'Cash');
INSERT INTO public.shopping_sales VALUES (10, 9, 2, 11.99, '2023-04-20', 'Grace Li', 'Credit Card');
INSERT INTO public.shopping_sales VALUES (11, 6, 1, 4.99, '2023-04-19', 'Robert Smith', 'Cash');
INSERT INTO public.shopping_sales VALUES (12, 11, 3, 7.99, '2023-04-18', 'Karen Zhang', 'Debit Card');
INSERT INTO public.shopping_sales VALUES (13, 7, 2, 12.99, '2023-04-17', 'John Doe', 'Credit Card');
INSERT INTO public.shopping_sales VALUES (14, 2, 1, 4.50, '2023-04-16', 'Jane Smith', 'Cash');
INSERT INTO public.shopping_sales VALUES (15, 5, 4, 2.99, '2023-04-15', 'Bob Johnson', 'Debit Card');
INSERT INTO public.shopping_sales VALUES (16, 2, 3, 6.00, '2023-04-28', 'John Doe', 'Cash');
INSERT INTO public.shopping_sales VALUES (17, 2, 3, 6.00, '2023-04-28', 'John Doe', 'Cash');


--
-- TOC entry 2889 (class 0 OID 16914)
-- Dependencies: 198
-- Data for Name: staff; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.staff VALUES (1, 'Kwame', 'Appiah', '024-123-4567', 'kwame.appiah@example.com', 'Manager', 4000.00);
INSERT INTO public.staff VALUES (2, 'Akosua', 'Mensah', '024-234-5678', 'akosua.mensah@example.com', 'Assistant Manager', 3000.00);
INSERT INTO public.staff VALUES (3, 'Yaw', 'Asare', '024-345-6789', 'yaw.asare@example.com', 'Supervisor', 2500.00);
INSERT INTO public.staff VALUES (4, 'Ama', 'Aidoo', '024-456-7890', 'ama.aidoo@example.com', 'Attendant', 1500.00);
INSERT INTO public.staff VALUES (5, 'Kofi', 'Owusu', '024-567-8901', 'kofi.owusu@example.com', 'Attendant', 1500.00);
INSERT INTO public.staff VALUES (6, 'Akua', 'Kwakye', '024-678-9012', 'akua.kwakye@example.com', 'Attendant', 1500.00);
INSERT INTO public.staff VALUES (7, 'Yaw', 'Boakye', '024-789-0123', 'yaw.boakye@example.com', 'Attendant', 1500.00);
INSERT INTO public.staff VALUES (8, 'Afia', 'Dapaah', '024-890-1234', 'afia.dapaah@example.com', 'Attendant', 1500.00);
INSERT INTO public.staff VALUES (9, 'Kwadwo', 'Opoku', '024-901-2345', 'kwadwo.opoku@example.com', 'Attendant', 1500.00);
INSERT INTO public.staff VALUES (10, 'Adwoa', 'Asamoah', '024-012-3456', 'adwoa.asamoah@example.com', 'Attendant', 1500.00);
INSERT INTO public.staff VALUES (11, 'Yaw', 'Annan', '024-123-4567', 'yaw.annan@example.com', 'Attendant', 1500.00);
INSERT INTO public.staff VALUES (12, 'Akos', 'Agyeman', '024-234-5678', 'akos.agyeman@example.com', 'Attendant', 1500.00);
INSERT INTO public.staff VALUES (13, 'Kwame', 'Addo', '024-345-6789', 'kwame.addo@example.com', 'Attendant', 1500.00);
INSERT INTO public.staff VALUES (14, 'Ama', 'Bonsu', '024-456-7890', 'ama.bonsu@example.com', 'Attendant', 1500.00);
INSERT INTO public.staff VALUES (15, 'Yaw', 'Boateng', '024-567-8901', 'yaw.boateng@example.com', 'Attendant', 1500.00);


--
-- TOC entry 2893 (class 0 OID 16938)
-- Dependencies: 202
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.suppliers VALUES (1, 'GOIL', 'Patrick Akpey', '+233-302-681918', 'info@goil.com.gh', 'P. O. Box GP 3183, Accra');
INSERT INTO public.suppliers VALUES (2, 'Total Ghana', 'Eric Fanchini', '+233-302-670811', 'contact@total-ghana.com', 'P. O. Box 5533, Accra');
INSERT INTO public.suppliers VALUES (3, 'Shell Ghana', 'Esi Essilfie-Conduah', '+233-302-684000', 'customercare@shellghana.com', 'P. O. Box GP 200, Accra');
INSERT INTO public.suppliers VALUES (4, 'Petroleum Solutions Limited', 'Yaw Osei Tutu', '+233-303-963313', 'info@psl.com.gh', 'P. O. Box CT 2944, Cantonments, Accra');
INSERT INTO public.suppliers VALUES (5, 'J. Stanley Owusu Group Limited', 'Joel Stanley Owusu', '+233-302-782727', 'info@jstanleyowusu.com', 'P. O. Box AN 5363, Accra North');
INSERT INTO public.suppliers VALUES (6, 'Phoenix Petroleum Ghana Limited', 'Benjamin Adekunle', '+233-302-740433', 'info@phoenixpetroleumghana.com', 'P. O. Box CT 8536, Cantonments, Accra');
INSERT INTO public.suppliers VALUES (7, 'Puma Energy', 'Jules Delafosse', '+233-302-632292', 'info@pumaenergy.com', 'P. O. Box KA 16307, Airport, Accra');
INSERT INTO public.suppliers VALUES (8, 'African Energy Consortium Limited', 'Nana Adu Abankroh', '+233-303-410466', 'info@africanenergyconsortium.com', 'P. O. Box TD 246, Tudu, Accra');
INSERT INTO public.suppliers VALUES (9, 'Allied Oil Company Limited', 'Emmanuel K. Debrah', '+233-302-258300', 'info@alliedoil.com', 'P. O. Box 176, Tema');
INSERT INTO public.suppliers VALUES (10, 'Star Oil Company Limited', 'Robert Coleman', '+233-244-339949', 'info@staroilghana.com', 'P. O. Box BT 375, Tema');


--
-- TOC entry 2926 (class 0 OID 0)
-- Dependencies: 210
-- Name: diesel_tank_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.diesel_tank_id_seq', 25, true);


--
-- TOC entry 2927 (class 0 OID 0)
-- Dependencies: 206
-- Name: employee_sign_in_sign_in_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employee_sign_in_sign_in_id_seq', 21, true);


--
-- TOC entry 2928 (class 0 OID 0)
-- Dependencies: 212
-- Name: mall_products_product_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mall_products_product_id_seq', 19, true);


--
-- TOC entry 2929 (class 0 OID 0)
-- Dependencies: 208
-- Name: petrol_tank_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.petrol_tank_id_seq', 26, true);


--
-- TOC entry 2930 (class 0 OID 0)
-- Dependencies: 199
-- Name: products_productid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.products_productid_seq', 10, true);


--
-- TOC entry 2931 (class 0 OID 0)
-- Dependencies: 203
-- Name: sales_salesid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sales_salesid_seq', 100, true);


--
-- TOC entry 2932 (class 0 OID 0)
-- Dependencies: 214
-- Name: shopping_sales_sale_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shopping_sales_sale_id_seq', 17, true);


--
-- TOC entry 2933 (class 0 OID 0)
-- Dependencies: 197
-- Name: staff_staffid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.staff_staffid_seq', 15, true);


--
-- TOC entry 2934 (class 0 OID 0)
-- Dependencies: 201
-- Name: suppliers_supplierid_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.suppliers_supplierid_seq', 10, true);


--
-- TOC entry 2753 (class 2606 OID 17068)
-- Name: diesel_tank diesel_tank_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.diesel_tank
    ADD CONSTRAINT diesel_tank_pkey PRIMARY KEY (id);


--
-- TOC entry 2747 (class 2606 OID 17018)
-- Name: employee_biometrics employee_biometrics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_biometrics
    ADD CONSTRAINT employee_biometrics_pkey PRIMARY KEY (employeeid);


--
-- TOC entry 2749 (class 2606 OID 17045)
-- Name: employee_sign_in employee_sign_in_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_sign_in
    ADD CONSTRAINT employee_sign_in_pkey PRIMARY KEY (sign_in_id);


--
-- TOC entry 2755 (class 2606 OID 17080)
-- Name: mall_products mall_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mall_products
    ADD CONSTRAINT mall_products_pkey PRIMARY KEY (product_id);


--
-- TOC entry 2751 (class 2606 OID 17060)
-- Name: petrol_tank petrol_tank_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.petrol_tank
    ADD CONSTRAINT petrol_tank_pkey PRIMARY KEY (id);


--
-- TOC entry 2741 (class 2606 OID 16927)
-- Name: fuel_products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fuel_products
    ADD CONSTRAINT products_pkey PRIMARY KEY (productid);


--
-- TOC entry 2745 (class 2606 OID 16951)
-- Name: fuel_sales sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fuel_sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (salesid);


--
-- TOC entry 2757 (class 2606 OID 17088)
-- Name: shopping_sales shopping_sales_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_sales
    ADD CONSTRAINT shopping_sales_pkey PRIMARY KEY (sale_id);


--
-- TOC entry 2739 (class 2606 OID 16919)
-- Name: staff staff_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (staffid);


--
-- TOC entry 2743 (class 2606 OID 16943)
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (supplierid);


--
-- TOC entry 2765 (class 2620 OID 17072)
-- Name: diesel_tank diesel_tank_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER diesel_tank_trigger AFTER INSERT OR UPDATE ON public.diesel_tank FOR EACH ROW EXECUTE PROCEDURE public.notify_manager_diesel();


--
-- TOC entry 2764 (class 2620 OID 17070)
-- Name: petrol_tank petrol_tank_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER petrol_tank_trigger AFTER INSERT OR UPDATE ON public.petrol_tank FOR EACH ROW EXECUTE PROCEDURE public.notify_manager_petrol();


--
-- TOC entry 2766 (class 2620 OID 17096)
-- Name: shopping_sales reduce_quantity_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER reduce_quantity_trigger AFTER INSERT ON public.shopping_sales FOR EACH ROW EXECUTE PROCEDURE public.reduce_quantity();


--
-- TOC entry 2763 (class 2620 OID 17052)
-- Name: employee_sign_in validate_employee_sign_in; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER validate_employee_sign_in BEFORE INSERT ON public.employee_sign_in FOR EACH ROW EXECUTE PROCEDURE public.validate_employee_fingerprint();


--
-- TOC entry 2760 (class 2606 OID 17019)
-- Name: employee_biometrics employee_biometrics_employeeid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_biometrics
    ADD CONSTRAINT employee_biometrics_employeeid_fkey FOREIGN KEY (employeeid) REFERENCES public.staff(staffid);


--
-- TOC entry 2761 (class 2606 OID 17046)
-- Name: employee_sign_in fk_employee_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee_sign_in
    ADD CONSTRAINT fk_employee_id FOREIGN KEY (employee_id) REFERENCES public.staff(staffid) ON DELETE CASCADE;


--
-- TOC entry 2759 (class 2606 OID 16957)
-- Name: fuel_sales sales_productid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fuel_sales
    ADD CONSTRAINT sales_productid_fkey FOREIGN KEY (productid) REFERENCES public.fuel_products(productid);


--
-- TOC entry 2758 (class 2606 OID 16952)
-- Name: fuel_sales sales_staffid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fuel_sales
    ADD CONSTRAINT sales_staffid_fkey FOREIGN KEY (staffid) REFERENCES public.staff(staffid);


--
-- TOC entry 2762 (class 2606 OID 17089)
-- Name: shopping_sales shopping_sales_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_sales
    ADD CONSTRAINT shopping_sales_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.mall_products(product_id);


-- Completed on 2023-05-02 19:28:53

--
-- PostgreSQL database dump complete
--

