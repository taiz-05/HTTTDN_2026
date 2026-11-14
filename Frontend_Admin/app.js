const API = "http://localhost:5000/api/admin";

const FALLBACK_ROLES = [
    { roleId: 1, roleName: "Admin", description: "Quản trị viên máy chủ hệ thống" },
    { roleId: 2, roleName: "Manager", description: "Người quản lý phân hệ CRM" },
    { roleId: 3, roleName: "Customer", description: "Khách hàng mua sắm và đánh giá" }
];

const FALLBACK_ACCOUNTS = [
    { accountId: 1, username: "admin", fullName: "Nguyễn Quản Trị Hệ Thống", email: "admin@sgutech.vn", phone: "0901000001", roleId: 1, roleName: "Admin", isActive: true },
    { accountId: 2, username: "admin2", fullName: "Lê Hoàng Nam (Bảo mật IT)", email: "nam.le@sgutech.vn", phone: "0901000003", roleId: 1, roleName: "Admin", isActive: true },
    { accountId: 3, username: "quanly", fullName: "Trần Trưởng Phòng CRM", email: "crm.manager@sgutech.vn", phone: "0901000002", roleId: 2, roleName: "Manager", isActive: true },
    { accountId: 4, username: "quanly_cskh", fullName: "Nguyễn Thu Trang (Phó phòng CSKH)", email: "trang.nguyen@sgutech.vn", phone: "0901000004", roleId: 2, roleName: "Manager", isActive: true },
    { accountId: 5, username: "khachhang1", fullName: "Nguyễn Văn An", email: "an.nguyen@gmail.com", phone: "0912345671", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 6, username: "khachhang2", fullName: "Lê Thị Bình", email: "binh.le@gmail.com", phone: "0912345672", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 7, username: "khachhang3", fullName: "Phạm Minh Châu", email: "chau.pham@gmail.com", phone: "0912345673", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 8, username: "khachhang4", fullName: "Hoàng Đức Dũng", email: "dung.hoang@gmail.com", phone: "0912345674", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 9, username: "khachhang5", fullName: "Võ Ngọc Hân (Tài khoản vi phạm - Đã khóa)", email: "han.vo@gmail.com", phone: "0912345675", roleId: 3, roleName: "Customer", isActive: false },
    { accountId: 10, username: "khachhang6", fullName: "Trần Quốc Bảo", email: "bao.tran@gmail.com", phone: "0912345676", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 11, username: "khachhang7", fullName: "Đặng Thúy Kiều", email: "kieu.dang@gmail.com", phone: "0912345677", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 12, username: "khachhang8", fullName: "Vũ Tuấn Kiệt", email: "kiet.vu@gmail.com", phone: "0912345678", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 13, username: "khachhang9", fullName: "Bùi Quỳnh Chi", email: "chi.bui@gmail.com", phone: "0912345679", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 14, username: "khachhang10", fullName: "Đỗ Hoàng Long", email: "long.do@gmail.com", phone: "0912345680", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 15, username: "khachhang11", fullName: "Ngô Phương Thảo", email: "thao.ngo@gmail.com", phone: "0912345681", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 16, username: "khachhang12", fullName: "Trịnh Gia Huy", email: "huy.trinh@gmail.com", phone: "0912345682", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 17, username: "khachhang13", fullName: "Mai Anh Tuấn", email: "tuan.mai@gmail.com", phone: "0912345683", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 18, username: "khachhang14", fullName: "Dương Hoàng Yến", email: "yen.duong@gmail.com", phone: "0912345684", roleId: 3, roleName: "Customer", isActive: true },
    { accountId: 19, username: "khachhang15", fullName: "Phan Thành Đạt (Tạm ngưng giao dịch)", email: "dat.phan@gmail.com", phone: "0912345685", roleId: 3, roleName: "Customer", isActive: false }
];

let rolesList = FALLBACK_ROLES;
let allAccountsCache = FALLBACK_ACCOUNTS;
let currentAccountRoleFilter = "all";
let currentUser = null;

// KÊNH ĐỒNG BỘ DỮ LIỆU GIỮA CÁC TAB
const syncChannel = new BroadcastChannel("htttdn_realtime_sync");

