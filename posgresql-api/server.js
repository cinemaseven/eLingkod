import express from 'express';
import bodyParser from 'body-parser';
import mysql from 'mysql2/promise';
import bcrypt from 'bcryptjs';
import multer from 'multer';
import cors from 'cors';
import path from 'path';

const app = express();
const port = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(express.static('uploads'));

// Database connection pool
const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',          // change if needed
    password: '',          // change if needed
    database: 'elingkod',  // your DB
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Multer storage (for images)
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}-${file.originalname}`);
    }
});
const upload = multer({ storage: storage });

/* ===========================
   SIGNUP ROUTE
=========================== */
app.post('/signup', async (req, res) => {
    const { emailOrContact, password } = req.body;
    if (!emailOrContact || !password) {
        return res.status(400).send({ message: 'Email/Contact and password are required.' });
    }

    let connection;
    try {
        connection = await pool.getConnection();
        await connection.beginTransaction();

        // Check if user exists already
        const [rows] = await connection.execute(
            'SELECT * FROM User_Details WHERE email = ? OR contact_num = ?',
            [emailOrContact, emailOrContact]
        );

        if (rows.length > 0) {
            await connection.rollback();
            connection.release();
            return res.status(409).send({ message: 'User already exists' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        // Insert new user
        await connection.execute(
            'INSERT INTO User_Details (username, email, contact_num, password) VALUES (?, ?, ?, ?)',
            [
                emailOrContact,                                 // use as username
                emailOrContact.includes('@') ? emailOrContact : null, // email if provided
                !emailOrContact.includes('@') ? emailOrContact : null, // contact_num if provided
                hashedPassword
            ]
        );

        await connection.commit();
        connection.release();
        res.status(201).send({ message: 'User registered successfully' });
    } catch (error) {
        if (connection) {
            await connection.rollback();
            connection.release();
        }
        console.error('Error during signup transaction:', error);
        res.status(500).send({ message: 'Server error' });
    }
});

/* ===========================
   LOGIN ROUTE
=========================== */
app.post('/login', async (req, res) => {
    const { emailOrContact, password } = req.body;
    if (!emailOrContact || !password) {
        return res.status(400).send({ message: 'Email/Contact and password are required.' });
    }

    try {
        const [results] = await pool.execute(
            'SELECT * FROM User_Details WHERE email = ? OR contact_num = ?',
            [emailOrContact, emailOrContact]
        );

        if (results.length === 0) {
            return res.status(401).send({ message: 'User not found' });
        }

        const user = results[0];
        const isMatch = await bcrypt.compare(password, user.password);

        if (!isMatch) {
            return res.status(401).send({ message: 'Invalid credentials' });
        }

        res.status(200).send({
            message: 'Login successful',
            user: {
                id: user.id,
                username: user.username,
                email: user.email,
                contact_num: user.contact_num
            }
        });
    } catch (error) {
        console.error('Error during login:', error);
        res.status(500).send({ message: 'Server error' });
    }
});

/* ===========================
   COMPLETE PROFILE ROUTE
=========================== */
app.post('/complete-profile', upload.fields([{ name: 'frontImage' }, { name: 'backImage' }]), async (req, res) => {
    const {
        email,
        lastName,
        firstName,
        midName,
        gender,
        birthDate,
        birthPlace,
        citizenship,
        houseNum,
        street,
        city,
        province,
        zipCode,
        contactNumber,
        civilStatus,
        voterStatus,
        isPwd,
        pwdIdNum
    } = req.body;

    const frontImagePath = req.files && req.files['frontImage'] ? req.files['frontImage'][0].path : null;
    const backImagePath = req.files && req.files['backImage'] ? req.files['backImage'][0].path : null;

    if (!email && !contactNumber) {
        return res.status(400).send({ message: 'User identifier (email or contact number) is required.' });
    }

    try {
        const query = `
            UPDATE User_Details SET
            last_name = ?,
            first_name = ?,
            mid_name = ?,
            gender = ?,
            birthdate = ?,
            birthplace = ?,
            citizenship = ?,
            house_num = ?,
            street = ?,
            city = ?,
            province = ?,
            zip_code = ?,
            contact_num = ?,
            civil_status = ?,
            voter_status = ?,
            is_pwd = ?,
            pwd_id_num = ?,
            front_id_image = ?,
            back_id_image = ?
            WHERE email = ? OR contact_num = ?
        `;

        const values = [
            lastName,
            firstName,
            midName,
            gender,
            birthDate,
            birthPlace,
            citizenship,
            houseNum,
            street,
            city,
            province,
            zipCode,
            contactNumber,
            civilStatus,
            voterStatus,
            isPwd,
            pwdIdNum,
            frontImagePath,
            backImagePath,
            email,
            contactNumber
        ];

        const [result] = await pool.execute(query, values);

        if (result.affectedRows === 0) {
            return res.status(404).send({ message: 'User not found.' });
        }
        res.status(201).send({ message: 'Profile created successfully!' });

    } catch (error) {
        console.error('Error updating profile:', error);
        res.status(500).send({ message: 'Error saving profile information.' });
    }
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
