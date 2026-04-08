<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>eHotel - Search Rooms</title>
    <link rel="stylesheet" href="assets/css/bootstrap.min.css">
    <style>
        .star-rating { color: #f4c430; }
        .navbar-brand { font-weight: 700; letter-spacing: 1px; }
        .table th { background-color: #0d6efd; color: #fff; }
        .badge-extendable { background-color: #198754; }
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
                <li class="nav-item"><a class="nav-link active" href="index.php">Search Rooms</a></li>
                <li class="nav-item"><a class="nav-link" href="checkin.php">Check-in</a></li>
                <li class="nav-item"><a class="nav-link" href="clients.php">Clients</a></li>
                <li class="nav-item"><a class="nav-link" href="employees.php">Employees</a></li>
                <li class="nav-item"><a class="nav-link" href="hotels.php">Hotels</a></li>
                <li class="nav-item"><a class="nav-link" href="rooms.php">Rooms</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container my-4">
    <h2 class="mb-4">🔍 Search Available Rooms</h2>

    <div class="card shadow-sm mb-4">
        <div class="card-body">
            <form id="searchForm">
                <div class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Check-in Date</label>
                        <input type="date" class="form-control" id="check_in" name="check_in" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Check-out Date</label>
                        <input type="date" class="form-control" id="check_out" name="check_out" required>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Capacity</label>
                        <select class="form-select" id="capacity" name="capacity">
                            <option value="all">All</option>
                            <option value="single">Single</option>
                            <option value="double">Double</option>
                            <option value="triple">Triple</option>
                            <option value="quad">Quad</option>
                            <option value="suite">Suite</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">City / Zone</label>
                        <input type="text" class="form-control" id="zone" name="zone" placeholder="e.g. New York">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Hotel Chain</label>
                        <select class="form-select" id="chain_id" name="chain_id">
                            <option value="all">All Chains</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Category (Stars)</label>
                        <select class="form-select" id="category" name="category">
                            <option value="any">Any</option>
                            <option value="1">★ 1 Star</option>
                            <option value="2">★★ 2 Stars</option>
                            <option value="3">★★★ 3 Stars</option>
                            <option value="4">★★★★ 4 Stars</option>
                            <option value="5">★★★★★ 5 Stars</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-semibold">Max Price / Night ($)</label>
                        <input type="number" class="form-control" id="max_price" name="max_price" min="0" step="10" placeholder="Any price">
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <div class="form-check me-3">
                            <input class="form-check-input" type="checkbox" id="extendable" name="extendable">
                            <label class="form-check-label fw-semibold" for="extendable">Extendable Only</label>
                        </div>
                        <button type="submit" class="btn btn-primary">Search</button>
                    </div>
                </div>
            </form>
        </div>
    </div>

    <div id="searchResults">
        <div class="text-center py-4 text-muted" id="loadingMsg">
            <div class="spinner-border spinner-border-sm me-2" role="status"></div> Loading available rooms...
        </div>
    </div>
</div>

<script src="assets/js/jquery.min.js"></script>
<script src="assets/js/bootstrap.bundle.min.js"></script>
<script>
$(function () {
    // Set default dates
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);
    $('#check_in').val(today.toISOString().split('T')[0]);
    $('#check_out').val(tomorrow.toISOString().split('T')[0]);

    // Load chains
    $.get('api/get_chains.php', function (res) {
        if (res.success) {
            res.data.forEach(c => {
                $('#chain_id').append(`<option value="${c.chain_id}">${c.name}</option>`);
            });
        }
    });

    function doSearch() {
        const check_in  = $('#check_in').val();
        const check_out = $('#check_out').val();
        if (!check_in || !check_out) return;
        if (check_out <= check_in) {
            $('#searchResults').html('<div class="alert alert-warning">Check-out must be after check-in.</div>');
            return;
        }

        $('#loadingMsg').show();
        $('#searchResults').html('<div class="text-center py-4 text-muted"><div class="spinner-border spinner-border-sm me-2"></div> Searching...</div>');

        const params = {
            check_in,
            check_out,
            capacity:   $('#capacity').val(),
            zone:       $('#zone').val(),
            chain_id:   $('#chain_id').val(),
            category:   $('#category').val(),
            max_price:  $('#max_price').val(),
            extendable: $('#extendable').is(':checked') ? '1' : '0',
        };

        $.get('api/search_rooms.php', params, function (res) {
            if (!res.success) {
                $('#searchResults').html(`<div class="alert alert-danger">${res.error}</div>`);
                return;
            }
            if (res.data.length === 0) {
                $('#searchResults').html('<div class="alert alert-info">No available rooms found for the selected criteria.</div>');
                return;
            }

            let stars = (n) => '★'.repeat(n) + '☆'.repeat(5 - n);
            let html = `
                <p class="text-muted">${res.data.length} room(s) found</p>
                <div class="table-responsive">
                <table class="table table-striped table-hover align-middle shadow-sm">
                    <thead>
                        <tr>
                            <th>Hotel</th><th>Chain</th><th>Stars</th><th>City</th>
                            <th>Capacity</th><th>View</th><th>Price/Night</th>
                            <th>Amenities</th><th>Extendable</th><th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>`;

            res.data.forEach(r => {
                const ext = r.extendable == 't' || r.extendable === true
                    ? '<span class="badge bg-success">Yes</span>'
                    : '<span class="badge bg-secondary">No</span>';
                const starsHtml = `<span class="star-rating">${stars(parseInt(r.category))}</span>`;
                html += `
                    <tr>
                        <td>${r.address.split(',')[0]}</td>
                        <td>${r.chain_name}</td>
                        <td>${starsHtml}</td>
                        <td>${r.city}</td>
                        <td class="text-capitalize">${r.capacity}</td>
                        <td class="text-capitalize">${r.view}</td>
                        <td><strong>$${parseFloat(r.price).toFixed(2)}</strong></td>
                        <td><small>${r.amenities || '-'}</small></td>
                        <td>${ext}</td>
                        <td>
                            <a href="reservation.php?room_id=${r.room_id}&check_in=${check_in}&check_out=${check_out}"
                               class="btn btn-sm btn-outline-primary me-1">Book Now</a>
                            <a href="rental.php?room_id=${r.room_id}&check_in=${check_in}&check_out=${check_out}"
                               class="btn btn-sm btn-outline-success">Rent Now</a>
                        </td>
                    </tr>`;
            });
            html += '</tbody></table></div>';
            $('#searchResults').html(html);
        }).fail(function () {
            $('#searchResults').html('<div class="alert alert-danger">Search failed. Please try again.</div>');
        });
    }

    $('#searchForm').on('submit', function (e) {
        e.preventDefault();
        doSearch();
    });

    $('#check_in, #check_out, #capacity, #zone, #chain_id, #category, #max_price, #extendable').on('change', function () {
        doSearch();
    });

    // Auto search on load
    doSearch();
});
</script>
</body>
</html>
