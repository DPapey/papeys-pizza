# Papeys Pizza: A Comprehensive Database Schema

---

## Project Brief

This project details the design and implementation of a robust and scalable relational database schema for "Papeys Pizza," a scenario-based local pizza parlour chain. As Papeys Pizza plans for national expansion, a modern and efficient database system is crucial to support their growth, manage diverse operations, and facilitate advanced business reporting, especially for stock management.

The database is built to handle:
* **Customer Order Management:** Detailed tracking of all customer purchases.
* **Integrated Arcade Operations:** Support for arcade facilities within parlours, including customer "pizza-points" cards.
* **Granular Inventory Tracking:** Precise stock management for each parlour, allowing for cross-location queries and tracking of various item types (food, decorations, tableware).
* **Supplier Relationships:** Management of multiple food suppliers and their specific ingredients.
* **Multi-Location Support:** Ability to track and potentially facilitate transfers between various parlour establishments.
* **Unified Contact Information:** A flexible system for managing contact details for staff, customers, parlours, and suppliers, with conditional validation requirements to be enforced at the application level or database triggers. (e.g., staff needing a name and postcode, parlours needing a full address).
---

## Key Features & Design Highlights

This schema has been meticulously crafted to ensure data integrity, scalability, and ease of reporting. Here's what makes it stand out:

* **Integrated Business Model:** Seamlessly combines the operational needs of both a pizza parlour (sales, inventory, supply chain) and an arcade (customer loyalty programme).
* **Comprehensive Customer & Staff Management:** Features a unified `contact_info` table for flexible data capture, alongside distinct account and role-based access for staff.
* **Advanced Inventory & Supply Chain:** Implements detailed multi-parlour inventory tracking, extensive item management, and robust supplier relationship management.
* **Robust Sales & Order Processing:** Handles `sale_order` specifics, accommodating both registered customer accounts and guest purchases.
* **Strong Data Integrity:**
    * Designed following **3rd Normal Form (3NF)** to minimise redundancy.
    * Extensive use of **Primary Keys (`PRIMARY KEY`)** and **Foreign Keys (`FOREIGN KEY`)** for clear relationships and referential integrity.
    * Leverages **`NOT NULL`**, **`UNIQUE`**, and **`CHECK`** constraints to enforce critical business rules.
    * Thoughtful application of **`ON DELETE CASCADE`**, **`ON DELETE SET NULL`**, and **`ON DELETE RESTRICT`** to manage data dependencies gracefully.

---

## Technologies Used

* **PostgreSQL**: Chosen for its robustness, extensibility, and performance as a relational database management system.
* **pgAdmin**: Utilised for database administration and development.
* **Docker**: Employed for containerising the PostgreSQL environment, ensuring easy setup and portability.
* **Git**: Used for version control of the schema and associated scripts.

---

## Database Schema (ER Diagram)

Below is the Entity-Relationship (ER) Diagram illustrating the table structure and relationships within the Papeys Pizza database.

![Papeys Pizza ER Diagram](images/papeys_pizza_erd.png)

---