function notifyDataChanged(scope) {
    const payload = { scope, timestamp: Date.now() };
    syncChannel.postMessage(payload);
    localStorage.setItem("htttdn_sync_event", JSON.stringify(payload));
}

syncChannel.onmessage = () => refreshAdminData();
window.addEventListener("storage", (e) => {
    if (e.key === "htttdn_sync_event") refreshAdminData();
});
window.addEventListener("focus", () => refreshAdminData());

window.onload = async () => {
    currentUser = JSON.parse(localStorage.getItem("currentUser") || "null");
    if (!currentUser || currentUser.roleName !== "Admin") {
        currentUser = {
            id: 1,
            username: "admin",
            fullName: "Nguyễn Quản Trị Hệ Thống",
            roleName: "Admin"
        };
        localStorage.setItem("currentUser", JSON.stringify(currentUser));
    }

    const adminNameEl = document.getElementById("adminName");
    if (adminNameEl) {
        adminNameEl.innerText = `${currentUser.fullName} (${currentUser.username})`;
    }

    await loadRoles();
    await loadAccounts();
};

async function refreshAdminData() {
    await loadRoles();
    await loadAccounts();
}

function switchTab(id, btn) {
    document.querySelectorAll(".tab-content").forEach(el => el.style.display = "none");
    document.querySelectorAll(".nav-item").forEach(el => el.classList.remove("active"));
    const target = document.getElementById(id);
    if (target) target.style.display = "block";
    if (btn) btn.classList.add("active");

    const breadcrumbMap = {
        tabAccounts: "Quản lý Tài khoản & Phân quyền",
        tabRoleMatrix: "Cơ cấu Phân quyền & Phân tách Hệ thống"
    };
    const bEl = document.getElementById("admBreadcrumb");
    if (bEl && breadcrumbMap[id]) {
        bEl.innerText = breadcrumbMap[id];
    }
}

function getRoleVietnameseLabel(roleName) {
    const map = {
        "Admin": "Admin (Quản trị máy chủ)",
        "Manager": "Manager (Người quản lý CRM)",
        "Customer": "Customer (Khách hàng)"
    };
    return map[roleName] || roleName;
}

function getRolePortalName(roleName) {
    const map = {
        "Admin": "Giao diện Admin Server (admin.html)",
        "Manager": "Giao diện Người quản lý CRM (manager_crm.html)",
        "Customer": "Giao diện Khách hàng (user.html)"
    };
    return map[roleName] || "Giao diện phân hệ";
}

// =========================================================
// 1. NẠP DANH SÁCH ROLES & HIỂN THỊ BẢNG PHÂN QUYỀN
// =========================================================
async function loadRoles() {
    try {
        const res = await fetch(`${API}/accounts/roles`);
        if (res.ok) {
            const data = await res.json();
            if (data && data.length > 0) {
                // Chỉ nhận 3 roles: Admin, Manager, Customer
                rolesList = data.filter(r => ["Admin", "Manager", "Customer"].includes(r.roleName));
            }
        }
    } catch (e) {
        console.warn("Backend offline, sử dụng danh sách 3 roles chuẩn:", e);
        rolesList = FALLBACK_ROLES;
    }

    const optionsHtml = rolesList
        .map(r => `<option value="${r.roleId}">${getRoleVietnameseLabel(r.roleName)}</option>`)
        .join("");

    const mRole = document.getElementById("mAccRole");
    if (mRole) mRole.innerHTML = optionsHtml;

    const qRole = document.getElementById("qAccRole");
    if (qRole) qRole.innerHTML = optionsHtml;
}

