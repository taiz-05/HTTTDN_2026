const CUS_API = "http://localhost:5000/api/customer";
const PROD_API = "http://localhost:5000/api/admin/products";
let currentCus = null;

window.onload = () => {
    currentCus = JSON.parse(localStorage.getItem("currentCustomer") || "null");
    if (currentCus) showPortal();
};

async function loginCustomer() {
    const username = document.getElementById("lUser").value.trim();
    const password = document.getElementById("lPass").value.trim();
    const res = await fetch(`${CUS_API}/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password })
    });
    const data = await res.json();
    if (!res.ok) return alert(data.message);
    localStorage.setItem("currentCustomer", JSON.stringify(data));
    currentCus = data;
    showPortal();
}

async function registerCustomer() {
    const body = {
        username: document.getElementById("rUser").value.trim(),
        password: document.getElementById("rPass").value.trim(),
        fullName: document.getElementById("rName").value.trim(),
        phone: document.getElementById("rPhone").value.trim(),
        age: Number(document.getElementById("rAge").value || 20),
        interest: document.getElementById("rInterest").value
    };
    const res = await fetch(`${CUS_API}/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });
    const data = await res.json();
    alert(data.message);
}

async function showPortal() {
    document.getElementById("authSection").style.display = "none";
    document.getElementById("portalSection").style.display = "block";
    document.getElementById("userHeaderBox").style.display = "block";
    document.getElementById("cusWelcome").innerText = "Khách hàng: " + currentCus.fullName;

    const prof = await (await fetch(`${CUS_API}/profile/${currentCus.accountId}`)).json();
    document.getElementById("pFullName").value = prof.fullName;
    document.getElementById("pPhone").value = prof.phone || "";
    document.getElementById("pAge").value = prof.age;
    document.getElementById("pAddress").value = prof.address || "";
    document.getElementById("pInterest").value = prof.interest || "Gaming";

    const prods = await (await fetch(PROD_API)).json();
    document.getElementById("fbProduct").innerHTML = prods.map(p => `<option value="${p.productId}">${p.productName}</option>`).join("");

    loadMyFeedbacks();
    loadMySurveys();
}

async function updateProfile() {
    const body = {
        fullName: document.getElementById("pFullName").value,
        phone: document.getElementById("pPhone").value,
        age: Number(document.getElementById("pAge").value),
        address: document.getElementById("pAddress").value,
        interest: document.getElementById("pInterest").value
    };
    const res = await fetch(`${CUS_API}/profile/${currentCus.accountId}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });
    alert((await res.json()).message);
}

async function loadMyFeedbacks() {
    const list = await (await fetch(`${CUS_API}/feedbacks/${currentCus.accountId}`)).json();
    document.getElementById("myFeedbackTable").innerHTML = list.map(f => `
        <tr>
            <td><b>${f.productName}</b></td>
            <td>${"⭐".repeat(f.rating)}</td>
            <td>${f.comment}</td>
            <td>${f.adminReply || "<i>Đang chờ quản lý phản hồi...</i>"}</td>
            <td>${f.status}</td>
        </tr>
    `).join("");
}

async function sendFeedback() {
    const body = {
        productId: Number(document.getElementById("fbProduct").value),
        rating: Number(document.getElementById("fbRating").value),
        comment: document.getElementById("fbComment").value
    };
    await fetch(`${CUS_API}/feedbacks/${currentCus.accountId}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });
    document.getElementById("fbComment").value = "";
    loadMyFeedbacks();
}

async function loadMySurveys() {
    const list = await (await fetch(`${CUS_API}/surveys/${currentCus.accountId}`)).json();
    document.getElementById("mySurveyTable").innerHTML = list.map(s => `
        <tr>
            <td><b>${s.title}</b><br><small>${s.description || ""}</small></td>
            <td>${s.targetProduct}</td>
            <td>${Number(s.expectedPrice).toLocaleString()} đ</td>
            <td>
                ${s.isCompleted
                    ? '<span class="badge badge-active">Đã hoàn thành khảo sát</span>'
                    : `<button class="btn" onclick="doSurvey(${s.surveyId})">Thực hiện Khảo sát</button>`}
            </td>
        </tr>
    `).join("");
}

async function doSurvey(surveyId) {
    const score = Number(prompt("Bạn chấm sản phẩm mới này mấy sao (1 - 5)?", "5"));
    if (!score || score < 1 || score > 5) return;
    const intent = prompt("Ý định mua của bạn? (Nhập 1: Rất muốn mua | 2: Đang cân nhắc | 3: Không mua)", "1");
    const buyingIntent = intent === "1" ? "Rất muốn mua" : (intent === "2" ? "Đang cân nhắc" : "Không mua");
    const opinion = prompt("Ý kiến đóng góp của bạn về mức giá dự kiến & tính năng:", "Mức giá hợp lý, tính năng tốt.");

    const res = await fetch(`${CUS_API}/surveys/${surveyId}/submit/${currentCus.accountId}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ score, buyingIntent, customerOpinion: opinion })
    });
    alert((await res.json()).message);
    loadMySurveys();
}

function logoutCustomer() {
    localStorage.removeItem("currentCustomer");
    window.location.reload();
}