const API = "http://localhost:5000/api/admin";
let rolesList = [];

window.onload = async () => {
    const user = JSON.parse(localStorage.getItem("currentUser") || "null");
    if (!user || user.roleName !== "Admin") return window.location.href = "login.html";
    document.getElementById("adminName").innerText = "Xin chào, " + user.fullName;

    await loadCategoriesAndSuppliers();
    await loadRoles();
    await loadProducts();
    await loadSuppliers();
    await loadAccounts();
};

function switchTab(id, btn) {
    document.querySelectorAll(".tab-content").forEach(el => el.style.display = "none");
    document.querySelectorAll(".tab-btn").forEach(el => el.classList.remove("active"));
    document.getElementById(id).style.display = "block";
    btn.classList.add("active");
}

async function loadCategoriesAndSuppliers() {
    const cats = await (await fetch(`${API}/categories`)).json();
    const sups = await (await fetch(`${API}/suppliers`)).json();

    const fCat = document.getElementById("fCategory"), pCat = document.getElementById("pCat");
    cats.forEach(c => {
        fCat.innerHTML += `<option value="${c.categoryId}">${c.categoryName}</option>`;
        pCat.innerHTML += `<option value="${c.categoryId}">${c.categoryName}</option>`;
    });

    const fSup = document.getElementById("fSupplier"), pSup = document.getElementById("pSup");
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
    document.getElementById("productTable").innerHTML = list.map(p => `
        <tr>
            <td>${p.productCode}</td>
            <td><b>${p.productName}</b></td>
            <td>${p.categoryName}</td>
            <td>${p.supplierName}</td>
            <td>${Number(p.price).toLocaleString()} đ</td>
            <td>${p.stockQuantity}</td>
            <td>${p.status}</td>
            <td><button class="btn btn-danger" onclick="deleteProduct(${p.productId})">Xóa</button></td>
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
        status: "Đang bán"
    };
    await fetch(`${API}/products`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
    loadProducts();
}

async function deleteProduct(id) {
    if (!confirm("Xóa sản phẩm này?")) return;
    await fetch(`${API}/products/${id}`, { method: "DELETE" });
    loadProducts();
}

async function loadSuppliers() {
    const list = await (await fetch(`${API}/suppliers`)).json();
    document.getElementById("supplierTable").innerHTML = list.map(s => `
        <tr>
            <td>${s.supplierCode}</td>
            <td>${s.supplierName}</td>
            <td>${s.phone || ""}</td>
            <td>${s.address || ""}</td>
            <td><button class="btn btn-danger" onclick="deleteSupplier(${s.supplierId})">Xóa</button></td>
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
    document.getElementById("accountTable").innerHTML = list.map(a => `
        <tr>
            <td>${a.accountId}</td>
            <td><b>${a.username}</b></td>
            <td>${a.fullName}</td>
            <td>${a.email || ""}</td>
            <td>
                <select onchange="changeRole(${a.accountId}, this.value)">
                    ${rolesList.map(r => `<option value="${r.roleId}" ${r.roleId === a.roleId ? "selected" : ""}>${r.roleName}</option>`).join("")}
                </select>
            </td>
            <td><button class="btn btn-danger" onclick="deleteAccount(${a.accountId})">Xóa</button></td>
        </tr>
    `).join("");
}

async function createAccount() {
    const body = {
        username: document.getElementById("aUser").value,
        fullName: document.getElementById("aName").value,
        email: document.getElementById("aEmail").value,
        roleId: Number(document.getElementById("aRole").value)
    };
    await fetch(`${API}/accounts`, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
    loadAccounts();
}

async function changeRole(accountId, roleId) {
    await fetch(`${API}/accounts/${accountId}/role`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ roleId: Number(roleId) })
    });
    alert("Đã cập nhật quyền thành công!");
}

async function deleteAccount(id) {
    if (!confirm("Xóa tài khoản này?")) return;
    await fetch(`${API}/accounts/${id}`, { method: "DELETE" });
    loadAccounts();
}

function logout() {
    localStorage.removeItem("currentUser");
    window.location.href = "login.html";
}