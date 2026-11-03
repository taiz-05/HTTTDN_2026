const CUS_API = "http://localhost:5000/api/customer";
const PROD_API = "http://localhost:5000/api/admin/products";
let currentCus = null;

window.onload = () => {
    currentCus = JSON.parse(localStorage.getItem("currentCustomer") || "null");
    if (!currentCus) {
        window.location.href = "customer_login.html";
        return;
    }
    initCustomerPortal();
};

async function initCustomerPortal() {
    document.getElementById("cusWelcome").innerText = "Khách hàng: " + currentCus.fullName;

    const prof = await (await fetch(`${CUS_API}/profile/${currentCus.accountId}`)).json();
    document.getElementById("pFullName").value = prof.fullName;
    document.getElementById("pPhone").value = prof.phone || "";
    document.getElementById("pAge").value = prof.age;
    document.getElementById("pAddress").value = prof.address || "";
    document.getElementById("pInterest").value = prof.interest || "Gaming";

    await loadProductShowcase();
    await loadCommunityFeedbacks(true);
    await loadMySurveys();
}

async function loadProductShowcase() {
    const prods = await (await fetch(PROD_API)).json();
    document.getElementById("fbProduct").innerHTML = prods.map(p => `<option value="${p.productId}">${p.productName}</option>`).join("");

    document.getElementById("productGallery").innerHTML = prods.map(p => `
        <div class="product-card">
            <img src="${p.imageUrl || 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500'}" alt="${p.productName}" onerror="this.src='https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500'">
            <div class="product-card-body">
                <div>
                    <span class="portal-tag" style="margin-bottom:6px; display:inline-block;">${p.categoryName}</span>
                    <div class="product-card-title">${p.productName}</div>
                    <div class="product-card-price">${Number(p.price).toLocaleString()} đ</div>
                    <div style="font-size:12.5px; color:#f59e0b; font-weight:700; margin-bottom:12px;">
                        ★ ${Number(p.avgRating ?? 5).toFixed(1)} / 5.0 <span style="color:var(--text-muted); font-weight:500;">(${p.reviewCount ?? 0} đánh giá)</span>
                    </div>
                </div>
                <div style="display:flex; gap:8px;">
                    <button class="btn btn-success" style="width:100%;" onclick="selectProductToReview(${p.productId})">✍️ Viết & Xem Đánh giá</button>
                </div>
            </div>
        </div>
    `).join("");
}

function selectProductToReview(productId) {
    document.getElementById("fbProduct").value = productId;
    loadCommunityFeedbacks(false);
    document.getElementById("reviewSectionCard").scrollIntoView({ behavior: "smooth" });
    document.getElementById("fbComment").focus();
}

async function loadCommunityFeedbacks(showAll = false) {
    const prodId = document.getElementById("fbProduct").value;
    const url = showAll ? `${CUS_API}/all-feedbacks` : `${CUS_API}/all-feedbacks?productId=${prodId}`;
    const list = await (await fetch(url)).json();

    document.getElementById("myFeedbackTable").innerHTML = list.map(f => {
        const isMine = f.accountId === currentCus.accountId;
        return `
        <tr style="${isMine ? 'background:#f0fdf4;' : ''}">
            <td><img src="${f.productImage || 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400'}" class="prod-thumb" alt="${f.productName}"></td>
            <td><b>${f.productName}</b></td>
            <td><b>${f.customerName}</b> ${isMine ? '<span class="badge badge-active">(Bạn)</span>' : ''}</td>
            <td style="color:#f59e0b; font-weight:700;">${"⭐".repeat(f.rating)}</td>
            <td>${f.comment}</td>
            <td>${f.adminReply ? `<b style="color:var(--primary);">${f.adminReply}</b>` : "<i>Đang chờ quản lý phản hồi...</i>"}</td>
        </tr>
        `;
    }).join("");
}

async function sendFeedback() {
    const comment = document.getElementById("fbComment").value.trim();
    if (!comment) return alert("Vui lòng nhập nhận xét của bạn về sản phẩm!");

    const body = {
        productId: Number(document.getElementById("fbProduct").value),
        rating: Number(document.getElementById("fbRating").value),
        comment
    };
    await fetch(`${CUS_API}/feedbacks/${currentCus.accountId}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
    });
    document.getElementById("fbComment").value = "";
    await loadProductShowcase();
    await loadCommunityFeedbacks(false);
}

async function loadMySurveys() {
    const list = await (await fetch(`${CUS_API}/surveys/${currentCus.accountId}`)).json();
    document.getElementById("mySurveyTable").innerHTML = list.map(s => {
        let expireLabel = `<span class="badge badge-active">♾️ Không thời hạn</span>`;
        if (s.expiresAt) {
            const d = new Date(s.expiresAt).toLocaleDateString("vi-VN");
            expireLabel = s.isExpired
                ? `<span class="badge badge-locked">⏰ Đã hết hạn (${d})</span>`
                : `<span class="portal-tag">📅 Hạn đến: ${d}</span>`;
        }

        let actionHtml = "";
        if (s.isCompleted) {
            actionHtml = `<span class="badge badge-active">✓ Đã hoàn thành khảo sát</span>`;
        } else if (!s.isActive) {
            actionHtml = `<button class="btn" style="background:#cbd5e1; color:#475569; cursor:not-allowed;" disabled>🔒 Khảo sát đang bị khóa</button>`;
        } else if (s.isExpired) {
            actionHtml = `<button class="btn" style="background:#fee2e2; color:#b91c1c; cursor:not-allowed;" disabled>⏰ Đã hết thời hạn</button>`;
        } else {
            actionHtml = `<button class="btn btn-success" onclick="doSurvey(${s.surveyId})">📝 Thực hiện Khảo sát</button>`;
        }

        return `
        <tr>
            <td><b>${s.title}</b><br><small>${s.description || ""}</small></td>
            <td><b>${s.targetProduct}</b></td>
            <td><b>${Number(s.expectedPrice).toLocaleString()} đ</b></td>
            <td>${expireLabel}</td>
            <td>${actionHtml}</td>
        </tr>
        `;
    }).join("");
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
    const data = await res.json();
    alert(data.message);
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

function logoutCustomer() {
    localStorage.removeItem("currentCustomer");
    window.location.href = "customer_login.html";
}