// =========================================================
// 2. NẠP DANH SÁCH ACCOUNT, THÊM, XÓA, PHÂN QUYỀN ACCOUNT
// =========================================================
async function loadAccounts() {
    try {
        const res = await fetch(`${API}/accounts`);
        if (res.ok) {
            const data = await res.json();
            if (data && data.length > 0) {
                // Lọc bỏ bất kỳ account nào thuộc role cũ nếu có
                allAccountsCache = data.filter(a => ["Admin", "Manager", "Customer"].includes(a.roleName));
            }
        }
    } catch (e) {
        console.warn("Backend offline, sử dụng danh sách tài khoản demo chuẩn:", e);
        allAccountsCache = FALLBACK_ACCOUNTS;
    }

    // Cập nhật 4 thẻ KPI
    const total = allAccountsCache.length;
    const activeCount = allAccountsCache.filter(a => a.isActive).length;
    const adminCount = allAccountsCache.filter(a => a.roleName === "Admin").length;
    const managerCount = allAccountsCache.filter(a => a.roleName === "Manager").length;
    const customerCount = allAccountsCache.filter(a => a.roleName === "Customer").length;

    if (document.getElementById("kpiTotalAccounts")) document.getElementById("kpiTotalAccounts").innerText = total;
    if (document.getElementById("kpiActiveSub")) document.getElementById("kpiActiveSub").innerText = `${activeCount} Hoạt động · ${total - activeCount} Đã khóa`;
    if (document.getElementById("kpiAdminCount")) document.getElementById("kpiAdminCount").innerText = adminCount;
    if (document.getElementById("kpiManagerCount")) document.getElementById("kpiManagerCount").innerText = managerCount;
    if (document.getElementById("kpiCustomerCount")) document.getElementById("kpiCustomerCount").innerText = customerCount;

    renderFilteredAccounts();
    renderRoleSummaryTable();
}

function filterAccountsByRole(role, btn) {
    currentAccountRoleFilter = role;
    document.querySelectorAll("#tabAccounts .filter-toolbar button").forEach(b => b.classList.remove("active"));
    if (btn) btn.classList.add("active");
    renderFilteredAccounts();
}

