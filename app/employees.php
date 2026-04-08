<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>eHotel - Manage Employees</title>
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
                <li class="nav-item"><a class="nav-link active" href="employees.php">Employees</a></li>
                <li class="nav-item"><a class="nav-link" href="hotels.php">Hotels</a></li>
                <li class="nav-item"><a class="nav-link" href="rooms.php">Rooms</a></li>
            </ul>
        </div>
    </div>
</nav>

<div class="container my-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2>🧑‍💼 Manage Employees</h2>
        <button class="btn btn-primary" id="btnAddEmployee">+ Add Employee</button>
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
                            <th>Role</th>
                            <th>Hotel</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="employeesBody">
                        <tr><td colspan="6" class="text-center py-4 text-muted">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Employee Modal -->
<div class="modal fade" id="employeeModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title" id="modalTitle">Add Employee</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <form id="employeeForm">
                <div class="modal-body">
                    <input type="hidden" id="employee_id" name="employee_id">
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
                        <input type="text" class="form-control" id="address" name="address">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Role</label>
                        <select class="form-select" id="role" name="role">
                            <option value="">-- Select role --</option>
                            <option value="Manager">Manager</option>
                            <option value="Receptionist">Receptionist</option>
                            <option value="Housekeeping">Housekeeping</option>
                            <option value="Concierge">Concierge</option>
                            <option value="Maintenance">Maintenance</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Hotel</label>
                        <select class="form-select" id="hotel_id" name="hotel_id">
                            <option value="">-- Select hotel --</option>
                        </select>
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
const employeeModal = new bootstrap.Modal(document.getElementById('employeeModal'));

function loadEmployees() {
    $.get('api/get_employees.php', function (res) {
        const tbody = $('#employeesBody');
        if (!res.success) {
            tbody.html(`<tr><td colspan="6" class="text-center text-danger">${res.error}</td></tr>`);
            return;
        }
        if (res.data.length === 0) {
            tbody.html('<tr><td colspan="6" class="text-center text-muted">No employees found.</td></tr>');
            return;
        }
        let html = '';
        res.data.forEach(e => {
            html += `
                <tr>
                    <td>${e.employee_id}</td>
                    <td>${e.full_name}</td>
                    <td>${e.ssn}</td>
                    <td>${e.role || '-'}</td>
                    <td><small>${e.hotel_address || '-'}</small></td>
                    <td>
                        <button class="btn btn-sm btn-outline-primary me-1 btn-edit"
                            data-id="${e.employee_id}"
                            data-name="${(e.full_name || '').replace(/"/g, '&quot;')}"
                            data-ssn="${e.ssn}"
                            data-address="${(e.address || '').replace(/"/g, '&quot;')}"
                            data-role="${e.role || ''}"
                            data-hotel="${e.hotel_id || ''}">
                            Edit
                        </button>
                        <button class="btn btn-sm btn-outline-danger btn-delete" data-id="${e.employee_id}">Delete</button>
                    </td>
                </tr>`;
        });
        tbody.html(html);
    });
}

function escQ(s) { return (s || '').replace(/'/g, "\\'"); }

function openModal(id = '', name = '', ssn = '', addr = '', role = '', hotelId = '') {
    $('#employee_id').val(id);
    $('#full_name').val(name);
    $('#ssn').val(ssn);
    $('#address').val(addr);
    $('#role').val(role);
    $('#hotel_id').val(hotelId);
    $('#modalTitle').text(id ? 'Edit Employee' : 'Add Employee');
    employeeModal.show();
}

function deleteEmployee(id) {
    if (!confirm('Delete this employee?')) return;
    $.post('api/delete_employee.php', { employee_id: id }, function (res) {
        if (res.success) {
            showAlert('success', 'Employee deleted.');
            loadEmployees();
        } else {
            showAlert('danger', res.error);
        }
    });
}

function showAlert(type, msg) {
    $('#alertBox').html(`<div class="alert alert-${type} alert-dismissible fade show">${msg}<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>`);
}

$('#employeeForm').on('submit', function (e) {
    e.preventDefault();
    $.post('api/save_employee.php', $(this).serialize(), function (res) {
        if (res.success) {
            employeeModal.hide();
            showAlert('success', 'Employee saved successfully.');
            loadEmployees();
        } else {
            showAlert('danger', res.error);
        }
    });
});

$(function () {
    loadEmployees();
    $.get('api/get_hotels.php', function (res) {
        if (res.success) {
            res.data.forEach(h => {
                $('#hotel_id').append(`<option value="${h.hotel_id}">${h.address} (${h.chain_name})</option>`);
            });
        }
    });

    $(document).on('click', '#btnAddEmployee', function () { openModal(); });
    $(document).on('click', '.btn-edit', function () {
        const b = $(this);
        openModal(b.data('id'), b.data('name'), b.data('ssn'), b.data('address'), b.data('role'), b.data('hotel'));
    });
    $(document).on('click', '.btn-delete', function () {
        deleteEmployee($(this).data('id'));
    });
});
</script>
</body>
</html>
