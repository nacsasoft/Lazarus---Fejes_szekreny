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
--delete from repair where r_date <= "2016-12-31";
--delete from feeder_errors where r_id < 32333;
--delete from feeder_works where r_id < 32333;
--delete from usedparts where r_id < 32333;
--delete from magazin_repair where m_date <= "2016-12-31";
--delete from magazin_repair_works where m_id < 1151;
--delete from used_magazin_parts where m_r_id < 1151;
--delete from trolley_repair where tr_date <= "2016-12-31";
--delete from trolley_works where r_id < 1017;
--delete from used_trolley_parts where t_r_id < 1017;
--delete from feeder_tpm where tpm_date <= "2016-12-31";



--kiesett adagolók ds7i-ként összesítve :
SELECT count(ds7i) as darabszam,ds7i FROM repair 
WHERE (r_date >= "2016-06-01" AND r_date <= "2017-01-01") and r_type = 1  AND repair.r_del = 0 
GROUP BY ds7i ORDER BY darabszam desc;



------------------------------------------------------------------------------------------------------------------------------
--fejes szekreny lekerdezesek (régi adatbázis) :
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

------------------------------------------------------------------------------------------------------------------------------
--Fejes szekreny lekerdezesek (új adatbázis) :

--Fej típushoz tartozó sorok : 
SELECT gep_infok.*, sorok.sor_name from gep_infok 
--JOIN fej_tipus ON gep_infok.fej_tipus_1 = fej_tipus.id  
JOIN sorok ON gep_infok.sorban = sorok.id 
WHERE (gep_infok.fej_tipus_1 = 10) OR (gep_infok.fej_tipus_2 = 10) OR (gep_infok.fej_tipus_3 = 10) OR (gep_infok.fej_tipus_4 = 10) GROUP BY sorok.sor_name ORDER BY sorok.sor_name;

--Kiválasztott fejtípushoz,sorhoz tartozó gépek:
SELECT gep_infok.*, sorok.sor_name, gepek.gep_tipus as gep  from gep_infok 
JOIN gepek ON gep_infok.gep_tipus = gepek.id 
-- JOIN fej_tipus ON gep_infok.fej_tipus_1 = fej_tipus.id  
JOIN sorok ON gep_infok.sorban = sorok.id 
WHERE sorok.id = 6 AND ((gep_infok.fej_tipus_1 = 8) OR (gep_infok.fej_tipus_2 = 8) OR (gep_infok.fej_tipus_3 = 8) OR (gep_infok.fej_tipus_4 = 8)) GROUP BY gep_infok.gep_ds7i ORDER BY sorok.sor_name;


--Fej típushoz tartozó gép(ek) a kiválasztott sorban:
SELECT fej.fej_tipus as "Fej típus", sorok.sor_name, gepek.gep_tipus, gepek.id as "gep_id" from fej 
JOIN gepek ON fej.felh_gep_id = gepek.id
JOIN fej_tipus ON fej.fej_tipus = fej_tipus.id  
JOIN sorok ON fej.felh_sor_id = sorok.id 
WHERE fej.fej_tipus = 8 AND sorok.id = 6 AND fej.hely = 2 GROUP BY gepek.gep_tipus ORDER BY fej.felh_sor_id;


-- Szekrényben lévő fejek:
select fejberakas.be_ajto as ajto, fejberakas.be_datum as datum, fejberakas.be_ido as ido, fejberakas.be_megj as megj, 
fej.sorozatszam as sn, fej_tipus.fej_tipus as tip, fej_allapot.fej_allapot as allapot, fejberakas.be_allapot as allapot_id from fej 
JOIN fejberakas ON fejberakas.fej_id = fej.id 
JOIN fej_allapot ON fejberakas.be_allapot = fej_allapot.id 
JOIN felhasznalok ON fejberakas.be_u_id = felhasznalok.id 
JOIN fej_tipus ON fej.fej_tipus = fej_tipus.id 
where hely = 1 
group by sorozatszam order by be_ajto;


--Használatban levö szekrények:
SELECT fejberakas.be_ajto,fejberakas.be_datum,fejberakas.be_ido, fej.sorozatszam, fej_tipus.fej_tipus FROM fej
JOIN fej_tipus ON fej.fej_tipus = fej_tipus.id 
JOIN fejberakas ON fej.id = fejberakas.fej_id 
WHERE fej.hely=1 GROUP BY sorozatszam ORDER BY be_ajto, be_datum, be_ido;

--Használatban lévő fejek:
SELECT fej.felh_gep_ds7i, fej.sorozatszam, gepek.gep_tipus, fej_tipus.fej_tipus, sorok.sor_name, fej.felh_portal as Portál from fej
JOIN gepek ON fej.felh_gep_id = gepek.id
JOIN fej_tipus ON fej.fej_tipus = fej_tipus.id 
JOIN sorok ON fej.felh_sor_id = sorok.id 
WHERE fej.hely=2 ORDER BY sorok.sor_name;

