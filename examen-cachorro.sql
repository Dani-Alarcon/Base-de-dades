/*EXERCICI 1*/
CREATE OR REPLACE PROCEDURE proc_pac(var_dni_metge metge.dni_metge%TYPE)   as $$
DECLARE
   var_dadeS RECORD;
BEGIN
    IF existeix_metge(var_dni_metge) AND metge_visita(var_dni_metge)  then
            FOR var_dades IN SELECT DISTINCT v.dni_pacient, p.cognom1, p.data_naix, p.telefon
                     FROM  persona p,visita v
                     WHERE v.dni_metge = var_dni_metge AND p.dni = dni_pacient  LOOP
                RAISE NOTICE 'DNI: %, COGNOM: %, DATA NAIXEMENT: %, TELÈFON: % ',var_dades.dni_pacient, var_dades.cognom1, var_dades.data_naix, var_dades.telefon;
                UPDATE persona SET mail = (concat(cognom1,'_',mail)) WHERE dni = var_dni_metge;
                end loop;
    else
        RAISE 'El metge no existeix o no te visitas';
        end if;
    EXCEPTION
    WHEN OTHERS THEN
    RAISE '%, %', SQLERRM, SQLSTATE;
end
$$ language plpgsql;

CREATE OR REPLACE FUNCTION existeix_metge(var_dni_metge metge.dni_metge%TYPE) returns boolean as $$
    DECLARE
        var_metge metge.dni_metge%TYPE;
    BEGIN
        SELECT dni_metge INTO STRICT var_metge from metge WHERE dni_metge = var_dni_metge;
        RETURN TRUE;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        RAISE '%, %', SQLERRM, SQLSTATE;
end
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION metge_visita(var_dni_metge metge.dni_metge%TYPE) returns boolean as $$
    DECLARE
        var_metge metge.dni_metge%TYPE;
    BEGIN
        SELECT dni_metge INTO STRICT var_metge from visita WHERE dni_metge = var_dni_metge LIMIT 1;
        RETURN TRUE;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        RAISE '%, %', SQLERRM, SQLSTATE;
end
$$ language plpgsql;
/*Joc de proves*/
--Proveu el procediment amb aquests DNIs de metges:
CALL proc_pac(30995635);
CALL proc_pac(30995999);

--Inserim un nou metge a la base de dades
INSERT INTO PERSONA VALUES(82344561,'Sara','Rius','Clavell','1967-11-15','654811345','srius@mail.cat');

INSERT INTO METGE VALUES(82344561,'Dermatoleg');

--I provem que salti l’excepció del metge sense visites
CALL proc_pac(82344561);


/* EXERCICI 2*/
CREATE TABLE ingressos_visites(total NUMERIC(14,3));
--INSERT INTO ingressos_visites (total) VALUES (0);

SELECT total from ingressos_visites;

CREATE OR REPLACE PROCEDURE proc_act_ingressos() as $$
DECLARE
    var_total INTEGER;
BEGIN
    SELECT SUM(preu) INTO var_total FROM visita;
    UPDATE ingressos_visites SET total = var_total;
end;
$$ LANGUAGE plpgsql;
CALL proc_act_ingressos();

CREATE OR REPLACE FUNCTION actual_ingres()RETURNS TRIGGER as $$
BEGIN

    UPDATE ingressos_visites SET total = total + new.preu;
    RAISE NOTICE 'Els ingressos actuals per les visites són %',(SELECT total from ingressos_visites) ;
    RETURN NEW;
    end;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_act_ingressos BEFORE INSERT
ON visita
FOR EACH ROW
EXECUTE PROCEDURE actual_ingres();
/*JOC DE PROVES*/
INSERT INTO visita VALUES(58555995497,38702232,43995635,000028,'https://www.cemedioc.cat/infomes/pdfs/589995497.pdf','2025-05-02',125);


/*segona part*/

create or replace function func_comprovar_data(var_data visita.data_visita%TYPE) RETURNS BOOLEAN AS $$
    BEGIN
     if var_data <= CURRENT_DATE then
         return true;
     end if;
     if var_data > CURRENT_DATE then
         RAISE EXCEPTION 'Data incorrecte';
     end if;
    end;

$$LANGUAGE plpgsql;

create or replace function func_preu(var_preu visita.preu%type, var_preu2 visita.preu%type ) RETURNS BOOLEAN AS $$
     BEGIN
     if var_preu = var_preu2  then
         return true;
     end if;
     if var_preu < var_preu2 or var_preu > var_preu2 then
         RAISE EXCEPTION'No es pot modifcar el preu';
     end if;
    end;
$$LANGUAGE plpgsql;

create or replace function func_data() RETURNS TRIGGER AS $$
    BEGIN
         if TG_OP = 'INSERT' AND func_comprovar_data(NEW.data_visita) then
             RAISE NOTICE 'Data correcte';
         elseif TG_OP = 'UPDATE' AND func_preu(NEW.preu, OLD.preu) THEN
            RAISE NOTICE 'Update fet';
         elseif TG_OP = 'DELETE' THEN
             RAISE EXCEPTION 'No es poden eliminar visitas';
         else
             RAISE EXCEPTION 'ERROR';
         end if;
          RETURN NEW;
    end

$$LANGUAGE plpgsql;
