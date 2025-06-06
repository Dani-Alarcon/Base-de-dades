-- ---------------------------------------------------------------------
-- EJERCICI 1: Procediment proc_pac(dniMetge)
-- ---------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE proc_pac(dniMetge NUMERIC(9)) AS $$
DECLARE
    var_pacient      RECORD;
    var_cognom_metge VARCHAR(20);

    CURSOR curs_pacients IS
      SELECT p.dni, p.nom, p.cognom1, p.data_naix, p.telefon, p.mail
      FROM persona p
      JOIN metge m ON p.dni = m.dni_metge
      WHERE m.dni_metge = dniMetge;
BEGIN
    SELECT p.cognom1
      INTO var_cognom_metge
    FROM persona p
    JOIN metge m ON p.dni = m.dni_metge
    WHERE m.dni_metge = dniMetge;

    FOR var_pacient IN curs_pacients LOOP
        RAISE NOTICE
          'DNI: %, Nom: %, Cognom: %, Data de naixement: %, Telèfon: %',
          var_pacient.dni,
          var_pacient.nom,
          var_pacient.cognom1,
          var_pacient.data_naix,
          var_pacient.telefon;

        UPDATE persona
           SET mail = var_cognom_metge || '_' || var_pacient.mail
         WHERE dni = var_pacient.dni;
    END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE EXCEPTION 'El metge no existeix!';
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------------
-- EJERCICI 2.1: Trigger per actualitzar ingressos
-- ---------------------------------------------------------------------

-- 1) Creació de la taula
CREATE TABLE IF NOT EXISTS ingressos_visites (
    total NUMERIC(14,3)
);

-- 2) Inicialització: inserim una fila amb valor 0 només si la taula està buida
DO $$
BEGIN
  IF NOT EXISTS (SELECT * FROM ingressos_visites) THEN
    INSERT INTO ingressos_visites VALUES (0);
  END IF;
END;
$$;

-- 3) Funció trigger (sense COALESCE, assignem 0 si SUM retorna NULL)
CREATE OR REPLACE FUNCTION proc_act_ingressos()
RETURNS TRIGGER AS $$
DECLARE
    var_total NUMERIC(14,3);
BEGIN
    -- Sumem els preus de totes les visites
    SELECT SUM(preu) INTO var_total FROM visita;

    -- Si no hi ha visites, SUM retorna NULL: ho convertim a 0
    IF var_total IS NULL THEN
      var_total := 0;
    END IF;

    -- Actualitzem la taula d'ingressos
    UPDATE ingressos_visites
       SET total = var_total;

    RAISE NOTICE 'Els ingressos actuals per les visites són %', var_total;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4) Trigger AFTER INSERT
DROP TRIGGER IF EXISTS trig_act_ingressos ON visita;
CREATE TRIGGER trig_act_ingressos
  AFTER INSERT ON visita
  FOR EACH ROW
  EXECUTE FUNCTION proc_act_ingressos();


-- ---------------------------------------------------------------------
-- EJERCICI 2.2: Trigger de validació de data i operacions
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION func_comprovar_data()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.data_visita > CURRENT_DATE THEN
        RAISE EXCEPTION 'Data incorrecta: no pot ser posterior a avui.';
    ELSIF TG_OP = 'UPDATE' THEN
        RAISE EXCEPTION 'No es pot modificar el preu de la visita.';
    ELSIF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'No es pot eliminar la visita.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trig_visit_audit ON visita;
CREATE TRIGGER trig_visit_audit
  BEFORE INSERT OR UPDATE OR DELETE ON visita
  FOR EACH ROW
  EXECUTE FUNCTION func_comprovar_data();
