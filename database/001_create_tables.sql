--CREATE DATABASE papeys_pizza

--DROP TABLES REVERSE ORDER
DROP TABLE IF EXISTS inventory_transaction CASCADE;
DROP TABLE IF EXISTS inventory_transaction_type CASCADE;
DROP TABLE IF EXISTS sale_order_item CASCADE;
DROP TABLE IF EXISTS sale_order CASCADE;
DROP TABLE IF EXISTS transaction_source CASCADE;
DROP TABLE IF EXISTS transaction_source_type CASCADE;
DROP TABLE IF EXISTS recipe CASCADE;
DROP TABLE IF EXISTS parlour_inventory CASCADE;
DROP TABLE IF EXISTS supplier_item CASCADE;
DROP TABLE IF EXISTS item CASCADE;
DROP TABLE IF EXISTS item_category CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS role CASCADE;
DROP TABLE IF EXISTS parlour CASCADE;
DROP TABLE IF EXISTS supplier CASCADE;
DROP TABLE IF EXISTS arcade_card CASCADE;
DROP TABLE IF EXISTS account CASCADE;
DROP TABLE IF EXISTS contact_info CASCADE;
DROP TABLE IF EXISTS contact_type CASCADE;

-- Contact Type Lookup Table (Account, Staff, Parlour, Supplier)
CREATE TABLE contact_type(
	contact_type_id SERIAL PRIMARY KEY,
	contact_type_name VARCHAR(20)
);

-- All Nullable to enforce NOT NULL checks through triggers (many tables rely on contact for different reasons).
CREATE TABLE contact_info(
	contact_id SERIAL PRIMARY KEY,
	contact_type_id INT NOT NULL,
	surname VARCHAR(30),
	forename VARCHAR(30),
	street VARCHAR(30),
	town VARCHAR(30),
	postcode VARCHAR(7),
	email_address VARCHAR(80) UNIQUE,
	telephone_number VARCHAR(13),
	FOREIGN KEY (contact_type_id) REFERENCES contact_type(contact_type_id)
);

-- Staff members can also have a customer account & membership aswell as staff, getting discounts to enforce.
CREATE TABLE account(
	account_id SERIAL PRIMARY KEY,
	contact_id INT NOT NULL UNIQUE,
	password VARCHAR(255) NOT NULL,
	date_of_birth DATE,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (contact_id) REFERENCES contact_info(contact_id)
	ON DELETE CASCADE
);

-- Card active == true, card lost, deactivated or replaced == false
CREATE TABLE arcade_card(
	a_card_id SERIAL PRIMARY KEY,
	account_id INT NOT NULL UNIQUE,
	purchased TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	current_value DECIMAL(10,2) NOT NULL,
	active BOOLEAN,
	updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (account_id) REFERENCES account(account_id) ON DELETE CASCADE
);

--Food Side
CREATE TABLE supplier(
	supplier_id SERIAL PRIMARY KEY,
	supplier_name VARCHAR(50),
	contact_id INT NOT NULL,
	FOREIGN KEY (contact_id) REFERENCES contact_info(contact_id)
	ON DELETE SET NULL
);

-- Contact info applied is admin
CREATE TABLE parlour(
	parlour_id SERIAL PRIMARY KEY,
	parlour_name VARCHAR(30),
	contact_id INT NOT NULL UNIQUE,
	FOREIGN KEY (contact_id) REFERENCES contact_info(contact_id) ON DELETE CASCADE
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
	contact_id INT NOT NULL UNIQUE,
	role_id INT NOT NULL,
	parlour_id INT NOT NULL,
	FOREIGN KEY (contact_id) REFERENCES contact_info(contact_id) 
	ON DELETE CASCADE,
	FOREIGN KEY (role_id) REFERENCES role(role_id),
	fOREIGN KEY (parlour_id) REFERENCES parlour(parlour_id) ON DELETE CASCADE
);


CREATE TABLE item_category(
	category_id SERIAL PRIMARY KEY,
	category_name VARCHAR(50) NOT NULL UNIQUE,
	description TEXT
);