function renderFilteredAccounts() {
    const tbody = document.getElementById("accountTable");
    if (!tbody) return;

    const kw = (document.getElementById("accSearchInput")?.value || "").trim().toLowerCase();

    const filtered = allAccountsCache.filter(a => {
        if (currentAccountRoleFilter === "Admin" && a.roleName !== "Admin") return false;
        if (currentAccountRoleFilter === "Manager" && a.roleName !== "Manager") return false;
        if (currentAccountRoleFilter === "Customer" && a.roleName !== "Customer") return false;

        if (kw) {
            const uMatch = a.username && a.username.toLowerCase().includes(kw);
            const nMatch = a.fullName && a.fullName.toLowerCase().includes(kw);
            const eMatch = a.email && a.email.toLowerCase().includes(kw);
            const pMatch = a.phone && a.phone.toLowerCase().includes(kw);
            if (!uMatch && !nMatch && !eMatch && !pMatch) return false;
        }
        return true;
    });

    const badgeEl = document.getElementById("accountCountBadge");
    if (badgeEl) badgeEl.innerText = `Đang hiển thị ${filtered.length} / ${allAccountsCache.length} account`;

    if (filtered.length === 0) {
        tbody.innerHTML = `<tr><td colspan="5" style="text-align:center; padding:28px; color:var(--text-muted); font-size:13.5px;">Không tìm thấy tài khoản nào khớp điều kiện lọc.</td></tr>`;
        return;
    }

    tbody.innerHTML = filtered.map(a => {
        let roleBadge = "";
        if (a.roleName === "Admin") {
            roleBadge = `<span class="badge badge-admin"><span class="status-dot red"></span> Admin Server</span>`;
        } else if (a.roleName === "Manager") {
            roleBadge = `<span class="badge badge-manager"><span class="status-dot green"></span> Quản lý CRM</span>`;
        } else {
            roleBadge = `<span class="badge badge-customer"><span class="status-dot orange"></span> Khách hàng</span>`;
        }

        const roleOptions = rolesList.map(r =>
            `<option value="${r.roleId}" ${(r.roleId === a.roleId || r.roleName === a.roleName) ? "selected" : ""}>${getRoleVietnameseLabel(r.roleName)}</option>`
        ).join("");

        const initials = (a.fullName || a.username || "U")
            .split(" ")
            .filter(Boolean)
            .map(p => p[0])
            .slice(-2)
            .join("")
            .toUpperCase() || "US";

        return `
            <tr>
                <!-- CỘT 1: THÀNH VIÊN & TÀI KHOẢN -->
                <td>
                    <div style="display:flex; align-items:center; gap:12px;">
                        <div class="user-avatar-circle" style="width:38px; height:38px; font-size:13px; font-weight:800; background:linear-gradient(135deg, #FF6A00, #EE4D00); color:#ffffff; flex-shrink:0;">
                            ${initials}
                        </div>
                        <div>
                            <div style="font-weight:700; font-size:13.5px; color:#0F172A; white-space:nowrap;">
                                ${a.fullName} <span style="font-size:11px; font-weight:600; color:#64748B; margin-left:4px;">#${a.accountId}</span>
                            </div>
                            <div style="font-size:12px; color:#64748B; margin-top:2px;">@${a.username}</div>
                        </div>
                    </div>
                </td>

                <!-- CỘT 2: THÔNG TIN LIÊN HỆ -->
                <td>
                    <div style="font-size:13px; font-weight:500; color:#0F172A; white-space:nowrap;">${a.email || "Chưa cập nhật email"}</div>
                    <div style="font-size:12px; color:#64748B; margin-top:2px; white-space:nowrap;">📞 ${a.phone || "Chưa có SĐT"}</div>
                </td>

                <!-- CỘT 3: VAI TRÒ & PHÂN QUYỀN -->
                <td>
                    <div style="margin-bottom:6px;">${roleBadge}</div>
                    <div style="display:flex; gap:6px; align-items:center;">
                        <select id="roleSelect_${a.accountId}" style="padding:5px 8px; font-size:12px; font-weight:600; border-radius:6px; border:1px solid #CBD5E1; background:#ffffff; min-width:145px;">
                            ${roleOptions}
                        </select>
                        <button class="btn" style="padding:5px 12px; font-size:11.5px; border-radius:6px; white-space:nowrap;" onclick="changeAccountRole(${a.accountId})">
                            Lưu quyền
                        </button>
                    </div>
                </td>

                <!-- CỘT 4: TRẠNG THÁI -->
                <td>
                    <span class="badge ${a.isActive ? 'badge-active' : 'badge-locked'}" style="white-space:nowrap;">
                        <span class="status-dot ${a.isActive ? 'green' : 'red'}"></span>
                        ${a.isActive ? 'Hoạt động' : 'Đã khóa TK'}
                    </span>
                </td>

                <!-- CỘT 5: THAO TÁC QUẢN LÝ -->
                <td style="text-align:center;">
                    <div style="display:inline-flex; gap:6px; white-space:nowrap;">
                        <button class="btn btn-warning" style="padding:6px 12px; font-size:12px; border-radius:6px;" onclick="toggleAccountLock(${a.accountId})">
                            ${a.isActive ? 'Khóa TK' : 'Mở khóa'}
                        </button>
                        <button class="btn btn-danger" style="padding:6px 12px; font-size:12px; border-radius:6px;" onclick="deleteAccount(${a.accountId})">
                            Xóa
                        </button>
                    </div>
                </td>
            </tr>
        `;
    }).join("");
}

function renderRoleSummaryTable() {
    const tbody = document.getElementById("roleSummaryTable");
    if (!tbody) return;

    tbody.innerHTML = rolesList.map(r => {
        const count = allAccountsCache.filter(a => a.roleId === r.roleId || a.roleName === r.roleName).length;
        return `
            <tr>
                <td><b>#${r.roleId}</b></td>
                <td><span class="badge badge-info">${r.roleName}</span></td>
                <td>${r.description || getRoleVietnameseLabel(r.roleName)}</td>
                <td><b>${getRolePortalName(r.roleName)}</b></td>
                <td style="text-align:center;"><b style="font-size:14px;">${count}</b> account</td>
            </tr>
        `;
    }).join("");
}

