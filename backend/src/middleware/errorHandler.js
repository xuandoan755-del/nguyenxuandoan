function errorHandler(err, req, res, next) {
  console.error('Lỗi hệ thống:', err);
  res.status(err.status || 500).json({
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: err.message || 'Đã xảy ra lỗi nội bộ máy chủ',
      timestamp: new Date().toISOString()
    }
  });
}

module.exports = errorHandler;
