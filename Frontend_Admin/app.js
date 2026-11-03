const API = "http://localhost:5000/api/admin";
let rolesList = [];
let currentUser = null;
let ratingChartInstance = null;
let productChartInstance = null;

window.onload = async () => {
    currentUser = JSON.parse(localStorage.getItem("currentUser") || "null");
    if (!currentUser || currentUser.roleName !== "Admin") return window.location.href = "login.html";
    document.getElementById("adminName").innerText = currentUser.fullName + " (" + currentUser.username + ")";

    await loadCategoriesAndSuppliers();
    await loadRoles();
    await loadProducts();
    await loadSuppliers();
    await loadAccounts();
    await loadReviewAnalytics();
};

function switchTab(id, btn) {
    document.querySelectorAll(".tab-content").forEach(el => el.style.display = "none");
    document.querySelectorAll(".sherah-nav-item").forEach(el => el.classList.remove("active"));
    document.getElementById(id).style.display = "block";
    btn.classList.add("active");
}

function quickSearch(val) {
    const kwInput = document.getElementById("fKeyword");
    if (kwInput) {
        kwInput.value = val;
        loadProducts();
    }
}

async function loadReviewAnalytics() {
    const feedbacks = await (await fetch(`${API}/crm/feedbacks`)).json();
    document.getElementById("kpiReviews").innerText = feedbacks.length;

    const avg = feedbacks.length > 0
        ? (feedbacks.reduce((sum, f) => sum + f.rating, 0) / feedbacks.length).toFixed(1)
        : "5.0";
    document.getElementById("kpiAvgStar").innerText = `★ ${avg} / 5.0 Điểm TB`;

    const starCounts = [1, 2, 3, 4, 5].map(star => feedbacks.filter(f => f.rating === star).length);

    const ctxBar = document.getElementById("ratingBarChart").getContext("2d");
    if (ratingChartInstance) ratingChartInstance.destroy();
    ratingChartInstance = new Chart(ctxBar, {
        type: "bar",
        data: {
            labels: ["1 Sao ★", "2 Sao ★★", "3 Sao ★★★", "4 Sao ★★★★", "5 Sao ★★★★★"],
            datasets: [{
                label: "Số lượng đánh giá",
                data: starCounts,
                backgroundColor: ["#ef4444", "#f97316", "#eab308", "#1e3a8a", "#65a30d"],
                borderRadius: 8,
                barThickness: 36
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, ticks: { stepSize: 1 } }
            }
        }
    });

    const prodMap = {};
    feedbacks.forEach(f => {
        const name = f.productName || "Sản phẩm khác";
        prodMap[name] = (prodMap[name] || 0) + 1;
    });

    const ctxPie = document.getElementById("productReviewChart").getContext("2d");
    if (productChartInstance) productChartInstance.destroy();
    productChartInstance = new Chart(ctxPie, {
        type: "doughnut",
        data: {
            labels: Object.keys(prodMap),
            datasets: [{
                data: Object.values(prodMap),
                backgroundColor: ["#1e3a8a", "#65a30d", "#0ea5e9", "#f59e0b", "#6366f1", "#ec4899"],
                borderWidth: 2
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: "bottom" }
            }
        }
    });

    document.getElementById("recentReviewsTable").innerHTML = feedbacks.slice(0, 6).map(f => `
        <tr>
            <td><b>${f.customerName}</b></td>
            <td>${f.productName}</td>
            <td style="color:#f59e0b; font-weight:700;">${"★".repeat(f.rating)} (${f.rating}/5)</td>
            <td>${f.comment}</td>
            <td><span class="badge ${f.status.includes('Đã') ? 'badge-active' : 'badge-locked'}">${f.status}</span></td>
        </tr>
    `).join("");
}

