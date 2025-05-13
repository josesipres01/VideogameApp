package org.example;
import java.sql.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Scanner;

/**
 * Sistema de Administración de Colección de Videojuegos
 * Basado en la lógica de PruebaAccesoMySQL, adaptado para:
 * - Base de datos: videogame_collection
 * - Tablas: users, platform, games, game_collection, log
 * - Consola de texto para CRUD y reportes
 */
public class Main {
    private static final String DB_IP = "localhost";
    private static final String DB_NAME = "videogame_collection";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "Sonora2003";

    private static Connection conexion = null;
    private static int userID;
    private static boolean isAdmin = false;
    private static Scanner scanner = new Scanner(System.in);

    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            //System.out.println("Driver JDBC cargado correctamente.");
           // System.out.println("ClassLoader del driver en main(): " + Class.forName("com.mysql.jdbc.Driver").getClassLoader());

            // 1) Conectar a la base de datos
            conectarABaseD(DB_IP);

            // 2) Login de usuario
            login();

            // 3) Si la conexión fue exitosa, arrancar menú principal
            if (conexion != null) {
                try (Statement st = conexion.createStatement()) {
                    insertCheckpointLog(conexion);
                    st.execute("SET @logged_user_id = " + userID);
                } catch (SQLException e) {
                    System.out.println("No se pudo obtener user ID" + e.getMessage());
                }
                showMainMenu();
            }

