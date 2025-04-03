const express = require('express');
const pool = require('../db'); 
const router = express.Router();

router.get('/', async (req, res) => {
    const { user_id } = req.query;
    if (!user_id) {
      return res.status(400).json({ error: 'User ID is required' });
    }
  
    try {
      const result = await pool.query(
        `
        SELECT  
          n.title, 
          n.user_id,
          n.message, 
          d.phone_number,
          n.created_at AS createdAt, 
          c.car_id
        FROM notifications n
        LEFT JOIN accepted_bets ab ON n.user_id = ab.id
        LEFT JOIN cars c ON c.car_id = ab.car_id
        LEFT JOIN dealers d ON c.dealer_id = d.dealer_id
        WHERE n.user_id = $1
        ORDER BY n.created_at DESC
        `,
        [user_id]
      );
  
      res.status(200).json(result.rows);
    } catch (error) {
      console.error('Error fetching notifications:', error);
      res.status(500).json({ error: 'Failed to fetch notifications' });
    }
  });
  

module.exports = router;