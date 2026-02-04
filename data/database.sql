-- Temporarily disable FK enforcement so dependent tables can be dropped cleanly
PRAGMA foreign_keys = OFF;

DROP VIEW IF EXISTS "Показать_товары";
DROP TABLE IF EXISTS "Товар";
DROP TABLE IF EXISTS "Поставщик";
DROP TABLE IF EXISTS "Тип";

PRAGMA foreign_keys = ON;

-- Reference data: product types
CREATE TABLE IF NOT EXISTS "Тип" (
    "ID"            INTEGER PRIMARY KEY,
    "Наименование"  TEXT    NOT NULL UNIQUE
);

-- Reference data: suppliers
CREATE TABLE IF NOT EXISTS "Поставщик" (
    "ID"         INTEGER PRIMARY KEY,
    "Поставщик"  TEXT    NOT NULL UNIQUE
);

-- Fact table: items
CREATE TABLE IF NOT EXISTS "Товар" (
    "ID"             INTEGER PRIMARY KEY,
    "Тип_id"         INTEGER NOT NULL,
    "Поставщик_id"   INTEGER NOT NULL,
    "Категория"      TEXT    NOT NULL
                        CHECK ("Категория" IN ('Для мальчиков','Для девочек','До года')),
    "Цвет"           TEXT    NOT NULL,
    "Цена"           NUMERIC NOT NULL DEFAULT 0.00
                        CHECK ("Цена" >= 0 AND round("Цена", 2) = "Цена"),
    "Количество"     INTEGER NOT NULL DEFAULT 1
                        CHECK ("Количество" >= 0),
    "Цена_закупки"   NUMERIC NOT NULL DEFAULT 0.00
                        CHECK ("Цена_закупки" >= 0 AND round("Цена_закупки", 2) = "Цена_закупки"),
    "Дата_закупки"   TEXT    NOT NULL DEFAULT (DATE('now'))
                        CHECK (
                            date("Дата_закупки") IS NOT NULL
                            AND "Дата_закупки" = strftime('%Y-%m-%d', "Дата_закупки")
                        ),
    "Цена_продажи"   NUMERIC NOT NULL DEFAULT 0.00
                        CHECK ("Цена_продажи" >= 0 AND round("Цена_продажи", 2) = "Цена_продажи"),
    "Дата_продажи"   TEXT
                        CHECK (
                            "Дата_продажи" IS NULL
                            OR (
                                date("Дата_продажи") IS NOT NULL
                                AND "Дата_продажи" = strftime('%Y-%m-%d', "Дата_продажи")
                                AND date("Дата_продажи") >= date("Дата_закупки")
                            )
                        ),
    FOREIGN KEY ("Тип_id")       REFERENCES "Тип"("ID")         ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY ("Поставщик_id") REFERENCES "Поставщик"("ID")   ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Read-only view for formatted output
CREATE VIEW "Показать_товары" AS
SELECT
    t."ID",
    tp."Наименование" AS "Тип",
    ps."Поставщик"    AS "Поставщик",
    t."Категория",
    t."Цвет",
    replace(printf('%,.2f', t."Цена"), ',', ' ')          AS "Цена",
    t."Количество",
    replace(printf('%,.2f', t."Цена_закупки"), ',', ' ')  AS "Цена_закупки",
    t."Дата_закупки",
    replace(printf('%,.2f', t."Цена_продажи"), ',', ' ')  AS "Цена_продажи",
    t."Дата_продажи"
FROM "Товар" AS t
JOIN "Тип"       AS tp ON tp."ID" = t."Тип_id"
JOIN "Поставщик" AS ps ON ps."ID" = t."Поставщик_id";