-- Sale Price if the item is sold to customers.
CREATE TABLE item(
	item_id SERIAL PRIMARY KEY,
	item_name VARCHAR(30) NOT NULL UNIQUE,
	category_id INT NOT NULL,
	unit_of_measure VARCHAR(30),
	cost_price DECIMAL(10,2),
	sale_price DECIMAL(10,2),
	FOREIGN KEY (category_id) REFERENCES item_category(category_id)
);


CREATE TABLE supplier_item(
	supplier_id INT NOT NULL,
	item_id INT NOT NULL,
	supplier_item_code VARCHAR(50),
	purchase_price DECIMAL(10,2) NOT NULL,
	min_order_quantity DECIMAL(10,2) DEFAULT 1,
	is_preferred_supplier BOOLEAN DEFAULT FALSE,
	contract_start_date DATE,
	contract_end_date DATE,
	notes TEXT,
	PRIMARY KEY (supplier_id, item_id),
	FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id) ON DELETE CASCADE,
	FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE CASCADE
);

CREATE TABLE parlour_inventory(
	parlour_inventory_id SERIAL PRIMARY KEY,
	parlour_id INT NOT NULL,
	item_id INT NOT NULL,
	current_stock_quantity DECIMAL(10,2) NOT NULL DEFAULT 0,
	min_stock_level DECIMAL(10,2) DEFAULT 0,
	max_stock_level DECIMAL(10,2) DEFAULT 0,
	last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	UNIQUE (parlour_id, item_id),
	FOREIGN KEY (parlour_id) REFERENCES parlour(parlour_id) ON DELETE CASCADE,
	FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE CASCADE
);

-- Recipes to ensure products are separately treated from ingredients 
CREATE TABLE recipe(
	product_item_id INT NOT NULL,
	ingredient_item_id INT NOT NULL,
	quantity_required DECIMAL(10,2) NOT NULL,
	PRIMARY KEY (product_item_id, ingredient_item_id),
	FOREIGN KEY (product_item_id) REFERENCES item(item_id) ON DELETE CASCADE,
	FOREIGN KEY (ingredient_item_id) REFERENCES item(item_id) ON DELETE CASCADE,
	CHECK (product_item_id <> ingredient_item_id)
);

-- Transaction source tracking for multiple types
CREATE TABLE transaction_source_type(
	source_type_id SERIAL PRIMARY KEY,
	source_type_name VARCHAR(30) NOT NULL UNIQUE --Sale_order_item, purchase_receipt, waste_event
);

CREATE TABLE transaction_source(
	transaction_source_id SERIAL PRIMARY KEY,
	source_type_id INT NOT NULL,
	FOREIGN KEY (source_type_id) REFERENCES transaction_source_type(source_type_id) ON DELETE CASCADE
);


-- Account ID Nullable incase guest purchase
CREATE TABLE sale_order(
	sale_order_id SERIAL PRIMARY KEY,
	account_id INT,
	parlour_id INT NOT NULL,
	purchase_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	total_item_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
	discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
	final_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
	payment_status BOOLEAN NOT NULL DEFAULT FALSE,
	notes TEXT,
	FOREIGN KEY (account_id) REFERENCES account(account_id) ON DELETE SET NULL,
	FOREIGN KEY (parlour_id) REFERENCES parlour(parlour_id) ON DELETE SET NULL
);

CREATE TABLE sale_order_item(
	sale_order_item_id INT PRIMARY KEY,
	sale_order_id INT NOT NULL,
	item_id INT NOT NULL,
	quantity INT NOT NULL CHECK (quantity > 0),
	unit_price DECIMAL(10,2) NOT NULL,
	item_total_price DECIMAL(10,2) NOT NULL,
	notes TEXT,
	FOREIGN KEY (sale_order_item_id) REFERENCES transaction_source(transaction_source_id) ON DELETE CASCADE,
	FOREIGN KEY (sale_order_id) REFERENCES sale_order(sale_order_id) ON DELETE CASCADE,
	FOREIGN KEY (item_id) REFERENCES item(item_id) ON DELETE RESTRICT

); 

