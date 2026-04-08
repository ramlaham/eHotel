<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>eHotel - Direct Rental</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        .navbar-brand { font-weight: 700; letter-spacing: 1px; }
        #newClientFields { display: none; }
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
                <li class="nav-item"><a class="nav-link" href="rooms.php">Rooms</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container my-4" style="max-width: 700px;">
    <h2 class="mb-4">🛎️ Direct Rental (Walk-in)</h2>
    <div id="alertBox"></div>

    <!-- Room Details -->
    <div class="card shadow-sm mb-4">
        <div class="card-header bg-success text-white fw-semibold">Room Details</div>
        <div class="card-body" id="roomDetails">
            <div class="text-center text-muted py-3">
                <div class="spinner-border spinner-border-sm me-2"></div> Loading room info...
            </div>
        </div>
    </div>

    <form id="rentalForm">
        <input type="hidden" name="room_id" id="room_id">
        <input type="hidden" name="start_date" id="start_date">
        <input type="hidden" name="end_date" id="end_date">

        <!-- Dates -->
        <div class="card shadow-sm mb-4">
            <div class="card-header fw-semibold">Stay Dates</div>
            <div class="card-body row g-3">
                <div class="col-md-6">
                    <label class="form-label">Check-in</label>
                    <input type="date" class="form-control" id="start_date_display" required>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Check-out</label>
                    <input type="date" class="form-control" id="end_date_display" required>
                </div>
            </div>
        </div>

        <!-- Client Section -->
        <div class="card shadow-sm mb-4">
            <div class="card-header fw-semibold">Client Information</div>
            <div class="card-body">
                <div class="mb-3">
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type="radio" name="client_type" id="clientExisting" value="existing" checked>
                        <label class="form-check-label" for="clientExisting">Existing Client</label>
                    </div>
                    <div class="form-check form-check-inline">
                        <input class="form-check-input" type="radio" name="client_type" id="clientNew" value="new">
                        <label class="form-check-label" for="clientNew">New Client</label>
                    </div>
                </div>

                <div id="existingClientFields">
                    <label class="form-label">Select Client</label>
                    <select class="form-select" name="client_id" id="client_id">
                        <option value="">-- Select a client --</option>
                    </select>
                </div>

                <div id="newClientFields">
                    <div class="mb-3">
                        <label class="form-label">Full Name</label>
                        <input type="text" class="form-control" name="full_name" id="full_name" placeholder="John Doe">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">SSN</label>
                        <input type="text" class="form-control" name="ssn" id="ssn" placeholder="123-45-6789">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Address</label>
                        <input type="text" class="form-control" name="address" id="address" placeholder="123 Main St, City">
                    </div>
                </div>
            </div>
        </div>

        <!-- Employee Section -->
        <div class="card shadow-sm mb-4">
            <div class="card-header fw-semibold">Assigned Employee</div>
            <div class="card-body">
                <label class="form-label">Select Employee</label>
                <select class="form-select" name="employee_id" id="employee_id" required>
                    <option value="">-- Select an employee --</option>
                </select>
            </div>
        </div>

        <div class="d-grid">
            <button type="submit" class="btn btn-success btn-lg">Confirm Rental</button>
        </div>
    </form>
</div>

<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
$(function () {
    const params   = new URLSearchParams(window.location.search);
    const roomId   = params.get('room_id')  || '';
    const checkIn  = params.get('check_in') || '';
    const checkOut = params.get('check_out')|| '';

    $('#room_id').val(roomId);
    $('#start_date').val(checkIn);
    $('#end_date').val(checkOut);
    $('#start_date_display').val(checkIn);
    $('#end_date_display').val(checkOut);

    // Load room details
    $.get('api/get_rooms.php', function (res) {
        if (res.success) {
            const room = res.data.find(r => r.room_id == roomId);
            if (room) {
                $('#roomDetails').html(`
                    <div class="row">
                        <div class="col-6"><strong>Hotel:</strong> ${room.hotel_address}</div>
                        <div class="col-6"><strong>Room ID:</strong> #${room.room_id}</div>
                        <div class="col-6 mt-2"><strong>Capacity:</strong> <span class="text-capitalize">${room.capacity}</span></div>
                        <div class="col-6 mt-2"><strong>View:</strong> <span class="text-capitalize">${room.view}</span></div>
                        <div class="col-6 mt-2"><strong>Price/Night:</strong> $${parseFloat(room.price).toFixed(2)}</div>
                        <div class="col-6 mt-2"><strong>Extendable:</strong> ${room.extendable == 't' ? 'Yes' : 'No'}</div>
                        <div class="col-12 mt-2"><strong>Amenities:</strong> ${room.amenities || '-'}</div>
                        ${room.damages ? `<div class="col-12 mt-2 text-warning"><strong>Damages:</strong> ${room.damages}</div>` : ''}
                    </div>
                `);
            }
        }
    });

    // Load clients
    $.get('api/get_clients.php', function (res) {
        if (res.success) {
            res.data.forEach(c => {
                $('#client_id').append(`<option value="${c.client_id}">${c.full_name} (${c.ssn})</option>`);
            });
        }
    });

    // Load employees
    $.get('api/get_employees.php', function (res) {
        if (res.success) {
            res.data.forEach(e => {
                $('#employee_id').append(`<option value="${e.employee_id}">${e.full_name} — ${e.role || 'N/A'} (${e.hotel_address || ''})</option>`);
            });
        }
    });

    // Toggle client fields
    $('input[name="client_type"]').on('change', function () {
        if ($(this).val() === 'new') {
            $('#existingClientFields').hide();
            $('#newClientFields').show();
        } else {
            $('#existingClientFields').show();
            $('#newClientFields').hide();
        }
    });

    // Sync date inputs
    $('#start_date_display').on('change', function () { $('#start_date').val($(this).val()); });
    $('#end_date_display').on('change', function ()   { $('#end_date').val($(this).val()); });

    // Submit
    $('#rentalForm').on('submit', function (e) {
        e.preventDefault();
        const data = {
            room_id:     $('#room_id').val(),
            start_date:  $('#start_date').val(),
            end_date:    $('#end_date').val(),
            employee_id: $('#employee_id').val(),
            client_type: $('input[name="client_type"]:checked').val(),
            client_id:   $('#client_id').val(),
            full_name:   $('#full_name').val(),
            ssn:         $('#ssn').val(),
            address:     $('#address').val(),
        };

        $.post('api/create_rental.php', data, function (res) {
            if (res.success) {
                $('#alertBox').html(`<div class="alert alert-success">✅ Rental #${res.rental_id} confirmed! <a href="index.php" class="alert-link">Back to Search</a></div>`);
                $('#rentalForm').hide();
            } else {
                $('#alertBox').html(`<div class="alert alert-danger">❌ ${res.error}</div>`);
            }
        });
    });
});
</script>
</body>
</html>
