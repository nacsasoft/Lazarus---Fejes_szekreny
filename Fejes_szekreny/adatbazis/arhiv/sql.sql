SELECT feeder_tpm.tpm_date AS "Preventív v. Javítás", feeder_tpm.tpm_outdate AS "Ellenörzés ideje", feeder_tpm.tpm_ds7i as "DS7i", users.u_name AS "operátor", feeder_types.ft_type AS "típus", feeder_size.size AS "méret",
CASE feeder_tpm.tpm_hibakod
    WHEN -1 THEN "OK"
    ELSE (SELECT e_desc FROM error_codes WHERE error_codes.id = feeder_tpm.tpm_hibakod)
END as "Feeder állapota"
FROM feeder_tpm
JOIN users ON feeder_tpm.u_id = users.id 
JOIN feeder_types ON feeder_tpm.tpm_type = feeder_types.id
JOIN feeder_size ON feeder_tpm.tpm_size = feeder_size.id
WHERE tpm_outdate >= "2017-01-01" and tpm_outdate <= "2017-04-31";

--Javitasra varo federek (TPM-bol)
SELECT feeder_tpm.tpm_outdate AS "Ellenörzés ideje", feeder_tpm.tpm_ds7i as "DS7i", users.u_name AS "Ellenőrizte", feeder_types.ft_type AS "Típus", feeder_size.size AS "Méret",
CASE 
    WHEN feeder_tpm.tpm_hibakod > -1 THEN (SELECT e_desc FROM error_codes WHERE error_codes.id = feeder_tpm.tpm_hibakod)
END as "Feeder állapota"
FROM feeder_tpm
JOIN users ON feeder_tpm.u_id = users.id 
JOIN feeder_types ON feeder_tpm.tpm_type = feeder_types.id
JOIN feeder_size ON feeder_tpm.tpm_size = feeder_size.id
WHERE tpm_outdate >= "2017-01-01" and tpm_outdate <= "2017-04-31" and feeder_tpm.tpm_javitasra = 1 and tpm_lezarva = 0
ORDER BY tpm_outdate and tpm_ds7i;


SELECT feeder_tpm.tpm_date AS "Preventív v. Javítás", feeder_tpm.tpm_outdate AS "Preventív ideje", feeder_tpm.tpm_ds7i as "DS7i", users.u_name AS "Preventives", feeder_types.ft_type AS "Típus", feeder_size.size AS "Méret" 
FROM feeder_tpm
JOIN users ON feeder_tpm.prev_u_id = users.id 
JOIN feeder_types ON feeder_tpm.tpm_type = feeder_types.id
JOIN feeder_size ON feeder_tpm.tpm_size = feeder_size.id
WHERE tpm_outdate >= "2017-01-01"  and tpm_outdate <= "2017-04-31" AND tpm_preventive = 1 AND tpm_lezarva = 1;


--TPM operátorok munkája:
SELECT feeder_tpm.tpm_outdate AS "Ellenörzés ideje", feeder_tpm.tpm_ds7i as "DS7i", users.u_name AS "TPM Operátor", feeder_types.ft_type AS "Típus", feeder_size.size AS "Méret" 
FROM feeder_tpm 
JOIN users ON feeder_tpm.u_id = users.id 
JOIN feeder_types ON feeder_tpm.tpm_type = feeder_types.id 
JOIN feeder_size ON feeder_tpm.tpm_size = feeder_size.id 
WHERE (tpm_outdate >= "2017-01-01" AND tpm_outdate <= "2017-04-31");


--Arhivalashoz....
--delete from repair where r_date <= "2015-12-31";
--delete from feeder_errors where r_id < 24332;
--delete from feeder_works where r_id < 24332;
--delete from usedparts where r_id < 24332;

--kiesett adagolók ds7i-ként összesítve :
SELECT count(ds7i) as darabszam,ds7i FROM repair 
WHERE (r_date >= "2016-06-01" AND r_date <= "2017-01-01") and r_type = 1  AND repair.r_del = 0 
GROUP BY ds7i ORDER BY darabszam desc;

------------------------------------------------------------------------------------------------------------------------------
--fejes szekreny lekerdezesek :
select fej_tipus.fej_tipus as "Típus", fejek.ajto as "Ajtó", fej_allapot.fej_allapot as "Fej állapota"
from fejek
join fej_tipus on fejek.f_id = fej_tipus.id 
join fej_allapot on fejek.fej_allapot_id = fej_allapot.id 
where fejek.hely = 1 order by fejek.ajto;

SELECT fejek.*, fej_tipus.fej_tipus from fejek
JOIN fej_tipus ON fejek.f_id = fej_tipus.id 
JOIN fej_allapot ON fejek.fej_allapot_id = fej_allapot.id 
WHERE hely=1 ORDER BY ajto;

--Szekrényben lévő fejek (állapotok, megjegyzés)
SELECT fejek.ajto,felhasznalok.u_name as "Név", fejek.be_datum, fejek.be_ido, fejek.be_megj, fejek.sorozatszam, fej_tipus.fej_tipus, fej_allapot.fej_allapot from fejek
JOIN fej_tipus ON fejek.f_id = fej_tipus.id 
JOIN felhasznalok ON fejek.be_u_id = felhasznalok.id 
JOIN fej_allapot ON fejek.fej_allapot_id = fej_allapot.id 
WHERE hely=1 ORDER BY ajto;

