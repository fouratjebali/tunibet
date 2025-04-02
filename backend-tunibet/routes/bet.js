const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/last-bets', async (req, res) => {
  const { car_id } = req.query;

  if (!car_id) {
    return res.status(400).json({ error: 'car_id is required' });
  }

  try {
    const result = await pool.query(
      `
      SELECT bet_number, amount, created_at
      FROM bets
      WHERE car_id = $1
      ORDER BY created_at DESC
      LIMIT 5
      `,
      [car_id]
    );

    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching last bets:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.post('/place-bet', async (req, res) => {
    const { car_id, user_id, amount } = req.body;
  
    if (!car_id || !user_id || !amount) {
      return res.status(400).json({ error: 'car_id, user_id, and amount are required' });
    }
  
    try {
      const result = await pool.query(
        `
        INSERT INTO bets (car_id, id, amount)
        VALUES ($1, $2, $3)
        RETURNING bet_number, car_id, id, amount, created_at
        `,
        [car_id, user_id, amount]
      );
  
      res.status(201).json(result.rows[0]);
    } catch (error) {
      console.error('Error placing bet:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

  router.post('/accept-bet', async (req, res) => {
    const { car_id, bet_number, user_id, amount } = req.body;
  
    if (!car_id || !bet_number || !user_id || !amount) {
      return res.status(400).json({ error: 'car_id, bet_number, user_id, and amount are required' });
    }
  
    try {
      await pool.query(
        `
        INSERT INTO accepted_bets (bet_number, id, car_id, amount)
        VALUES ($1, $2, $3, $4)
        `,
        [bet_number, user_id, car_id, amount]
      );
      await pool.query(
        `
        UPDATE cars
        SET is_sold = TRUE
        WHERE car_id = $1
        `,
        [car_id]
      );
      res.status(200).json({ message: 'Bet accepted successfully' });
    } catch (error) {
      console.error('Error accepting bet:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

module.exports = router;