// THÊM ACCOUNT TRỰC TIẾP TRÊN KHUNG NHANH
async function createAccountInline() {
    const username = document.getElementById("qAccUser").value.trim();
    const password = document.getElementById("qAccPass").value.trim() || "123456";
    const fullName = document.getElementById("qAccFullName").value.trim();
    const email = document.getElementById("qAccEmail").value.trim();
    const phone = document.getElementById("qAccPhone").value.trim();
    const roleId = Number(document.getElementById("qAccRole").value);

    if (!username || !fullName) {
        return alert("Vui lòng nhập đầy đủ Tên đăng nhập (Username) và Họ tên người dùng!");
    }

    await submitCreateAccount({ username, password, fullName, email, phone, roleId }, () => {
        document.getElementById("qAccUser").value = "";
        document.getElementById("qAccPass").value = "123456";
        document.getElementById("qAccFullName").value = "";
        document.getElementById("qAccEmail").value = "";
        document.getElementById("qAccPhone").value = "";
    });
}

// THÊM ACCOUNT QUA MODAL
function openAddAccountModal() {
    document.getElementById("mAccUser").value = "";
    document.getElementById("mAccPass").value = "123456";
    document.getElementById("mAccFullName").value = "";
    document.getElementById("mAccEmail").value = "";
    document.getElementById("mAccPhone").value = "";
    document.getElementById("accountModal").classList.add("show");
}

function closeAccountModal() {
    document.getElementById("accountModal").classList.remove("show");
}

async function saveAccountModal() {
    const username = document.getElementById("mAccUser").value.trim();
    const password = document.getElementById("mAccPass").value.trim() || "123456";
    const fullName = document.getElementById("mAccFullName").value.trim();
    const email = document.getElementById("mAccEmail").value.trim();
    const phone = document.getElementById("mAccPhone").value.trim();
    const roleId = Number(document.getElementById("mAccRole").value);

    if (!username || !fullName) {
        return alert("Vui lòng nhập đầy đủ Tên đăng nhập và Họ tên!");
    }

    await submitCreateAccount({ username, password, fullName, email, phone, roleId }, () => {
        closeAccountModal();
    });
}

async function submitCreateAccount(body, onSuccess) {
    try {
        const res = await fetch(`${API}/accounts`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();
        if (!res.ok) {
            return alert(data.message || "Không thể tạo Account.");
        }
        alert(data.message || "Thêm Account mới và phân quyền thành công!");
        if (onSuccess) onSuccess();
        await loadAccounts();
        notifyDataChanged("accounts");
    } catch (err) {
        alert("Lỗi kết nối máy chủ: " + err.message);
    }
}

// PHÂN QUYỀN CHO ACCOUNT
async function changeAccountRole(accountId) {
    const selectEl = document.getElementById(`roleSelect_${accountId}`);
    if (!selectEl) return;
    const newRoleId = Number(selectEl.value);

    try {
        const res = await fetch(`${API}/accounts/${accountId}/role`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ roleId: newRoleId })
        });
        const data = await res.json();
        if (!res.ok) {
            await loadAccounts();
            return alert(data.message || "Không thể cập nhật phân quyền.");
        }
        alert(data.message || "Đã cập nhật phân quyền cho Account thành công!");
        await loadAccounts();
        notifyDataChanged("accounts");
    } catch (err) {
        alert("Lỗi khi phân quyền: " + err.message);
        await loadAccounts();
    }
}

// KHÓA / MỞ KHÓA ACCOUNT
async function toggleAccountLock(id) {
    try {
        const res = await fetch(`${API}/accounts/${id}/toggle-status`, { method: "PUT" });
        const data = await res.json();
        if (!res.ok) return alert(data.message || "Lỗi cập nhật trạng thái.");
        alert(data.message || "Đã cập nhật trạng thái tài khoản.");
        await loadAccounts();
        notifyDataChanged("accounts");
    } catch (err) {
        alert("Lỗi đổi trạng thái tài khoản: " + err.message);
    }
}

// XÓA ACCOUNT
async function deleteAccount(id) {
    if (!confirm("Xác nhận xóa Account này khỏi hệ thống?")) return;
    try {
        const res = await fetch(`${API}/accounts/${id}`, { method: "DELETE" });
        const data = await res.json();
        if (!res.ok) return alert(data.message || "Không thể xóa Account.");
        alert(data.message || "Đã xóa Account thành công!");
        await loadAccounts();
        notifyDataChanged("accounts");
    } catch (err) {
        alert("Lỗi khi xóa Account: " + err.message);
    }
}

function logout() {
    localStorage.removeItem("currentUser");
    window.location.href = "login.html";
}
