<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>eHotel - Check-in</title>
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
                <li class="nav-item"><a class="nav-link active" href="checkin.php">Check-in</a></li>
                <li class="nav-item"><a class="nav-link" href="clients.php">Clients</a></li>
                <li class="nav-item"><a class="nav-link" href="employees.php">Employees</a></li>
                <li class="nav-item"><a class="nav-link" href="hotels.php">Hotels</a></li>
                <li class="nav-item"><a class="nav-link" href="rooms.php">Rooms</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container my-4">
    <h2 class="mb-1">🏁 Check-in</h2>
    <p class="text-muted mb-4">Convert an active reservation into a rental by checking the client in.</p>

    <div id="alertBox"></div>

    <div class="card shadow-sm">
        <div class="card-header d-flex justify-content-between align-items-center bg-primary text-white">
            <span class="fw-semibold">Active Reservations</span>
            <button class="btn btn-sm btn-light" onclick="loadReservations()">↻ Refresh</button>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-striped table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>Res. ID</th>
                            <th>Client</th>
                            <th>Room</th>
                            <th>Hotel</th>
                            <th>Check-in</th>
                            <th>Check-out</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="reservationsBody">
                        <tr><td colspan="7" class="text-center py-4 text-muted">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Check-in Modal -->
<div class="modal fade" id="checkinModal" tabindex="-1" aria-labelledby="checkinModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="checkinModalLabel">✅ Confirm Check-in</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p id="checkinInfo" class="text-muted"></p>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Assign Employee</label>
                    <select class="form-select" id="checkinEmployee">
                        <option value="">-- Select an employee --</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <button class="btn btn-primary" id="confirmCheckin">Check In</button>
            </div>
        </div>
    </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
let currentResId = null;
const checkinModal = new bootstrap.Modal(document.getElementById('checkinModal'));

function loadReservations() {
    $.get('api/get_reservations.php?status=active', function (res) {
        const tbody = $('#reservationsBody');
        if (!res.success) {
            tbody.html(`<tr><td colspan="7" class="text-center text-danger">${res.error}</td></tr>`);
            return;
        }
        if (res.data.length === 0) {
            tbody.html('<tr><td colspan="7" class="text-center text-muted py-4">No active reservations found.</td></tr>');
            return;
        }
        let html = '';
        res.data.forEach(r => {
            html += `
                <tr>
                    <td>#${r.reservation_id}</td>
                    <td>${r.client_name}</td>
                    <td>#${r.room_id} (${r.capacity})</td>
                    <td><small>${r.hotel_address}</small></td>
                    <td>${r.start_date}</td>
                    <td>${r.end_date}</td>
                    <td>
                        <button class="btn btn-sm btn-primary" onclick="openCheckin(${r.reservation_id}, '${r.client_name}', '${r.hotel_address}')">
                            Check In
                        </button>
                    </td>
                </tr>`;
        });
        tbody.html(html);
    });
}

function openCheckin(resId, clientName, hotel) {
    currentResId = resId;
    $('#checkinInfo').text(`Reservation #${resId} — ${clientName} at ${hotel}`);
    checkinModal.show();
}

$('#confirmCheckin').on('click', function () {
    const employeeId = $('#checkinEmployee').val();
    if (!employeeId) {
        alert('Please select an employee.');
        return;
    }

    $.post('api/convert_reservation.php', {
        reservation_id: currentResId,
        employee_id: employeeId
    }, function (res) {
        checkinModal.hide();
        if (res.success) {
            $('#alertBox').html(`<div class="alert alert-success alert-dismissible fade show">✅ Check-in complete! Rental #${res.rental_id} created. <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>`);
            loadReservations();
        } else {
            $('#alertBox').html(`<div class="alert alert-danger alert-dismissible fade show">❌ ${res.error} <button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>`);
        }
    });
});

$(function () {
    loadReservations();
    $.get('api/get_employees.php', function (res) {
        if (res.success) {
            res.data.forEach(e => {
                $('#checkinEmployee').append(`<option value="${e.employee_id}">${e.full_name} — ${e.role || 'N/A'}</option>`);
            });
        }
    });
});
</script>
</body>
</html>
