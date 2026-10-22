const express = require('express');
const router = express.Router();
const dbService = require('../services/dbService');
const { authenticateToken } = require('../middleware/auth');

// Lấy danh sách yêu cầu hỗ trợ
router.get('/', authenticateToken, (req, res) => {
  const tickets = dbService.getCollection('tickets');

  if (req.user.role === 'admin' || req.user.role === 'staff') {
    return res.status(200).json({ data: tickets, total: tickets.length });
  }

  // Khách hàng xem ticket của mình
  const myTickets = tickets.filter(t => t.customerId === req.user.id);
  res.status(200).json({ data: myTickets, total: myTickets.length });
});

// Tạo yêu cầu hỗ trợ mới (Khách hàng / Phụ huynh)
router.post('/', authenticateToken, (req, res) => {
  const { title, description } = req.body;

  if (!title || !description) {
    return res.status(400).json({
      error: { code: 'INVALID_INPUT', message: 'Vui lòng cung cấp tiêu đề và mô tả vấn đề' }
    });
  }

  const db = dbService.read();
  const newTicket = {
    id: 't_' + Date.now(),
    customerId: req.user.id,
    customerName: req.user.fullName || req.user.username,
    title,
    description,
    status: 'pending', // pending, inProgress, resolved
    staffNotes: '',
    createdAt: new Date().toISOString()
  };

  db.tickets.push(newTicket);
  dbService.write(db);

  res.status(201).json({ message: 'Gửi yêu cầu hỗ trợ thành công', data: newTicket });
});

// Cập nhật trạng thái ticket (Nhân viên / Admin)
router.put('/:id', authenticateToken, (req, res) => {
  const { id } = req.params;
  const { status, staffNotes } = req.body;

  const db = dbService.read();
  const ticket = db.tickets.find(t => t.id === id);

  if (!ticket) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Không tìm thấy yêu cầu hỗ trợ' }
    });
  }

  if (status) ticket.status = status;
  if (staffNotes !== undefined) ticket.staffNotes = staffNotes;

  dbService.write(db);
  res.status(200).json({ message: 'Cập nhật tiến độ hỗ trợ thành công', data: ticket });
});

// Xóa ticket
router.delete('/:id', authenticateToken, (req, res) => {
  const { id } = req.params;

  const db = dbService.read();
  const initialLength = db.tickets.length;
  db.tickets = db.tickets.filter(t => t.id !== id);

  if (db.tickets.length === initialLength) {
    return res.status(404).json({
      error: { code: 'NOT_FOUND', message: 'Không tìm thấy yêu cầu hỗ trợ' }
    });
  }

  dbService.write(db);
  res.status(200).json({ message: 'Đã xóa yêu cầu hỗ trợ' });
});

module.exports = router;