CREATE TABLE inventory_transaction_type(
	trans_type_id SERIAL PRIMARY KEY,
	trans_type_name VARCHAR(50) NOT NULL UNIQUE, --purchase, sale, waste, transfer (in/out), initial
	is_increase BOOLEAN NOT NULL --true for adding stock, false for removing
);

CREATE TABLE inventory_transaction(
	inv_transaction_id SERIAL PRIMARY KEY,
	trans_type_id INT NOT NULL,
	parlour_inventory_id INT NOT NULL,
	quantity DECIMAL(10,2),
	transaction_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	transaction_source_id INT, 
	staff_id INT,
	FOREIGN KEY (trans_type_id) REFERENCES inventory_transaction_type(trans_type_id) ON DELETE RESTRICT,
	FOREIGN KEY (parlour_inventory_id) REFERENCES parlour_inventory(parlour_inventory_id) ON DELETE RESTRICT,
	FOREIGN KEY (transaction_source_id) REFERENCES transaction_source(transaction_source_id) ON DELETE CASCADE,
	FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE SET NULL
);

-- Enforcing contact-info validation.

-- Validation Staff Contact Info Function
CREATE OR REPLACE FUNCTION validate_staff_contact_info()
RETURNS TRIGGER as $$
DECLARE 
	v_surname VARCHAR(30);
	v_forename VARCHAR(30);
	v_street VARCHAR(30),
	v_town VARCHAR(30);
	v_postcode VARCHAR(7);
	v_email VARCHAR(30);
	v_telephone_number VARCHAR(13)
BEGIN
	SELECT surname, forename, street, town, postcode, email_address, telephone_number
	INTO v_surname, v_forename, v_street, v_town, v_postcode, v_email, v_telephone_number
	FROM contact_info
	WHERE contact-id = NEW.contact_id;

	IF v_surname IS NULL OR v_forename IS NULL OR v_street IS NULL OR v_postcode OR v_email OR v_telephone_number IS NULL THEN
		RAISE EXCEPTION 'Staff contact info (contact_id: %) must have: surname, forename, street, town, postcode, email and phone number.', NEW.contact_id;
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Supplier Contact Info Validation Function
CREATE OR REPLACE FUNCTION validate_supplier_contact_info()
RETURNS TRIGGER AS $$
DECLARE
	v_surname VARCHAR(30);
	v_forename VARCHAR(30);
	v_street VARCHAR(30);
	v_town VARCHAR(30);
	v_postcode VARCHAR(30);

-- Account validation Function (requires email as username)
CREATE OR REPLACE FUNCTION validate_account_email_contact()
RETURNS TRIGGER AS $$
DECLARE
	v.email VARCHAR(80);
BEGIN
	SELECT email_address
	into v_email
	FROM contact_info
	WHERE contact_id = NEW.contact_id;

	IF v_email IS NULL THEN
		RAISE EXCEPTION 'Account contact info (contact_id: %) must have an email address for username.', NEW.contact_id;
	END IF

	IF EXISTS (
		SELECT 1 FROM account a 
		JOIN contact_info ci ON a.contact_id = ci.contact_id
		WHERE ci.email_address = v_email AND a.account_id <> NEW.account_id
		) THEN
		RAISE EXCEPTION 'The email address used for this account (contact_id: %) is already linked to another account.', NEW.contact_id;
	END IF;

	RETURN NEW;
END
$$ LANGUAGE plpgsql;

-- Trigger for staff
CREATE TRIGGER trg_validate_staff_contact
BEFORE INSERT ON OR UPDATE OF contact_id ON staff
FOR EACH ROW
	EXECUTE FUNCTION validate_staff_contact_info();


-- Trigger for Account
CREATE TRIGGER trg_validate_account_email
BEFORE INSERT ON OR UPDATE OF contact_id ON account
FOR EACH ROW
	EXECUTE FUNCTION validate_account_email_contact();

