const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const app = express();

// Configura el servidor Express
app.use(express.static('public'));
app.use(bodyParser.urlencoded({ extended: true }));

// Configura la conexión a MySQL
const db = mysql.createConnection({
    host: '127.0.0.1',
    user: 'root',
    password: 'root',
    database: '5to_betgambler'
});

// Conexión a la base de datos
db.connect((err) => {
    if (err) {
        console.error('Error de conexión a la base de datos: ' + err.stack);
        return;
    }
    console.log('Conexión a la base de datos MySQL exitosa como ID ' + db.threadId);
});

app.get('/', (req, res) => {
    res.redirect('registro-login.html')
})


// Maneja el registro de usuario
app.post('/registro', (req, res) => {
    const { contra, nombre, apodo, dni, mail, edad, nacimiento } = req.body;

    // Verifica si la edad es menor de 18 años
    if (edad < 18) {
        res.status(400).send('Debes ser mayor de 18 años para registrarte.');
        return;
    }

    const query = 'CALL AltaUsuario(?, ?, ?, ?, ?, ?, ?)';

    // Llama al procedimiento almacenado AltaUsuario en la base de datos
    db.query(query, [contra, nombre, apodo, dni, mail, edad, nacimiento], (err, results) => {
        if (err) {
            console.error('Error al registrar el usuario: ' + err.stack);
            res.status(500).send('Error al registrar el usuario.');
            return;
        }
        console.log('Usuario registrado con éxito.');
        res.status(200).redirect('/index.html');
    });
});

// Maneja el inicio de sesión
app.post('/login', (req, res) => {
    const {apodo, contra } = req.body;
    const queryinicio = 'SELECT * FROM usuario WHERE apodo = ? AND contra = ?';
    // Verifica las credenciales en la base de datos
    db.query(queryinicio, [apodo, contra], (err, results) => {
        if (err) {
            console.error('Error al verificar las credenciales: ' + err.stack);
            res.status(500).send('Error al verificar las credenciales.');
            return;
        }

        if (results.length === 0) {
            console.log('El usuario ingresado no existe.');
            res.status(401).send('El usuario ingresado no existe.');
        } else {
            console.log('Inicio de sesión exitoso.');
            res.status(200).redirect('/index.html');
        }
    });
});

//Google OAuth configuracion

const passport = require('passport');
const GoogleStrategy = require('passport-google-oauth').OAuth2Strategy;

passport.use(new GoogleStrategy ({
    clientID: '480358724096-saa7ritb823f5rmas2df6b9t9j6nc8ig.apps.googleusercontent.com',
    clientSecret: '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',
    callbackURL: 'https://BetGamblerOficial.com/auth/google/callback'
},
    (accessToken, refreshToken, profile, done) => {

    }));

    app.use(passport.initialize());

    app.get('/auth/google',
        passport.authenticate('google', { scope: ['https://www.googleapis.com/auth/plus.login']})
    );

    app.get('/auth/google/callback', 
        passport.authenticate('google', {failureRedirect: '/login'}),
        (req, res) => {
            res.redirect('/index.html');
        }
    );


// Métodos de pago

// Configuración para procesar datos del formulario.
app.use(bodyParser.urlencoded({ extended: false}));

// Ruta para manejar la confirmación del pago.
app.post('/paypal-confirmacion-pago', (req, res) => {
    const headers = req.headers;
    const body = req.body;

    // Validaciones.
    const isAuthentic = verifyPaypalWebhook(headers, JSON.stringify(body));

    if (isAuthentic) {

        res.sendStatus(200);
    } else {
        res.sendStatus(400);
    }
});


//Validaciones de Notificación

const crypto = require('crypto');
const YOUR_PAYPAL_WEBHOOK_SECREET = '';

function verifyPaypalWebhook(headers, body){
    const expectedSignature = headers['paypal-transmission-sig'];
    const transmissionId = headers['paypal-transmission-id'];
    const transmissionTime = headers['paypal-transmission-time'];

    const webhookSecret = YOUR_PAYPAL_WEBHOOK_SECREET;

    const payload = '${transmissionId}|${transmissionTime}|${body}';
    
    const calculatedSignature = crypto
    .createHmac('SHA256', webhookSecret)
    .update(payload)
    .digest('hex');

    return expectedSignature === calculatedSignature;

}

// Iniciar el servidor
const port = 3000;
app.listen(port, () => {
    console.log(`Servidor en ejecución en http://localhost:${port}`);
});


