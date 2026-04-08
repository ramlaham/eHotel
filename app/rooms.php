<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>eHotel - Manage Rooms</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        .navbar-brand { font-weight: 700; letter-spacing: 1px; }
        .table th { background-color: #0d6efd; color: #fff; }
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
                <li class="nav-item"><a class="nav-link" href="hotels.php">Hotels</a></li>
                <li class="nav-item"><a class="nav-link active" href="rooms.php">Rooms</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container my-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>🛏️ Manage Rooms</h2>
        <button class="btn btn-primary" onclick="openModal()">+ Add Room</button>
    </div>

    <!-- Hotel Filter -->
    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <div class="row align-items-end g-3">
                <div class="col-md-5">
                    <label class="form-label fw-semibold">Filter by Hotel</label>
                    <select class="form-select" id="filterHotel">
                        <option value="">All Hotels</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button class="btn btn-outline-primary" onclick="loadRooms()">Apply Filter</button>
                </div>
            </div>
        </div>
    </div>

    <div id="alertBox"></div>

    <div class="card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-striped table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Hotel</th>
                            <th>Price/Night</th>
                            <th>Capacity</th>
                            <th>View</th>
                            <th>Extendable</th>
                            <th>Amenities</th>
                            <th>Damages</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="roomsBody">
                        <tr><td colspan="9" class="text-center py-4 text-muted">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Room Modal -->
<div class="modal fade" id="roomModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="modalTitle">Add Room</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="roomForm">
                <div class="modal-body">
                    <input type="hidden" id="room_id" name="room_id">
                    <div class="row g-3">
                        <div class="col-md-12">
                            <label class="form-label">Hotel <span class="text-danger">*</span></label>
                            <select class="form-select" id="hotel_id" name="hotel_id" required>
                                <option value="">-- Select hotel --</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Price / Night ($) <span class="text-danger">*</span></label>
                            <input type="number" class="form-control" id="price" name="price" min="1" step="0.01" required>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Capacity <span class="text-danger">*</span></label>
                            <select class="form-select" id="capacity" name="capacity" required>
                                <option value="">-- Select --</option>
                                <option value="single">Single</option>
                                <option value="double">Double</option>
                                <option value="triple">Triple</option>
                                <option value="quad">Quad</option>
                                <option value="suite">Suite</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">View <span class="text-danger">*</span></label>
                            <select class="form-select" id="view" name="view" required>
                                <option value="">-- Select --</option>
                                <option value="sea">Sea</option>
                                <option value="mountain">Mountain</option>
                                <option value="city">City</option>
                                <option value="garden">Garden</option>
                                <option value="none">None</option>
                            </select>
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Amenities</label>
                            <input type="text" class="form-control" id="amenities" name="amenities" placeholder="WiFi, TV, Minibar, ...">
                        </div>
                        <div class="col-md-12">
                            <label class="form-label">Damages</label>
                            <input type="text" class="form-control" id="damages" name="damages" placeholder="Any known damage...">
                        </div>
                        <div class="col-md-12">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="extendable" name="extendable" value="1">
                                <label class="form-check-label" for="extendable">Room is Extendable</label>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Room</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
const roomModal = new bootstrap.Modal(document.getElementById('roomModal'));
let hotelsCache = [];

function loadRooms() {
    const hotelId = $('#filterHotel').val();
    const url = hotelId ? `api/get_rooms.php?hotel_id=${hotelId}` : 'api/get_rooms.php';
    $.get(url, function (res) {
        const tbody = $('#roomsBody');
        if (!res.success) {
            tbody.html(`<tr><td colspan="9" class="text-center text-danger">${res.error}</td></tr>`);
            return;
        }
        if (res.data.length === 0) {
            tbody.html('<tr><td colspan="9" class="text-center text-muted py-4">No rooms found.</td></tr>');
            return;
        }
        let html = '';
        res.data.forEach(r => {
            const ext = r.extendable == 't' || r.extendable === true
                ? '<span class="badge bg-success">Yes</span>'
                : '<span class="badge bg-secondary">No</span>';
            const extBool = r.extendable == 't' || r.extendable === true;
            html += `
                <tr>
                    <td>${r.room_id}</td>
                    <td><small>${r.hotel_address}</small></td>
                    <td>$${parseFloat(r.price).toFixed(2)}</td>
                    <td class="text-capitalize">${r.capacity}</td>
                    <td class="text-capitalize">${r.view}</td>
                    <td>${ext}</td>
                    <td><small>${r.amenities || '-'}</small></td>
                    <td><small class="text-warning">${r.damages || '-'}</small></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary me-1 btn-edit"
                            data-id="${r.room_id}"
                            data-hotel="${r.hotel_id}"
                            data-price="${parseFloat(r.price).toFixed(2)}"
                            data-capacity="${r.capacity}"
                            data-view="${r.view}"
                            data-amenities="${(r.amenities || '').replace(/"/g, '&quot;')}"
                            data-damages="${(r.damages || '').replace(/"/g, '&quot;')}"
                            data-ext="${extBool}">
                            Edit
                        </button>
                        <button class="btn btn-sm btn-outline-danger btn-delete" data-id="${r.room_id}">Delete</button>
                    </td>
                </tr>`;
        });
        tbody.html(html);
    });
}

function escQ(s) { return (s || '').replace(/'/g, "\\'"); }

function openModal(id = '', hotelId = '', price = '', cap = '', view = '', amenities = '', damages = '', ext = false) {
    $('#room_id').val(id);
    $('#hotel_id').val(hotelId);
    $('#price').val(price);
    $('#capacity').val(cap);
    $('#view').val(view);
    $('#amenities').val(amenities);
    $('#damages').val(damages);
    $('#extendable').prop('checked', ext);
    $('#modalTitle').text(id ? 'Edit Room' : 'Add Room');
    roomModal.show();
}

function deleteRoom(id) {
    if (!confirm('Delete this room?')) return;
    $.post('api/delete_room.php', { room_id: id }, function (res) {
        if (res.success) {
            showAlert('success', 'Room deleted.');
            loadRooms();
        } else {
            showAlert('danger', res.error);
        }
    });
}

function showAlert(type, msg) {
    $('#alertBox').html(`<div class="alert alert-${type} alert-dismissible fade show">${msg}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>`);
}

$('#roomForm').on('submit', function (e) {
    e.preventDefault();
    $.post('api/save_room.php', $(this).serialize(), function (res) {
        if (res.success) {
            roomModal.hide();
            showAlert('success', 'Room saved successfully.');
            loadRooms();
        } else {
            showAlert('danger', res.error);
        }
    });
});

$(function () {
    $.get('api/get_hotels.php', function (res) {
        if (res.success) {
            hotelsCache = res.data;
            res.data.forEach(h => {
                const opt = `<option value="${h.hotel_id}">${h.address} (${h.chain_name})</option>`;
                $('#filterHotel').append(opt);
                $('#hotel_id').append(opt);
            });
        }
        loadRooms();
    });

    $(document).on('click', '.btn-edit', function () {
        const b = $(this);
        openModal(b.data('id'), b.data('hotel'), b.data('price'), b.data('capacity'), b.data('view'),
                  b.data('amenities'), b.data('damages'), b.data('ext') === true || b.data('ext') === 'true');
    });
    $(document).on('click', '.btn-delete', function () {
        deleteRoom($(this).data('id'));
    });
});
</script>
</body>
</html>
