DELIMITER $$

DROP PROCEDURE IF EXISTS AltaUsuario $$
CREATE PROCEDURE AltaUsuario(unaContra CHAR(20), unNombre VARCHAR(20), unApodo VARCHAR(30), unDNI INT, unMail VARCHAR(30), unaEdad SMALLINT UNSIGNED, unNacimiento DATE)
BEGIN
    INSERT INTO Usuario (contra, nombre, apodo, dni, mail, saldo, fecha_registro, edad, nacimiento)
    VALUES (unaContra, unNombre, unApodo, unDNI, unMail, 2500, NOW(), unaEdad, unNacimiento) ;
END $$



DELIMITER $$

DROP PROCEDURE IF EXISTS AltaPartidoCopa $$
CREATE PROCEDURE AltaPartidoCopa(unId TINYINT, unaCopa TINYINT, ELocal TINYINT, EVisitante TINYINT, fecha TINYINT, estadio TINYINT)
BEGIN
    INSERT INTO Partido(equipo_local, equipo_visitante, idFecha, idEstadio)
    VALUES (ELocal, EVisitante, fecha, estadio);
	IF	(EXISTS	(SELECT *
				 FROM Partido
				 WHERE idFecha = fecha)) THEN
    			 INSERT INTO partido_copa(idPartido, idCopa)
    			 VALUES (idPartido, unaCopa);
	END IF;
END $$


DELIMITER $$

DROP PROCEDURE IF EXISTS AltaPartidoLiga $$
CREATE PROCEDURE AltaPartidoLiga(unId TINYINT, unaLiga TINYINT, ELocal TINYINT, EVisitante TINYINT, fecha TINYINT, estadio TINYINT)
BEGIN
    INSERT INTO Partido(equipo_local, equipo_visitante, idFecha, idEstadio)
    VALUES (ELocal, EVisitante, fecha, estadio);
	IF	(EXISTS	(SELECT *
				 FROM Partido
				 WHERE idFecha = fecha)) THEN
    			 INSERT INTO Partido_Liga(idPartido, idLiga)
    			 VALUES (idPartido, unaLiga);
	END IF;
END $$


DELIMITER $$

DROP PROCEDURE IF EXISTS CancelarApuesta $$

CREATE PROCEDURE CancelarApuesta (unApuesta INT, motivo VARCHAR(100))
BEGIN
    UPDATE Apuesta
    SET cancelada = TRUE,
    fin = NOW()
    WHERE idApuesta = unApuesta;
END $$


DELIMITER $$

DROP PROCEDURE IF EXISTS GolRealizado$$

CREATE PROCEDURE GolRealizado (unEquipo TINYINT, unPartido TINYINT, unMinuto SMALLINT)
BEGIN
    IF (EXISTS (SELECT *
                FROM partido
                WHERE idPartido = unPartido)) THEN
               
                INSERT INTO Gol (idEquipo, idPartido, minuto)
                VALUES (unEquipo, unPartido, unMinuto) ;
    END IF;
END $$


DELIMITER $$

DROP PROCEDURE IF EXISTS MovimientoUsuario $$

CREATE PROCEDURE MovimientoUsuario (unUsuario TINYINT, unApuesta INT, unTipo SMALLINT )
BEGIN
    INSERT INTO historial_usuario(idUsuario, idApuesta, tipoApuesta)
    VALUES (unUsuario, unApuesta, unTipo);
END $$


DELIMITER $$

DROP PROCEDURE IF EXISTS FinalizarPartido $$

CREATE PROCEDURE FinalizarPartido (unPartido TINYINT, unResultado INT)
BEGIN
    INSERT INTO resultado_partido(idPartido, resultado)
    VALUES (unPartido, unResultado);
END $$



DELIMITER $$

DROP PROCEDURE IF EXISTS PosponerPartido $$

CREATE PROCEDURE PosponerPartido (unPartido TINYINT, diaNuevo DATE)
BEGIN
	IF(EXISTS (SELECT *
				FROM Partido
				WHERE idPartido = unPartido)) THEN 
				UPDATE Fecha_Partido 
				SET dia = diaNuevo
				WHERE idPartido = unPartido;
	END IF;
END $$


DELIMITER $$

DROP PROCEDURE IF EXISTS AltaApuestaGol $$

CREATE PROCEDURE AltaApuestaGol	(unUsuario TINYINT, unPartido TINYINT, unaCantidad TINYINT, unMonto DOUBLE)
BEGIN
	INSERT INTO Apuesta (tipoApuesta, idUsuario, idEstado, idPartido, cantidadGol, inicio, monto, cancelada)
	VALUES	(1, unUsuario, 1, unPartido, unaCantidad, NOW(), unMonto, FALSE);
	IF(EXISTS (SELECT *
				FROM Apuesta
				WHERE idUsuario = unUsuario AND idApuesta = idApuesta)) THEN
				CALL MovimientoUsuario(unUsuario, idApuesta, tipoApuesta);
	END IF;
END $$