const API = "http://localhost:5000/api/admin";

let rolesList = [];
let allAccountsCache = [];
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
        window.location.href = "login.html";
        return;
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
        "Customer": "Customer (Khách hàng)",
        "HR": "HR (Quản lý nhân sự)",
        "Warehouse": "Warehouse (Quản lý kho)",
        "Sales": "Sales (Quản lý bán hàng)"
    };
    return map[roleName] || roleName;
}

function getRolePortalName(roleName) {
    const map = {
        "Admin": "Giao diện Admin Server (admin.html)",
        "Manager": "Giao diện Người quản lý CRM (manager_crm.html)",
        "Customer": "Giao diện Khách hàng (user.html)",
        "HR": "Phân hệ Quản lý Nhân sự (Tách biệt)",
        "Warehouse": "Phân hệ Quản lý Kho (Tách biệt)",
        "Sales": "Phân hệ Quản lý Bán hàng (Tách biệt)"
    };
    return map[roleName] || "Giao diện tách biệt theo phân hệ";
}

// =========================================================
// 1. NẠP DANH SÁCH ROLES & HIỂN THỊ BẢNG PHÂN QUYỀN
// =========================================================
async function loadRoles() {
    try {
        const res = await fetch(`${API}/accounts/roles`);
        if (!res.ok) return;
        rolesList = await res.json();

        const optionsHtml = rolesList
            .map(r => `<option value="${r.roleId}">${getRoleVietnameseLabel(r.roleName)}</option>`)
            .join("");

        const mRole = document.getElementById("mAccRole");
        if (mRole) mRole.innerHTML = optionsHtml;

        const qRole = document.getElementById("qAccRole");
        if (qRole) qRole.innerHTML = optionsHtml;
    } catch (e) {
        console.error("Lỗi loadRoles:", e);
    }
}

// =========================================================
// 2. NẠP DANH SÁCH ACCOUNT, THÊM, XÓA, PHÂN QUYỀN ACCOUNT
// =========================================================
async function loadAccounts() {
    try {
        const res = await fetch(`${API}/accounts`);
        if (!res.ok) return;
        allAccountsCache = await res.json();

        // Cập nhật 4 thẻ KPI
        const total = allAccountsCache.length;
        const activeCount = allAccountsCache.filter(a => a.isActive).length;
        const adminCount = allAccountsCache.filter(a => a.roleName === "Admin").length;
        const managerCount = allAccountsCache.filter(a => ["Manager", "HR", "Warehouse", "Sales"].includes(a.roleName)).length;
        const customerCount = allAccountsCache.filter(a => a.roleName === "Customer").length;

        if (document.getElementById("kpiTotalAccounts")) document.getElementById("kpiTotalAccounts").innerText = total;
        if (document.getElementById("kpiActiveSub")) document.getElementById("kpiActiveSub").innerText = `${activeCount} Hoạt động · ${total - activeCount} Đã khóa`;
        if (document.getElementById("kpiAdminCount")) document.getElementById("kpiAdminCount").innerText = adminCount;
        if (document.getElementById("kpiManagerCount")) document.getElementById("kpiManagerCount").innerText = managerCount;
        if (document.getElementById("kpiCustomerCount")) document.getElementById("kpiCustomerCount").innerText = customerCount;

        renderFilteredAccounts();
        renderRoleSummaryTable();
    } catch (e) {
        console.error("Lỗi loadAccounts:", e);
    }
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
        if (currentAccountRoleFilter === "Other" && !["HR", "Warehouse", "Sales"].includes(a.roleName)) return false;

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
        } else if (a.roleName === "Customer") {
            roleBadge = `<span class="badge badge-customer"><span class="status-dot orange"></span> Khách hàng</span>`;
        } else {
            roleBadge = `<span class="badge badge-info"><span class="status-dot blue"></span> ${a.roleName}</span>`;
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