--Adott időszakban történt fejcserék
SELECT fejberakas.be_ajto,felhasznalok.u_name as Név, fejberakas.be_datum, fejkivetel.ki_datum, fejberakas.be_megj, fej.sorozatszam, fej_tipus.fej_tipus, fej_allapot.fej_allapot, 
sorok.sor_name as Sor, fej.felh_gep_ds7i as DS7i, gepek.gep_tipus, fej.felh_portal FROM fej
JOIN fej_tipus ON fej.fej_tipus = fej_tipus.id 
JOIN felhasznalok ON fejberakas.be_u_id = felhasznalok.id 
JOIN fej_allapot ON fejberakas.be_allapot = fej_allapot.id 
JOIN fejberakas ON fej.id = fejberakas.fej_id 
JOIN fejkivetel ON fej.id = fejkivetel.fej_id 
JOIN sorok ON fej.felh_sor_id = sorok.id 
JOIN gepek ON fej.felh_gep_id = gepek.id 
WHERE hely <> 1 AND (ki_oka = 1 OR ki_oka = 3) AND ki_datum >= "2017-01-01" AND ki_datum <= "2017-12-30" 
ORDER BY ki_datum;

--Fejcserék fejtípus szerint:
SELECT fejberakas.be_ajto,felhasznalok.u_name as Név, fejberakas.be_datum, fejkivetel.ki_datum, fejberakas.be_megj, fej.sorozatszam, fej_tipus.fej_tipus, fej_allapot.fej_allapot, 
sorok.sor_name as Sor, fej.felh_gep_ds7i as DS7i, gepek.gep_tipus, fej.felh_portal FROM fej
JOIN fej_tipus ON fej.fej_tipus = fej_tipus.id 
JOIN felhasznalok ON fejberakas.be_u_id = felhasznalok.id 
JOIN fej_allapot ON fejberakas.be_allapot = fej_allapot.id 
JOIN fejberakas ON fej.id = fejberakas.fej_id 
JOIN fejkivetel ON fej.id = fejkivetel.fej_id 
JOIN sorok ON fej.felh_sor_id = sorok.id 
JOIN gepek ON fej.felh_gep_id = gepek.id 
WHERE hely <> 1 AND ki_oka = 1 AND ki_datum >= "2017-01-01" AND ki_datum <= "2017-12-30" AND fej.fej_tipus = 7 
ORDER BY ki_datum;

--Adott soron cserélt fejek:
SELECT fejkivetel.ki_ajto, felhasznalok.u_name as Név, fejkivetel.ki_datum, fej.sorozatszam, fej_tipus.fej_tipus, 
sorok.sor_name as Sor, fej.felh_gep_ds7i as DS7i, gepek.gep_tipus, fej.felh_portal, ki_okok.ki_ok as "kivétel oka" FROM fej
JOIN fej_tipus ON fej.fej_tipus = fej_tipus.id 
JOIN felhasznalok ON fejkivetel.ki_u_id = felhasznalok.id 
JOIN fejkivetel ON fej.id = fejkivetel.fej_id 
join ki_okok on fejkivetel.ki_oka = ki_okok.id 
JOIN sorok ON fej.felh_sor_id = sorok.id 
JOIN gepek ON fej.felh_gep_id = gepek.id 
WHERE ki_datum >= "2017-01-01" AND ki_datum <= "2018-01-30" and ki_oka = 1 --AND felh_sor_id = 10 
ORDER BY ki_datum, sor_name;



--Fejcserék az adott gépen (DS7i alapján):
SELECT fejkivetel.ki_ajto,felhasznalok.u_name as Név, fejkivetel.ki_datum, fej.sorozatszam, fej_tipus.fej_tipus, fejkivetel.gepre_ds7i as DS7i, gepek.gep_tipus, 
fejkivetel.portalra, ki_okok.ki_ok AS "Kivétel oka" FROM fej
JOIN fej_tipus ON fej.fej_tipus = fej_tipus.id 
JOIN felhasznalok ON fejkivetel.ki_u_id = felhasznalok.id 
JOIN fejkivetel ON fej.id = fejkivetel.fej_id 
JOIN gepek ON fejkivetel.gepre_id = gepek.id 
JOIN ki_okok ON fejkivetel.ki_oka = ki_okok.id 
WHERE (ki_datum >= "2017-01-01" AND ki_datum <= "2017-12-30") AND fejkivetel.gepre_ds7i = "672349" 
ORDER BY ki_datum;