--Adott időszakban történt fejcserék
SELECT fejek.ajto,felhasznalok.u_name as "Név", fejek.be_datum, fejek.ki_datum, fejek.be_megj, fejek.sorozatszam, fej_tipus.fej_tipus, fej_allapot.fej_allapot from fejek
JOIN fej_tipus ON fejek.f_id = fej_tipus.id 
JOIN felhasznalok ON fejek.be_u_id = felhasznalok.id 
JOIN fej_allapot ON fejek.fej_allapot_id = fej_allapot.id 
WHERE hely=0 AND ki_datum >= "2017-01-01" AND ki_datum <= "2017-09-20" ORDER BY ajto;

--Szekrényben lévő fejek állapota:
SELECT fejek.ajto,felhasznalok.u_name as "Név", fejek.be_datum, fejek.be_ido, fejek.be_megj, fejek.sorozatszam, fej_tipus.fej_tipus, fej_allapot.fej_allapot from fejek
JOIN fej_tipus ON fejek.f_id = fej_tipus.id 
JOIN felhasznalok ON fejek.be_u_id = felhasznalok.id 
JOIN fej_allapot ON fejek.fej_allapot_id = fej_allapot.id 
WHERE hely=1 AND fej_allapot_id = 1 ORDER BY ajto;

--Fejcserék fejtípus szerint:
SELECT fejek.ajto,felhasznalok.u_name as "Név", fejek.be_datum, fejek.ki_datum, fejek.be_megj, fejek.sorozatszam, fej_tipus.fej_tipus, fej_allapot.fej_allapot from fejek
JOIN fej_tipus ON fejek.f_id = fej_tipus.id 
JOIN felhasznalok ON fejek.be_u_id = felhasznalok.id 
JOIN fej_allapot ON fejek.fej_allapot_id = fej_allapot.id 
WHERE hely=0 AND ki_datum >= "2017-01-01" AND ki_datum <= "2017-09-20" AND f_id = 6 
ORDER BY ki_datum;

--Fejcserék sorokra szűrve:
SELECT fejek.ajto,felhasznalok.u_name as "Név", fejek.be_datum, fejek.ki_datum, 
sorok.sor_name AS "Felhasználás helye", fejek.be_megj, fejek.sorozatszam, fej_tipus.fej_tipus, fej_allapot.fej_allapot from fejek
JOIN fej_tipus ON fejek.f_id = fej_tipus.id 
JOIN felhasznalok ON fejek.be_u_id = felhasznalok.id 
JOIN fej_allapot ON fejek.fej_allapot_id = fej_allapot.id 
JOIN sorok on fejek.felh_sor_id = sorok.id
WHERE hely=0 AND ki_datum >= "2017-01-01" AND ki_datum <= "2017-09-20" AND felh_sor_id = 1 
ORDER BY ki_datum;

--Szekrényben lévő bevethető fejek:
SELECT fejek.ajto,felhasznalok.u_name as "Név", fejek.be_datum, fejek.be_ido, fejek.be_megj, fejek.sorozatszam, fej_tipus.fej_tipus, fej_allapot.fej_allapot from fejek
JOIN fej_tipus ON fejek.f_id = fej_tipus.id 
JOIN felhasznalok ON fejek.be_u_id = felhasznalok.id 
JOIN fej_allapot ON fejek.fej_allapot_id = fej_allapot.id 
WHERE hely=1 AND ( fej_allapot_id = 1 OR fej_allapot_id = 3 OR fej_allapot_id = 9 ) ORDER BY ajto;

--Szekrényben lévő hibás fejek:
SELECT fejek.ajto,felhasznalok.u_name as "Név", fejek.be_datum, fejek.be_ido, fejek.be_megj, fejek.sorozatszam, fej_tipus.fej_tipus, fej_allapot.fej_allapot from fejek
JOIN fej_tipus ON fejek.f_id = fej_tipus.id 
JOIN felhasznalok ON fejek.be_u_id = felhasznalok.id 
JOIN fej_allapot ON fejek.fej_allapot_id = fej_allapot.id 
WHERE hely=1 AND ( fej_allapot_id <> 1 AND fej_allapot_id <> 3 AND fej_allapot_id <> 9 ) ORDER BY ajto;

--Használatban lévő fejek:
SELECT fejek.felh_gep_ds7i, fejek.ki_datum, felhasznalok.u_name as "Név", fejek.sorozatszam, gepek.gep_tipus, fej_tipus.fej_tipus, sorok.sor_name, fejek.felh_portal as "Portál" from fejek
JOIN gepek ON fejek.felh_gep_id = gepek.id
JOIN fej_tipus ON fejek.f_id = fej_tipus.id 
JOIN felhasznalok ON fejek.ki_u_id = felhasznalok.id 
JOIN sorok ON fejek.felh_sor_id = sorok.id 
WHERE hely=2 ORDER BY fejek.felh_sor_id;

--Fej típushoz tartozó sorok,gépek:
SELECT fejek.f_id as "Fej típus", sorok.sor_name, gepek.gep_tipus  from fejek
JOIN gepek ON fejek.felh_gep_id = gepek.id
JOIN fej_tipus ON fejek.f_id = fej_tipus.id  
JOIN sorok ON fejek.felh_sor_id = sorok.id 
WHERE fejek.f_id = 7 GROUP BY gepek.gep_tipus, sorok.sor_name ORDER BY fejek.felh_sor_id;
