Daniela Garcia Lopez
Jose Guadalupe Venegas Sipres

Nota: Para correr el programa debes tener el JDK 23 como minimo para que funcione correctamente. 
Nota:Se debe tener en la librerias externas del proyecto el conector a mysql, en este proyecto se usó mysql-connector-java-5.1.48-bin, por lo que se deberá descargar y agregarlo a las librerias externas.

1. Descargar el proyecto.
2. Una vez descargado el proyecto, entramos a mysql y creamos la Base de Datos que se llamará "videogame_collection" (CREATE DATABASE "videogame_collection";).
3. Si todo salió bien, se debería poder ver la base con un "SHOW DATABASES;" y con "USE videogame_collection;" para usar la base de datos.
4. Ya que esté creada, copiamos y pegamos el codigo que está en "videogame_collection.sql" y lo corremos.
5. De ahí, copiamos y pegamos las instrucciones de "insert_videogame_collection" para insertar los datos en nuestras tablas.
6. Ya creada se debería tener los registros, para confirmar le daremos un SELECT en cualquier tabla (ej. SELECT * FROM users;).
7. Unas vez visto la tabla, pueden crear un nuevo usuario (ej. INSERT INTO users(username, password, email, access_type) VALUES('adminPrueba',SHA2('admin123',256),'adminPrueba@gmail.com','admin');) para poder entrar al programa.
8. Cambiar el usuario y contraseña de mysql en el programa
9. El programa está diseñado para restaurar la bitacora desde el último CHECKPOINT (cada vez que se inicia el programa, se agrega un CHECKPOINT) por lo que la restauracion de la base empezará desde el último CHECKPOINT para adelante
cualquier registro anterior al último CHECKPOINT, se perderá, pero quedará registrado en log

Declaración sobre el uso de Asistentes Digitales
Durante el desarrollo de este proyecto se utilizaron asistentes digitales ChatGPT y Gemini, para la resolución de problemas técnicos (sobre todo en el ambito de la restaurazión de la base) y optimización de soluciones. 
Todas las decisiones finales de implementación fueron revisadas y validadas por los desarrolladores responsables del proyecto.
