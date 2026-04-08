<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>eHotel - Manage Clients</title>
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
                <li class="nav-item"><a class="nav-link active" href="clients.php">Clients</a></li>
                <li class="nav-item"><a class="nav-link" href="employees.php">Employees</a></li>
                <li class="nav-item"><a class="nav-link" href="hotels.php">Hotels</a></li>
                <li class="nav-item"><a class="nav-link" href="rooms.php">Rooms</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container my-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>👤 Manage Clients</h2>
        <button class="btn btn-primary" onclick="openModal()">+ Add Client</button>
    </div>
    <div id="alertBox"></div>

    <div class="card shadow-sm">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-striped table-hover align-middle mb-0">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Full Name</th>
                            <th>SSN</th>
                            <th>Address</th>
                            <th>Registered</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="clientsBody">
                        <tr><td colspan="6" class="text-center py-4 text-muted">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Client Modal -->
<div class="modal fade" id="clientModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="modalTitle">Add Client</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="clientForm">
                <div class="modal-body">
                    <input type="hidden" id="client_id" name="client_id">
                    <div class="mb-3">
                        <label class="form-label">Full Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="full_name" name="full_name" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">SSN <span class="text-danger">*</span></label>
                        <input type="text" class="form-control" id="ssn" name="ssn" placeholder="123-45-6789" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Address</label>
                        <input type="text" class="form-control" id="address" name="address" placeholder="123 Main St, City">
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
const clientModal = new bootstrap.Modal(document.getElementById('clientModal'));

function loadClients() {
    $.get('api/get_clients.php', function (res) {
        const tbody = $('#clientsBody');
        if (!res.success) {
            tbody.html(`<tr><td colspan="6" class="text-center text-danger">${res.error}</td></tr>`);
            return;
        }
        if (res.data.length === 0) {
            tbody.html('<tr><td colspan="6" class="text-center text-muted">No clients found.</td></tr>');
            return;
        }
        let html = '';
        res.data.forEach(c => {
            html += `
                <tr>
                    <td>${c.client_id}</td>
                    <td>${c.full_name}</td>
                    <td>${c.ssn}</td>
                    <td>${c.address || '-'}</td>
                    <td>${c.registration_date}</td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary me-1 btn-edit"
                            data-id="${c.client_id}"
                            data-name="${c.full_name.replace(/"/g, '&quot;')}"
                            data-ssn="${c.ssn}"
                            data-address="${(c.address || '').replace(/"/g, '&quot;')}">
                            Edit
                        </button>
                        <button class="btn btn-sm btn-outline-danger btn-delete" data-id="${c.client_id}">Delete</button>
                    </td>
                </tr>`;
        });
        tbody.html(html);
    });
}

function escQ(s) { return (s || '').replace(/'/g, "\\'"); }

function openModal(id = '', name = '', ssn = '', addr = '') {
    $('#client_id').val(id);
    $('#full_name').val(name);
    $('#ssn').val(ssn);
    $('#address').val(addr);
    $('#modalTitle').text(id ? 'Edit Client' : 'Add Client');
    clientModal.show();
}

function deleteClient(id) {
    if (!confirm('Delete this client? This cannot be undone.')) return;
    $.post('api/delete_client.php', { client_id: id }, function (res) {
        if (res.success) {
            showAlert('success', 'Client deleted.');
            loadClients();
        } else {
            showAlert('danger', res.error);
        }
    });
}

function showAlert(type, msg) {
    $('#alertBox').html(`<div class="alert alert-${type} alert-dismissible fade show">${msg}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>`);
}

$('#clientForm').on('submit', function (e) {
    e.preventDefault();
    $.post('api/save_client.php', $(this).serialize(), function (res) {
        if (res.success) {
            clientModal.hide();
            showAlert('success', 'Client saved successfully.');
            loadClients();
        } else {
            showAlert('danger', res.error);
        }
    });
});

// Event delegation for dynamically rendered buttons
$(document).on('click', '.btn-edit', function () {
    const btn = $(this);
    openModal(btn.data('id'), btn.data('name'), btn.data('ssn'), btn.data('address'));
});
$(document).on('click', '.btn-delete', function () {
    deleteClient($(this).data('id'));
});

$(loadClients);
</script>
</body>
</html>