async function loadCategoriesAndSuppliers() {
    const cats = await (await fetch(`${API}/categories`)).json();
    const sups = await (await fetch(`${API}/suppliers`)).json();

    const fCat = document.getElementById("fCategory"), pCat = document.getElementById("pCat");
    fCat.innerHTML = `<option value="">-- Tất cả Danh mục --</option>`;
    pCat.innerHTML = "";
    cats.forEach(c => {
        fCat.innerHTML += `<option value="${c.categoryId}">${c.categoryName}</option>`;
        pCat.innerHTML += `<option value="${c.categoryId}">${c.categoryName}</option>`;
    });

    const fSup = document.getElementById("fSupplier"), pSup = document.getElementById("pSup");
    fSup.innerHTML = `<option value="">-- Tất cả Nhà cung cấp --</option>`;
    pSup.innerHTML = "";
    sups.forEach(s => {
        fSup.innerHTML += `<option value="${s.supplierId}">${s.supplierName}</option>`;
        pSup.innerHTML += `<option value="${s.supplierId}">${s.supplierName}</option>`;
    });
}

async function loadProducts() {
    const params = new URLSearchParams({
        keyword: document.getElementById("fKeyword").value,
        categoryId: document.getElementById("fCategory").value,
        supplierId: document.getElementById("fSupplier").value,
        minPrice: document.getElementById("fMinPrice").value,
        maxPrice: document.getElementById("fMaxPrice").value,
        sortBy: document.getElementById("fSort").value
    });
    const list = await (await fetch(`${API}/products?${params}`)).json();
    document.getElementById("kpiProducts").innerText = list.length;

    document.getElementById("productTable").innerHTML = list.map(p => `
        <tr>
            <td><img src="${p.imageUrl || 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400'}" class="prod-thumb" alt="${p.productName}" onerror="this.src='https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400'"></td>
            <td><b style="color:var(--primary);">#${p.productCode}</b></td>
            <td><b>${p.productName}</b></td>
            <td>${p.categoryName}</td>
            <td>${p.supplierName}</td>
            <td><b>${Number(p.price).toLocaleString()} đ</b></td>
            <td>${p.stockQuantity}</td>
            <td style="color:#f59e0b; font-weight:700;">★ ${Number(p.avgRating ?? 5).toFixed(1)} (${p.reviewCount ?? 0})</td>
            <td><button class="btn btn-danger" onclick="deleteProduct(${p.productId})">🗑️ Xóa</button></td>
        </tr>
    `).join("");
}

