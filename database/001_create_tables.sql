--CREATE DATABASE papeys_pizza

--DROP TABLES
DROP TABLE IF EXISTS parlour;
DROP TABLE IF EXISTS supplier;
DROP TABLE IF EXISTS membership;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS role;
DROP TABLE IF EXISTS account;
DROP TABLE IF EXISTS contact_info;
DROP TABLE IF EXISTS address;



CREATE TABLE contact_info(
	contact_id SERIAL PRIMARY KEY,
	street VARCHAR(30) NOT NULL,
	town VARCHAR(30),
	postcode VARCHAR(7) NOT NULL,
	email_address VARCHAR(80) NOT NULL,
	phone_number VARCHAR(13)
);

-- Staff members can also have a customer account & membership aswell as staff, getting discounts to enforce.
CREATE TABLE account(
	account_id SERIAL PRIMARY KEY,
	username VARCHAR(30),
	password VARCHAR(255) NOT NULL,
	contact_id INT,
	date_of_birth DATE,
	created_at TIMESTAMP,
	is_staff BOOLEAN,
	FOREIGN KEY (contact_id) REFERENCES contact_info(contact_id)
	ON DELETE CASCADE,
);

CREATE TABLE role(
	role_id SERIAL PRIMARY KEY,
	role_name VARCHAR(30) NOT NULL,
	access_level SMALLINT NOT NULL,
	salary DECIMAL(10,2) NOT NULL,
	role_description TEXT
);

CREATE TABLE staff(
	staff_id SERIAL PRIMARY KEY,
	contact_id INT NOT NULL,
	role_id SMALLINT NOT NULL,
	FOREIGN KEY (contact_id) REFERENCES contact_info(contact_id)
	ON DELETE CASCADE,
	FOREIGN KEY (role_id) REFERENCES role(role_id)
);

CREATE TABLE membership(
	membership_id SERIAL PRIMARY KEY,
	account_id INT NOT NULL,
	purchased TIMESTAMP,
	valid_until DATE
);

--Food Side
CREATE TABLE supplier(
	supplier_id SERIAL PRIMARY KEY,
	supplier_name VARCHAR(50),
	contact_id INT NOT NULL,
	address_id INT NOT NULL,
	FOREIGN KEY (contact_id) REFERENCES contact_info(contact_id)
	ON DELETE CASCADE,
);

-- Contact info applied is admin
CREATE TABLE parlour(
	parlour_id SERIAL PRIMARY KEY,
	parlour_name VARCHAR(30),
	address_id INT NOT NULL,
	FOREIGN KEY (address_id) REFERENCES address(address_id)	
);


