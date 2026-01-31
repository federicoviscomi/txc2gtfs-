package main

import (
	"database/sql"
	"encoding/xml"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"

	_ "github.com/lib/pq"
)

const (
	XML_DIR = "./data/input/unzipped"
)

func main() {
	db, err := connectDB()
	if err != nil {
		log.Fatal("DB connection failed:", err)
		return
	}
	defer db.Close()

	err = filepath.Walk(XML_DIR, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() || filepath.Ext(path) != ".xml" {
			return nil
		}

		fmt.Println("Processing", path)
		if err := parseXML(path, db); err != nil {
			log.Println("Error parsing", path, ":", err)
		}
		return nil
	})
	if err != nil {
		log.Fatal(err)
	}
}

func connectDB() (*sql.DB, error) {
	dataSourceName := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		getenv("POSTGRES_HOST", "localhost"),
		getenv("POSTGRES_PORT", "5432"),
		getenv("POSTGRES_USER", "txc_user"),
		getenv("POSTGRES_PASSWORD", "txc_pass"),
		getenv("POSTGRES_DB", "txc_db"),
	)
	db, err := sql.Open("postgres", dataSourceName)
	if err != nil {
		return nil, err
	}
	fmt.Println("Database connected")
	return db, nil
}

func getenv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

// --- Parse XML ---
func parseXML(path string, db *sql.DB) error {
	f, err := os.Open(path)
	if err != nil {
		return err
	}
	defer f.Close()

	decoder := xml.NewDecoder(f)
	for {
		t, err := decoder.Token()
		if err != nil {
			if err == io.EOF {
				break
			}
			return err
		}
		switch se := t.(type) {
		case xml.StartElement:
			if se.Name.Local == "Service" {
				// Example: extract Service ID attribute
				for _, attr := range se.Attr {
					if attr.Name.Local == "id" {
						fmt.Println("Service ID:", attr.Value)
						// Optionally insert into DB
						// _, _ = db.Exec("INSERT INTO services(id) VALUES($1)", attr.Value)
					}
				}
			}
		}
	}
	return nil
}