async function createProduct() {
    const body = {
        productCode: document.getElementById("pCode").value,
        productName: document.getElementById("pName").value,
        categoryId: Number(document.getElementById("pCat").value),
        supplierId: Number(document.getElementById("pSup").value),
        price: Number(document.getElementById("pPrice").value),
        costPrice: Number(document.getElementById("pPrice").value) * 0.8,
        stockQuantity: Number(document.getElementById("pStock").value),
        unit: "Cái",
        status: "Đang bán",
        imageUrl: document.getElementById("pImage") ? document.getElementById("pImage").value : ""
    };
    await fetch(`${API}/products`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
    document.getElementById("pCode").value = "";
    document.getElementById("pName").value = "";
    document.getElementById("pPrice").value = "";
    document.getElementById("pStock").value = "";
    if (document.getElementById("pImage")) document.getElementById("pImage").value = "";
    loadProducts();
}

async function deleteProduct(id) {
    if (!confirm("Xóa sản phẩm này?")) return;
    await fetch(`${API}/products/${id}`, { method: "DELETE" });
    loadProducts();
}

async function loadSuppliers() {
    const list = await (await fetch(`${API}/suppliers`)).json();
    document.getElementById("kpiSuppliers").innerText = list.length;

    document.getElementById("supplierTable").innerHTML = list.map(s => `
        <tr>
            <td><b style="color:var(--primary);">#${s.supplierCode}</b></td>
            <td><b>${s.supplierName}</b></td>
            <td>${s.phone || ""}</td>
            <td>${s.address || ""}</td>
            <td><button class="btn btn-danger" onclick="deleteSupplier(${s.supplierId})">🗑️ Xóa</button></td>
        </tr>
    `).join("");
}

async function createSupplier() {
    const body = {
        supplierCode: document.getElementById("sCode").value,
        supplierName: document.getElementById("sName").value,
        phone: document.getElementById("sPhone").value,
        address: document.getElementById("sAddress").value
    };
    await fetch(`${API}/suppliers`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
    loadSuppliers();
}

async function deleteSupplier(id) {
    await fetch(`${API}/suppliers/${id}`, { method: "DELETE" });
    loadSuppliers();
}

async function loadRoles() {
    rolesList = await (await fetch(`${API}/accounts/roles`)).json();
    document.getElementById("aRole").innerHTML = rolesList.map(r => `<option value="${r.roleId}">${r.roleName}</option>`).join("");
}

async function loadAccounts() {
    const list = await (await fetch(`${API}/accounts`)).json();
    document.getElementById("kpiAccounts").innerText = list.length;

    document.getElementById("accountTable").innerHTML = list.map(a => {
        const isSelf = currentUser && a.accountId === currentUser.accountId;
        const isOtherAdmin = a.roleName === "Admin" && !isSelf;

        let deleteBtnHtml = "";
        if (isOtherAdmin) {
            deleteBtnHtml = `<button class="btn" style="background:#cbd5e1; color:#475569; cursor:not-allowed;" disabled>🔒 Không thể xóa</button>`;
        } else if (isSelf) {
            deleteBtnHtml = `<button class="btn btn-danger" onclick="deleteAccount(${a.accountId}, true)">⚠️ Tự xóa TK</button>`;
        } else {
            deleteBtnHtml = `<button class="btn btn-danger" onclick="deleteAccount(${a.accountId}, false)">🗑️ Xóa</button>`;
        }

        return `
        <tr style="${isSelf ? 'background:#f0fdf4;' : ''}">
            <td>#${a.accountId}</td>
            <td><b>${a.username}</b> ${isSelf ? '<span class="badge badge-active">(Bạn)</span>' : ''}</td>
            <td>${a.fullName}</td>
            <td>${a.email || ""}</td>
            <td>
                <select onchange="changeRole(${a.accountId}, this.value)" ${isOtherAdmin ? "disabled" : ""}>
                    ${rolesList.map(r => `<option value="${r.roleId}" ${r.roleId === a.roleId ? "selected" : ""}>${r.roleName}</option>`).join("")}
                </select>
            </td>
            <td>${deleteBtnHtml}</td>
        </tr>
        `;
    }).join("");
}

async function createAccount() {
    const body = {
        username: document.getElementById("aUser").value,
        fullName: document.getElementById("aName").value,
        email: document.getElementById("aEmail").value,
        roleId: Number(document.getElementById("aRole").value)
    };
    const res = await fetch(`${API}/accounts`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
    const data = await res.json();
    if (!res.ok) return alert(data.message || "Lỗi tạo tài khoản!");
    loadAccounts();
}

async function changeRole(accountId, roleId) {
    const res = await fetch(`${API}/accounts/${accountId}/role?currentUserId=${currentUser.accountId}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ roleId: Number(roleId) })
    });
    const data = await res.json();
    alert(data.message);
    loadAccounts();
}

async function deleteAccount(id, isSelf) {
    const msg = isSelf
        ? "CẢNH BÁO: Bạn đang tự xóa tài khoản Admin của chính mình! Sau khi xóa bạn sẽ bị đăng xuất ngay lập tức. Tiếp tục?"
        : "Bạn có chắc chắn muốn xóa tài khoản này?";

    if (!confirm(msg)) return;

    const res = await fetch(`${API}/accounts/${id}?currentUserId=${currentUser.accountId}`, {
        method: "DELETE"
    });
    const data = await res.json();

    if (!res.ok) {
        alert(data.message || "Không thể xóa tài khoản!");
        return;
    }

    alert(data.message);
    if (isSelf) {
        logout();
    } else {
        loadAccounts();
    }
}

function logout() {
    localStorage.removeItem("currentUser");
    window.location.href = "login.html";
}