USE donor_registry;

-- Organ types
INSERT INTO organ_types (name, description) VALUES
  ('Kidney',''),
  ('Liver',''),
  ('Heart','');

-- Hospitals
INSERT INTO hospitals (name, city, state) VALUES
  ('Columbia University Irving Medical Center','New York','NY'),
  ('NYU Langone Health','New York','NY');

-- Donors
INSERT INTO donors (first_name,last_name,dob,gender,blood_type,hla_type,city,state,hospital_id)
VALUES
  ('Ravi','Sharma','1988-05-12','M','O+','A*01:01 B*08:01','New York','NY',1),
  ('Neha','Kapoor','1990-11-23','F','A-','A*02:01 B*07:02','New York','NY',2);

-- Recipients
INSERT INTO recipients (first_name,last_name,dob,gender,blood_type,hla_type,needed_organ_id,urgency,waitlist_date,city,state,hospital_id)
VALUES
  ('Arjun','Patel','1995-02-08','M','O+','A*01:01 B*08:01', (SELECT organ_type_id FROM organ_types WHERE name='Kidney'), 9, CURRENT_DATE, 'New York','NY',1),
  ('Meera','Iyer','1986-07-15','F','A-','A*02:01 B*07:02', (SELECT organ_type_id FROM organ_types WHERE name='Liver'), 6, CURRENT_DATE, 'New York','NY',2);

-- Donations (link donor -> organ)
INSERT INTO donations (donor_id, organ_type_id, donation_date, status, health_rating, hospital_id)
VALUES
  (1, (SELECT organ_type_id FROM organ_types WHERE name='Kidney'), CURRENT_DATE, 'Available', 8, 1),
  (2, (SELECT organ_type_id FROM organ_types WHERE name='Liver'), CURRENT_DATE, 'Available', 7, 2);

-- Matches (example proposed matches with a score)
INSERT INTO matches (donation_id, recipient_id, match_score, match_status)
VALUES
  (1, 1, 92.500, 'Proposed'),
  (2, 2, 76.300, 'Proposed');
