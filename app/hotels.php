<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>eHotel - Manage Hotels</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        .navbar-brand { font-weight: 700; letter-spacing: 1px; }
        .table th { background-color: #0d6efd; color: #fff; }
        .star-rating { color: #f4c430; }
    </style>
</head>
<body class="bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand" href="index.php">🏨 eHotel</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navMenu">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="index.php">Search Rooms</a></li>
                <li class="nav-item"><a class="nav-link" href="checkin.php">Check-in</a></li>
                <li class="nav-item"><a class="nav-link" href="clients.php">Clients</a></li>
                <li class="nav-item"><a class="nav-link" href="employees.php">Employees</a></li>
                <li class="nav-item"><a class="nav-link active" href="hotels.php">Hotels</a></li>
                <li class="nav-item"><a class="nav-link" href="rooms.php">Rooms</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container my-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>🏩 Manage Hotels</h2>
        <button class="btn btn-primary" onclick="openModal()">+ Add Hotel</button>
    </div>
    <div id="alertBox"></div>

    <div class="card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-striped table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Chain</th>
                            <th>Stars</th>
                            <th>Address</th>
                            <th>Rooms</th>
                            <th>Email</th>
                            <th>Phone</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="hotelsBody">
                        <tr><td colspan="8" class="text-center py-4 text-muted">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Hotel Modal -->
<div class="modal fade" id="hotelModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="modalTitle">Add Hotel</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="hotelForm">
                <div class="modal-body">
                    <input type="hidden" id="hotel_id" name="hotel_id">
                    <div class="mb-3">
                        <label class="form-label">Hotel Chain <span class="text-danger">*</span></label>
                        <select class="form-select" id="chain_id" name="chain_id" required>
                            <option value="">-- Select chain --</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Category (Stars) <span class="text-danger">*</span></label>
                        <select class="form-select" id="category" name="category" required>
                            <option value="">-- Select --</option>
                            <option value="1">1 ★</option>
                            <option value="2">2 ★★</option>
                            <option value="3">3 ★★★</option>
                            <option value="4">4 ★★★★</option>
                            <option value="5">5 ★★★★★</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Address <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="address" name="address" placeholder="123 Main St, City" required>
                        <div class="form-text">Format: "Street Address, City"</div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Email</label>
                        <input type="email" class="form-control" id="email" name="email">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Phone</label>
                        <input type="text" class="form-control" id="phone" name="phone">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
const hotelModal = new bootstrap.Modal(document.getElementById('hotelModal'));

function stars(n) { return '★'.repeat(n) + '☆'.repeat(5 - n); }

function loadHotels() {
    $.get('api/get_hotels.php', function (res) {
        const tbody = $('#hotelsBody');
        if (!res.success) {
            tbody.html(`<tr><td colspan="8" class="text-center text-danger">${res.error}</td></tr>`);
            return;
        }
        if (res.data.length === 0) {
            tbody.html('<tr><td colspan="8" class="text-center text-muted">No hotels found.</td></tr>');
            return;
        }
        let html = '';
        res.data.forEach(h => {
            html += `
                <tr>
                    <td>${h.hotel_id}</td>
                    <td>${h.chain_name}</td>
                    <td><span class="star-rating">${stars(parseInt(h.category))}</span></td>
                    <td>${h.address}</td>
                    <td><span class="badge bg-secondary">${h.num_rooms}</span></td>
                    <td><small>${h.email || '-'}</small></td>
                    <td><small>${h.phone || '-'}</small></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary me-1 btn-edit"
                            data-id="${h.hotel_id}"
                            data-chain="${h.chain_id}"
                            data-category="${h.category}"
                            data-address="${h.address.replace(/"/g, '&quot;')}"
                            data-email="${(h.email || '').replace(/"/g, '&quot;')}"
                            data-phone="${(h.phone || '').replace(/"/g, '&quot;')}">
                            Edit
                        </button>
                        <button class="btn btn-sm btn-outline-danger btn-delete" data-id="${h.hotel_id}">Delete</button>
                    </td>
                </tr>`;
        });
        tbody.html(html);
    });
}

function escQ(s) { return (s || '').replace(/'/g, "\\'"); }

function openModal(id = '', chainId = '', cat = '', addr = '', email = '', phone = '') {
    $('#hotel_id').val(id);
    $('#chain_id').val(chainId);
    $('#category').val(cat);
    $('#address').val(addr);
    $('#email').val(email);
    $('#phone').val(phone);
    $('#modalTitle').text(id ? 'Edit Hotel' : 'Add Hotel');
    hotelModal.show();
}

function deleteHotel(id) {
    if (!confirm('Delete this hotel? This will also delete all associated rooms and employees.')) return;
    $.post('api/delete_hotel.php', { hotel_id: id }, function (res) {
        if (res.success) {
            showAlert('success', 'Hotel deleted.');
            loadHotels();
        } else {
            showAlert('danger', res.error);
        }
    });
}

function showAlert(type, msg) {
    $('#alertBox').html(`<div class="alert alert-${type} alert-dismissible fade show">${msg}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>`);
}

$('#hotelForm').on('submit', function (e) {
    e.preventDefault();
    $.post('api/save_hotel.php', $(this).serialize(), function (res) {
        if (res.success) {
            hotelModal.hide();
            showAlert('success', 'Hotel saved successfully.');
            loadHotels();
        } else {
            showAlert('danger', res.error);
        }
    });
});

$(function () {
    loadHotels();
    $.get('api/get_chains.php', function (res) {
        if (res.success) {
            res.data.forEach(c => {
                $('#chain_id').append(`<option value="${c.chain_id}">${c.name}</option>`);
            });
        }
    });

    $(document).on('click', '.btn-edit', function () {
        const b = $(this);
        openModal(b.data('id'), b.data('chain'), b.data('category'), b.data('address'), b.data('email'), b.data('phone'));
    });
    $(document).on('click', '.btn-delete', function () {
        deleteHotel($(this).data('id'));
    });
});
</script>
</body>
</html>