            // 4) Cerrar conexión al salir
            if (conexion != null) conexion.close();

        } catch (SQLException e) {
            System.err.println("Error al cerrar la conexión: " + e.getMessage());
        } catch (ClassNotFoundException e) {
            System.err.println("No se encontró el driver JDBC: " + e.getMessage());
            System.exit(1);
        }
    }

    /**
     * Establece la conexión JDBC con MySQL.
     */
    private static void conectarABaseD(String ip) {
        String url = String.format(
                "jdbc:mysql://%s/%s?useSSL=false&serverTimezone=UTC",
                ip, DB_NAME);
        try {
            conexion = DriverManager.getConnection(url, DB_USER, DB_PASSWORD);
            System.out.println("Conectado a la base de datos: " + DB_NAME);
        } catch (SQLException ex) {
            System.err.println("No se pudo conectar a la base de datos: " + ex.getMessage());
        }
    }

    public static void insertCheckpointLog(Connection conexion) {
        String sql = "INSERT INTO log (timestamp, action_type, table_name, record_id, sql_instruction, user_id) VALUES (?, ?, ?, ?, ?, ?)";


        try {
            String url = String.format("jdbc:mysql://%s/%s?useSSL=false&serverTimezone=UTC", DB_IP, DB_NAME);
            try (Connection conn = DriverManager.getConnection(url, DB_USER, DB_PASSWORD);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setTimestamp(1, new Timestamp(new Date().getTime()));
                pstmt.setString(2, "CHECKP");
                pstmt.setString(3, null);
                pstmt.setInt(4, 0);
                pstmt.setString(5, "Programa iniciado");
                pstmt.setInt(6, userID);


                pstmt.executeUpdate();
                //System.out.println("Registro 'CHECKP' insertado en la tabla log.");
            }
        } catch (SQLException e) {
            System.err.println("Error al insertar el registro 'CHECKP': " + e.getMessage());
        }
    }

    /**
     * Solicita credenciales y valida en tabla users.
     */
    private static void login() {
        System.out.println("--- LOGIN ---");
        int attempts = 3;
        String sql = "SELECT user_id, access_type FROM users "
                + "WHERE username = ? AND password = SHA2(?,256)";
        while (attempts > 0) {
            System.out.print("Usuario: ");
            String username = scanner.nextLine().trim();
            System.out.print("Contraseña: ");
            String password = scanner.nextLine().trim();

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, password);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    userID = rs.getInt("user_id");
                    String role = rs.getString("access_type");
                    isAdmin = role.equalsIgnoreCase("admin");
                    System.out.println("** ACCESO CONCEDIDO **\n");
                    return;
                } else {
                    attempts--;
                    System.out.println("** ACCESO DENEGADO **. Intentos restantes: "
                            + attempts + "\n");
                }
            } catch (SQLException e) {
                System.err.println("Error en login: " + e.getMessage());
                return;
            }
        }
        System.out.println("Número de intentos agotado. Saliendo...");
        System.exit(0);
    }


    /**
     * Muestra el menú principal y redirige a acciones.
     */
    private static void showMainMenu() throws SQLException {
        int option;
        do {
            System.out.println("--- MENÚ PRINCIPAL ---");
            if (isAdmin) {
                System.out.println("1. Gestionar Usuarios");
            }
            System.out.println("2. Gestionar Plataformas");
            System.out.println("3. Gestionar Videojuegos");
            System.out.println("4. Gestionar Colección");
            System.out.println("5. Consultas y Reportes");
            if (isAdmin) {
                System.out.println("6. Restaurar Base de Datos");
            }
            System.out.println("0. Salir");
            System.out.print("Elija una opción: ");
            option = Integer.parseInt(scanner.nextLine());

            switch (option) {
                case 1:
                    if (isAdmin) {
                        gestionarUsuarios();
                    } else {
                        System.out.println("Acceso denegado. Solo para administradores.");
                    }
                    break;
                case 2:
                    gestionarPlataformas();
                    break;
                case 3:
                    gestionarGames();
                    break;
                case 4:
                    gestionarCollection();
                    break;
                case 5:
                    gestionarConsultas();
                    break;
                case 6:
                    if (isAdmin) {
                        gestionarRestauracion();
                    } else {
                        System.out.println("Acceso denegado. Solo para administradores.");
                    }
                    break;
                case 0:
                    System.out.println("Saliendo...");
                    break;
                default:
                    System.out.println("Opción inválida.");
            }

        } while (option != 0);
    }


    private static void gestionarUsuarios() throws SQLException {
        System.out.println("--- Gestión de Usuarios ---");
        System.out.println("1. Insertar Usuario");
        System.out.println("2. Modificar Usuario");
        System.out.println("3. Eliminar Usuario");
        System.out.println("4. Regresar");
        System.out.print("Seleccione una opción: ");
        int subOption = Integer.parseInt(scanner.nextLine());

        switch (subOption) {
            case 1:
                agregarUsuario();
                break;
            case 2:
                modificarUsuario();
                break;
            case 3:
                eliminarUsuario();
                break;
            case 4:
                showMainMenu();
            default:
                System.out.println("Opción no válida en gestión de usuarios.");
        }
    }

    private static void gestionarPlataformas() throws SQLException {
        System.out.println("--- Gestionar Plataformas ---");
        System.out.println("1. Insertar Plataforma");
        System.out.println("2. Modificar Plataforma");
        System.out.println("3. Eliminar Plataforma");
        System.out.println("4. Regresar");
        System.out.print("Seleccione una opcion: ");
        int subOption = Integer.parseInt(scanner.nextLine());
        switch (subOption) {
            case 1:
                agregarPlatform();
                break;
            case 2:
                modificarPlatform();
                break;
            case 3:
                eliminarPlatform();
                break;
            case 4:
                showMainMenu();
            default:
                System.out.println("Opción no valida");

        }
    }

    public static void gestionarGames() throws SQLException {
        System.out.println("--- Gestionar Videojuegos ---");
        System.out.println("1. Insertar Videojuego");
        System.out.println("2. Modificar Videojuego");
        System.out.println("3. Eliminar Videojuego");
        System.out.println("4. Regresar");
        System.out.print("Seleccione una opcion: ");

        int subOption = Integer.parseInt(scanner.nextLine());
        switch (subOption) {
            case 1:
                insertGame();
                break;
            case 2:
                modificarGame();
                break;
            case 3:
                eliminarGame();
                break;
            case 4:
                showMainMenu();
            default:
                System.out.println("Opción no valida");
        }
    }

    public static void gestionarCollection() throws SQLException {
        System.out.println("--- Gestionar Collections---");
        System.out.println("1. Insertar Collection");
        System.out.println("2. Modificar Collection");
        System.out.println("3. Eliminar Collection");
        System.out.println("4. Regresar");
        System.out.print("Seleccione una opcion: ");
        int subOption = Integer.parseInt(scanner.nextLine());
        switch (subOption) {
            case 1:
                insertCollection();
                break;
            case 2:
                modificarCollection();
                break;
            case 3:
                eliminarCollection();
                break;
            case 4:
                showMainMenu();
            default:
                System.out.println("Opción no valida");
        }
    }

    public static void gestionarConsultas() throws SQLException {
        System.out.println("--- Ver Consultas y Reportes ---");
        System.out.println("1. Listar Collection");
        System.out.println("2. Listar Videojuego con mayores colecciones");
        System.out.println("3. Top 5 mejores videojuegos");
        System.out.println("4. Regresar");
        System.out.print("Seleccione una opción: ");
        int subOption = Integer.parseInt(scanner.nextLine());
        switch (subOption) {
            case 1:
                listarCollectionUsuario();
                break;
            case 2:
                listarVideojuegosCollection();
                break;
            case 3:
                top5Games();
                break;
            case 4:
                showMainMenu();
            default:
                System.out.println("Opción no valida");
        }


    }

    private static void gestionarRestauracion() throws SQLException {
        int option;
        // Ya no creamos una nueva conexión aquí
        // Usamos la conexión existente 'conexion'
        if (conexion == null) {
            System.err.println("No hay conexión a la base de datos.");
            return;
        }

        System.out.println("Conexión exitosa a la base de datos.");

        do {
            System.out.println("--- MENÚ DE RESTAURACIÓN ---");
            System.out.println("1. Eliminar registros de las tablas");
            System.out.println("2. Restaurar base de datos desde el último checkpoint");
            System.out.println("3. Regresar al Menú Principal");
            System.out.print("Elija una opción: ");
            option = Integer.parseInt(scanner.nextLine());

            switch (option) {
                case 1:
                    eliminarRegistros(conexion);
                    break;
                case 2:
                    restaurarDesdeCheckpoint(conexion);
                    break;
                case 3:
                    showMainMenu();
                    break;
                default:
                    System.out.println("Opción inválida.");
            }

        } while (option != 0);


    }

    private static void agregarUsuario() {
        System.out.println("--- Agregar Usuario ---");
        System.out.print("Username: ");
        String username = scanner.nextLine().trim();
        System.out.print("Password: ");
        String password = scanner.nextLine().trim();
        System.out.print("Email: ");
        String email = scanner.nextLine().trim();
        System.out.print("ID de Plataforma preferida: ");
        int platformId = Integer.parseInt(scanner.nextLine().trim());
        System.out.print("Tipo de acceso (user/admin): ");
        String accessType = scanner.nextLine().trim().toLowerCase();

        String sql = "INSERT INTO users(username, password, email, preferred_platform_id, access_type) VALUES(?, SHA2(?,256), ?, ?, ?)";
        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, password);
                ps.setString(3, email);
                ps.setInt(4, platformId);
                ps.setString(5, accessType);
                ps.executeUpdate();
            }

            conexion.commit();
            System.out.println("Usuario agregado correctamente.");

        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) { /* Ignorado */ }
            System.err.println("Error al agregar usuario: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) { /* Ignorado */ }
        }
    }


    private static void modificarUsuario() {
        System.out.println("--- Modificar Usuario ---");
        System.out.print("Ingrese el ID del usuario a modificar: ");
        int id = Integer.parseInt(scanner.nextLine().trim());

        System.out.print("Nuevo nombre de usuario: ");
        String username = scanner.nextLine().trim();
        System.out.print("Nueva contraseña: ");
        String password = scanner.nextLine().trim();
        System.out.print("Nuevo correo electrónico: ");
        String email = scanner.nextLine().trim();
        System.out.print("ID de nueva plataforma preferida: ");
        int platformId = Integer.parseInt(scanner.nextLine().trim());
        System.out.print("Tipo de acceso (user/admin): ");
        String accessType = scanner.nextLine().trim().toLowerCase();

        String sql = "UPDATE users SET username = ?, password = SHA2(?,256), email = ?, preferred_platform_id = ?, access_type = ? WHERE user_id = ? ";

        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, password);
                ps.setString(3, email);
                ps.setInt(4, platformId);
                ps.setString(5, accessType);
                ps.setInt(6, id);
                int rows = ps.executeUpdate();

                if (rows == 1) {
                    conexion.commit();
                    System.out.println("Usuario modificado correctamente.");
                } else {
                    conexion.rollback();
                    System.out.println("No se encontró un usuario activo con ese ID. Cambios cancelados.");
                }
            }

        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) { /* ignora */ }
            System.err.println("Error al modificar usuario: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) { /* ignora */ }
        }
    }

    private static void eliminarUsuario() {
        System.out.println("--- Eliminar Usuario ---");
        System.out.print("Ingrese el ID del usuario a eliminar: ");
        int id = Integer.parseInt(scanner.nextLine().trim());

        System.out.print("¿Seguro que desea eliminar el usuario? (S/N): ");
        String response = scanner.nextLine().trim();

        if (!response.equalsIgnoreCase("S")) {
            System.out.println("Operación cancelada.");
            return;
        }

        String sql = "UPDATE users SET active = 0 WHERE user_id = ?  AND active = 1";

        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setInt(1, id);
                int rows = ps.executeUpdate();

                if (rows == 1) {
                    conexion.commit();
                    System.out.println("Usuario eliminado exitosamente.");
                } else {
                    conexion.rollback();
                    System.out.println("No se encontró un usuario con ese ID.");
                }
            }

        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) { /* ignora */ }
            System.err.println("Error al eliminar usuario: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) { /* ignora */ }
        }
    }

    private static void agregarPlatform() {
        System.out.println("--- Insertar Nueva Plataforma ---");
        System.out.print("Nombre de la plataforma: ");
        String nombre = scanner.nextLine().trim();

        String sql = "INSERT INTO platform(platform_name, date_added, active) VALUES (?, NOW(), 1)";

        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setString(1, nombre);
                ps.executeUpdate();
            }

            conexion.commit();
            System.out.println("Plataforma agregada correctamente.");

        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) { /* ignora */ }
            System.err.println("Error al insertar plataforma: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) { /* ignora */ }
        }
    }

    private static void modificarPlatform() {
        System.out.println("--- Modificar Plataforma ---");
        System.out.print("ID de la plataforma a modificar: ");
        int id = Integer.parseInt(scanner.nextLine().trim());

        System.out.print("Nuevo nombre de plataforma: ");
        String nuevoNombre = scanner.nextLine().trim();

        String sql = "UPDATE platform SET platform_name = ? WHERE platform_id = ?";

        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setString(1, nuevoNombre);
                ps.setInt(2, id);
                int rows = ps.executeUpdate();

                if (rows == 1) {
                    conexion.commit();
                    System.out.println("Plataforma modificada correctamente.");
                } else {
                    conexion.rollback();
                    System.out.println("No se encontró la plataforma con ese ID.");
                }
            }

        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) { /* ignora */ }
            System.err.println("Error al modificar plataforma: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) { /* ignora */ }
        }
    }

    private static void eliminarPlatform() {
        System.out.println("--- Eliminar Plataforma ---");
        System.out.print("ID de la plataforma a eliminar: ");
        int id = Integer.parseInt(scanner.nextLine().trim());

        System.out.print("¿Está seguro? (S/N): ");
        String confirm = scanner.nextLine().trim();

        if (!confirm.equalsIgnoreCase("S")) {
            System.out.println("Operación cancelada.");
            return;
        }

        String sql = "UPDATE platform SET active = 0 WHERE platform_id = ? AND active = 1";

        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setInt(1, id);
                int rows = ps.executeUpdate();

                if (rows == 1) {
                    conexion.commit();
                    System.out.println("Plataforma eliminada correctamente.");
                } else {
                    conexion.rollback();
                    System.out.println("No se encontró una plataforma con ese ID.");
                }
            }

        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) {}
            System.err.println("Error al eliminar plataforma: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) { /* ignora */ }
        }
    }

    private static void insertGame() {
        System.out.println("--- Insertar Nuevo Videojuego ---");
        System.out.print("Nombre del juego: ");
        String nombre = scanner.nextLine().trim();
        System.out.print("Año de lanzamiento: ");
        int anio = Integer.parseInt(scanner.nextLine().trim());
        System.out.print("ID de la plataforma: ");
        int plataformaId = Integer.parseInt(scanner.nextLine().trim());
        System.out.print("URL de la imagen: ");
        String imagen = scanner.nextLine().trim();

        String sql = "INSERT INTO games(game_name, platform_id, year_released, image_url, date_added, active) "
                + "VALUES (?, ?, ?, ?, NOW(), 1)";

        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setString(1, nombre);
                ps.setInt(2, plataformaId);
                ps.setInt(3, anio);
                ps.setString(4, imagen);
                ps.executeUpdate();
            }

            conexion.commit();
            System.out.println("Videojuego agregado correctamente.");

        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) {}
            System.err.println("Error al insertar videojuego: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) {}
        }


    }


    private static void modificarGame() {
        System.out.println("--- Modificar Videojuego ---");
        System.out.print("ID del juego a modificar: ");
        int id = Integer.parseInt(scanner.nextLine().trim());

        System.out.print("Nuevo nombre del juego: ");
        String nombre = scanner.nextLine().trim();
        System.out.print("Nuevo año de lanzamiento: ");
        int anio = Integer.parseInt(scanner.nextLine().trim());
        System.out.print("Nuevo ID de plataforma: ");
        int plataformaId = Integer.parseInt(scanner.nextLine().trim());
        System.out.print("Nueva URL de imagen: ");
        String imagen = scanner.nextLine().trim();

        String sql = "UPDATE games SET game_name = ?, platform_id = ?, year_released = ?, image_url = ? "
                + "WHERE game_id = ? AND active = 1";

        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setString(1, nombre);
                ps.setInt(2, plataformaId);
                ps.setInt(3, anio);
                ps.setString(4, imagen);
                ps.setInt(5, id);
                int rows = ps.executeUpdate();

                if (rows == 1) {
                    conexion.commit();
                    System.out.println("Videojuego modificado correctamente.");
                } else {
                    conexion.rollback();
                    System.out.println("No se encontró un videojuego con ese ID.");
                }
            }

        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) {}
            System.err.println("Error al modificar videojuego: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) {}
        }
    }

    private static void eliminarGame() {
        System.out.println("--- Eliminar Videojuego ---");
        System.out.print("ID del juego a eliminar: ");
        int id = Integer.parseInt(scanner.nextLine().trim());

        System.out.print("¿Está seguro que desea eliminarlo? (S/N): ");
        String confirm = scanner.nextLine().trim();

        if (!confirm.equalsIgnoreCase("S")) {
            System.out.println("Operación cancelada.");
            return;
        }

        String sql = "UPDATE games SET active = 0 WHERE game_id = ? AND active = 1";

        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setInt(1, id);
                int rows = ps.executeUpdate();

                if (rows == 1) {
                    conexion.commit();
                    System.out.println("Videojuego eliminado correctamente.");
                } else {
                    conexion.rollback();
                    System.out.println("No se encontró un videojuego con ese ID.");
                }
            }

        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) {}
            System.err.println("Error al eliminar videojuego: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) {}
        }
    }

    private static void insertCollection() {
        System.out.println("--- Agregar juego a la colección ---");
        System.out.print("ID del usuario: ");
        int userId = Integer.parseInt(scanner.nextLine().trim());
        System.out.print("ID del videojuego: ");
        int gameId = Integer.parseInt(scanner.nextLine().trim());
        System.out.print("Calificación (1-10): ");
        int rating = Integer.parseInt(scanner.nextLine().trim());

        String sql = "INSERT INTO game_collection(user_id, game_id, rating, date_added, active) VALUES (?, ?, ?, NOW(), 1)";

        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, gameId);
                ps.setInt(3, rating);
                ps.executeUpdate();
            }

            conexion.commit();
            System.out.println("Juego agregado a la colección.");
        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) {}
            System.err.println("Error al agregar juego a la colección: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) {}
        }
    }

    private static void modificarCollection() {
        System.out.println("--- Modificar juego en la colección ---");
        System.out.print("ID de la colección: ");
        int collectionId = Integer.parseInt(scanner.nextLine().trim());
        System.out.print("Nuevo ID del usuario: ");
        int user_id = Integer.parseInt(scanner.nextLine().trim());
        System.out.print("Nuevo ID del videojuego: ");
        int game_id = Integer.parseInt(scanner.nextLine().trim());
        System.out.print("Nueva calificación: ");
        int rating = Integer.parseInt(scanner.nextLine().trim());



        String sql = "UPDATE game_collection SET user_id = ? , game_id = ?, rating = ? WHERE collection_id = ? AND active = 1";

        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setInt(1, user_id);
                ps.setInt(2, game_id);
                ps.setInt(3, rating);
                ps.setInt(4, collectionId);
                ps.executeUpdate();
            }

            conexion.commit();
            System.out.println("Juego actualizado correctamente.");
        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) {}
            System.err.println("Error al modificar juego en la colección: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) {}
        }
    }

    private static void eliminarCollection() {
        System.out.println("--- Eliminar juego de la colección ---");
        System.out.print("ID de la colección: ");
        int collectionId = Integer.parseInt(scanner.nextLine().trim());
        System.out.println("Estas seguro de eliminar el juego de la colección? (S/N): ");
        String confirm = scanner.nextLine().trim();
        if (!confirm.equalsIgnoreCase("S")) {
            System.out.println("Operación cancelada.");
            return;
        }
        String sql = "UPDATE game_collection SET active = 0 WHERE collection_id = ?";

        try {
            conexion.setAutoCommit(false);

            try (PreparedStatement ps = conexion.prepareStatement(sql)) {
                ps.setInt(1, collectionId);
                ps.executeUpdate();
            }

            conexion.commit();
            System.out.println("Juego eliminado de la colección.");
        } catch (SQLException e) {
            try { conexion.rollback(); } catch (SQLException ex) {}
            System.err.println("Error al eliminar juego de la colección: " + e.getMessage());
        } finally {
            try { conexion.setAutoCommit(true); } catch (SQLException ex) {}
        }
    }

    private static void listarCollectionUsuario() {
        System.out.println("--- Listar su colección---");
        System.out.print("Ingrese el ID del usuario: ");
        int userId = Integer.parseInt(scanner.nextLine().trim());

        String sql = "SELECT g.game_id, g.game_name, g.year_released, p.platform_name, gc.rating " +
                "FROM game_collection gc " +
                "JOIN games g ON gc.game_id = g.game_id " +
                "JOIN platform p ON g.platform_id = p.platform_id " +
                "WHERE gc.user_id = ?";

        try (PreparedStatement ps = conexion.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            System.out.println("Juegos en la colección del usuario:");
            while (rs.next()) {
                System.out.printf("ID: %d | Nombre: %s | Año: %d | Plataforma: %s | Rating: %d\n",
                        rs.getInt("game_id"),
                        rs.getString("game_name"),
                        rs.getInt("year_released"),
                        rs.getString("platform_name"),
                        rs.getInt("rating"));
            }
        } catch (SQLException e) {
            System.err.println("Error al listar colección: " + e.getMessage());
        }
    }

    private static void listarVideojuegosCollection() {
        System.out.println("--- Videojuegos con más colleccionistas ---");

        String sql = "SELECT g.game_name, COUNT(DISTINCT gc.user_id) AS cantidad_usuarios "
                + "FROM game_collection gc "
                + "JOIN games g ON gc.game_id = g.game_id "
                + "WHERE gc.active = 1 "
                + "GROUP BY g.game_name "
                + "ORDER BY cantidad_usuarios DESC";





        try (PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                System.out.printf("Juego: %s | Coleccionistas: %d\n",
                        rs.getString("game_name"),
                        rs.getInt("cantidad_usuarios"));
            }

        } catch (SQLException e) {
            System.err.println("Error al listar juegos populares: " + e.getMessage());
        }
    }

    private static void top5Games() {
        System.out.println("--- Top 5 juegos ---");

        String sql = "SELECT g.game_name, ROUND(AVG(gc.rating), 2) AS promedio " +
                "FROM game_collection gc " +
                "JOIN games g ON gc.game_id = g.game_id " +
                "GROUP BY gc.game_id " +
                "ORDER BY promedio DESC " +
                "LIMIT 5";

        try (PreparedStatement ps = conexion.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            int rank = 1;
            while (rs.next()) {
                System.out.printf("%d. %s | Rating Promedio: %.2f\n",
                        rank++,
                        rs.getString("game_name"),
                        rs.getDouble("promedio"));
            }

        } catch (SQLException e) {
            System.err.println("Error al generar Top 5: " + e.getMessage());
        }
    }
    public static void limpiarTablas(Connection conn) throws SQLException {
        String[] tablas = {"game_collection", "games", "platform", "users"}; // Orden modificado
        Statement stmt = conn.createStatement();

        stmt.executeUpdate("SET FOREIGN_KEY_CHECKS = 0");

        // 2. Eliminar los registros de las tablas
        for (String tabla : tablas) {
            String sql = "DELETE FROM " + tabla;
            stmt.executeUpdate(sql);
            System.out.println("Registros eliminados de la tabla " + tabla + ".");
        }

        // 3. Habilitar nuevamente la restricción de clave externa
        stmt.executeUpdate("SET FOREIGN_KEY_CHECKS = 1");

        stmt.close();
    }
    private static void eliminarRegistros(Connection conn) {
        System.out.println("Eliminando registros de las tablas...");
        try {
            limpiarTablas(conn);
            System.out.println("Registros eliminados correctamente.");
        } catch (SQLException e) {
            System.err.println("Error al eliminar registros: " + e.getMessage());
        }
    }
    private static void restaurarDesdeCheckpoint(Connection conn) {
        String sqlCheckpoint = "SELECT log_id FROM log WHERE action_type = 'CHECKP' ORDER BY timestamp DESC LIMIT 1";
        String sqlRestaurar = "SELECT table_name, action_type, record_id, sql_instruction FROM log WHERE log_id > ? ORDER BY timestamp ASC";

        java.util.Map<String, java.util.Map<Integer, String[]>> operacionesPorTablaRegistro = new java.util.HashMap<>();

        try (PreparedStatement psCheckpoint = conn.prepareStatement(sqlCheckpoint)) {
            ResultSet rsCheckpoint = psCheckpoint.executeQuery();

            if (!rsCheckpoint.next()) {
                System.out.println("No hay checkpoint registrado en la tabla log.");
                return;
            }

            int checkpointId = rsCheckpoint.getInt("log_id");

            try (PreparedStatement psRestaurar = conn.prepareStatement(sqlRestaurar)) {
                psRestaurar.setInt(1, checkpointId);
                ResultSet rs = psRestaurar.executeQuery();

                while (rs.next()) {
                    String tabla = rs.getString("table_name");
                    String tipoAccion = rs.getString("action_type");
                    int idRegistro = rs.getInt("record_id");
                    String instruccionSql = rs.getString("sql_instruction");

                    if (instruccionSql == null || instruccionSql.isEmpty()) continue;

                    // Ignorar cualquier DELETE del log
                    if (!"DELETE".equalsIgnoreCase(tipoAccion)) {
                        operacionesPorTablaRegistro
                                .computeIfAbsent(tabla, k -> new java.util.HashMap<>())
                                .put(idRegistro, new String[]{tipoAccion, instruccionSql});
                    }
                }

                conn.setAutoCommit(false);
                Statement stmt = conn.createStatement();
                stmt.execute("SET FOREIGN_KEY_CHECKS = 0");

                for (java.util.Map<Integer, String[]> operacionesPorRegistro : operacionesPorTablaRegistro.values()) {
                    for (String[] operacion : operacionesPorRegistro.values()) {
                        try {
                            stmt.executeUpdate(operacion[1]);
                        } catch (SQLException e) {
                            System.err.println("Instrucción fallida: " + operacion[1]);
                            System.err.println("Motivo: " + e.getMessage());
                            // Continúa con la siguiente
                        }
                    }

                }

                stmt.execute("SET FOREIGN_KEY_CHECKS = 1");
                conn.commit();
                System.out.println("Restauración completada con éxito.");

                // Agregar nuevo CHECKPOINT al log
                String insertarCheckpoint = "INSERT INTO log (timestamp, user_id, action_type, table_name, record_id, sql_instruction) VALUES (NOW(), NULL, 'CHECKP', NULL, 0, 'Checkpoint después de restauración')";
                try (PreparedStatement psCheckpointNuevo = conn.prepareStatement(insertarCheckpoint)) {
                    psCheckpointNuevo.executeUpdate();
                    }

            } catch (SQLException e) {
                conn.rollback();
                System.err.println("Error al restaurar: " + e.getMessage());
            } finally {
                conn.setAutoCommit(true);
            }

        } catch (SQLException e) {
            System.err.println("Error al buscar checkpoint: " + e.getMessage());
        }
    }

}
