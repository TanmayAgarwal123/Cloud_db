-- Donor Registry - Relational Schema

CREATE DATABASE IF NOT EXISTS donor_registry
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE donor_registry;

-- Reference/lookup: Hospitals
CREATE TABLE IF NOT EXISTS hospitals (
  hospital_id     BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name            VARCHAR(200) NOT NULL,
  city            VARCHAR(120) NULL,
  state           VARCHAR(80)  NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Reference/lookup: Organ types
CREATE TABLE IF NOT EXISTS organ_types (
  organ_type_id   BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  name            VARCHAR(80) NOT NULL,
  description     TEXT NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_organ_types_name (name)
) ENGINE=InnoDB;

-- Donors
CREATE TABLE IF NOT EXISTS donors (
  donor_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  first_name      VARCHAR(120) NOT NULL,
  last_name       VARCHAR(120)  NOT NULL,
  dob             DATE          NULL,      
  gender          ENUM('M','F','O') NULL,    
  blood_type      ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
  hla_type        VARCHAR(200)  NULL,   
  comorbidities   TEXT          NULL,     
  city            VARCHAR(120)  NULL,
  state           VARCHAR(80)   NULL,
  hospital_id     BIGINT UNSIGNED NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_donors_hospital
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  KEY ix_donors_blood_type (blood_type),
  KEY ix_donors_hospital (hospital_id)
) ENGINE=InnoDB;

-- Recipients (patients on waiting list)
CREATE TABLE IF NOT EXISTS recipients (
  recipient_id    BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  first_name      VARCHAR(120) NOT NULL,
  last_name       VARCHAR(120) NOT NULL,
  dob             DATE         NULL,
  gender          ENUM('M','F','O') NULL,
  blood_type      ENUM('A+','A-','B+','B-','AB+','AB-','O+','O-') NOT NULL,
  hla_type        VARCHAR(200) NULL,
  comorbidities   TEXT         NULL,
  needed_organ_id BIGINT UNSIGNED NOT NULL,
  urgency         TINYINT UNSIGNED NOT NULL DEFAULT 5,  
  waitlist_date   DATE NOT NULL DEFAULT (CURRENT_DATE),
  city            VARCHAR(120) NULL,
  state           VARCHAR(80)  NULL,
  hospital_id     BIGINT UNSIGNED NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_recipients_organ_type
    FOREIGN KEY (needed_organ_id) REFERENCES organ_types(organ_type_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_recipients_hospital
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  KEY ix_recipients_blood_type (blood_type),
  KEY ix_recipients_urgency (urgency),
  KEY ix_recipients_needed_organ (needed_organ_id)
) ENGINE=InnoDB;

-- Donations (each organ offered by a donor)
CREATE TABLE IF NOT EXISTS donations (
  donation_id     BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  donor_id        BIGINT UNSIGNED NOT NULL,
  organ_type_id   BIGINT UNSIGNED NOT NULL,
  donation_date   DATE NOT NULL DEFAULT (CURRENT_DATE),
  status          ENUM('Available','Matched','Transplanted','Withdrawn','Expired') NOT NULL DEFAULT 'Available',
  health_rating   TINYINT UNSIGNED NULL,  
  hospital_id     BIGINT UNSIGNED NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_donations_donor
    FOREIGN KEY (donor_id) REFERENCES donors(donor_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_donations_organ_type
    FOREIGN KEY (organ_type_id) REFERENCES organ_types(organ_type_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_donations_hospital
    FOREIGN KEY (hospital_id) REFERENCES hospitals(hospital_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  KEY ix_donations_status (status),
  KEY ix_donations_organ_type (organ_type_id),
  KEY ix_donations_donor (donor_id)
) ENGINE=InnoDB;

-- Matches (AI / rules engine proposals & accepted matches)
CREATE TABLE IF NOT EXISTS matches (
  match_id        BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  donation_id     BIGINT UNSIGNED NOT NULL,
  recipient_id    BIGINT UNSIGNED NOT NULL,
  match_score     DECIMAL(6,3) NULL,  
  match_status    ENUM('Proposed','Accepted','Rejected','Cancelled') NOT NULL DEFAULT 'Proposed',
  match_date      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_matches_donation
    FOREIGN KEY (donation_id) REFERENCES donations(donation_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_matches_recipient
    FOREIGN KEY (recipient_id) REFERENCES recipients(recipient_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  UNIQUE KEY uk_matches_unique_proposal (donation_id, recipient_id), 
  KEY ix_matches_score (match_score),
  KEY ix_matches_status (match_status)
) ENGINE=InnoDB;


