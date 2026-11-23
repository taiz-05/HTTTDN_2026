const CUS_API = "http://localhost:5000/api/customer";
const PROD_API = "http://localhost:5000/api/admin/products";
const DEFAULT_IMG = "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500";

let currentCus = null;
let allProductsCache = [];
let allSurveysCache = [];
let allFeedbacksCache = [];
let selectedCategoryFilter = "";
let selectedModalProductId = null;
let selectedModalStar = 5;
let selectedModalSurveyId = null;

const syncChannel = new BroadcastChannel("htttdn_realtime_sync");

function notifyDataChanged(scope) {
    const payload = { scope, timestamp: Date.now() };
    syncChannel.postMessage(payload);
    localStorage.setItem("htttdn_sync_event", JSON.stringify(payload));
}

syncChannel.onmessage = () => refreshCustomerDataSilently();
window.addEventListener("storage", (e) => {
    if (e.key === "htttdn_sync_event") refreshCustomerDataSilently();
});
window.addEventListener("focus", () => refreshCustomerDataSilently());

function getInitials(fullName) {
    if (!fullName) return "KH";
    const parts = fullName.trim().split(" ");
    if (parts.length === 1) return parts[0].substring(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
}

window.onload = async () => {
    currentCus = JSON.parse(localStorage.getItem("currentCustomer") || "null");
    if (!currentCus) {
        currentCus = {
            accountId: 5,
            username: "khachhang1",
            fullName: "Nguyễn Văn An",
            email: "an.nguyen@gmail.com",
            roleName: "Customer"
        };
        localStorage.setItem("currentCustomer", JSON.stringify(currentCus));
    }
    await initCustomerPortal();

    const params = new URLSearchParams(window.location.search);
    const tabParam = params.get("tab");
    if (tabParam) {
        const navBtn = document.querySelector(`button[onclick*="${tabParam}"]`);
        switchCustomerTab(tabParam, navBtn);
    }
};

function switchCustomerTab(sectionId, btn) {
    document.querySelectorAll(".cus-section").forEach(sec => sec.style.display = "none");
    document.querySelectorAll(".cus-nav-btn").forEach(b => b.classList.remove("active"));
    const target = document.getElementById(sectionId);
    if (target) {
        target.style.display = "block";
        target.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
    if (btn) btn.classList.add("active");

    if (sectionId === "secSurveys") {
        setTimeout(loadMySurveys, 30);
    } else if (sectionId === "secFeedback") {
        setTimeout(() => loadCommunityFeedbacks(false), 30);
    } else if (sectionId === "secProfile") {
        setTimeout(refreshProfileData, 30);
    }
}

async function refreshProfileData() {
    if (!currentCus) return;
    try {
        const prof = await (await fetch(`${CUS_API}/profile/${currentCus.accountId}`)).json();
        if (document.getElementById("pFullName")) document.getElementById("pFullName").value = prof.fullName || currentCus.fullName;
        if (document.getElementById("pEmailDisplay") && prof.email) document.getElementById("pEmailDisplay").value = prof.email;
        if (document.getElementById("pPhone")) document.getElementById("pPhone").value = prof.phone || "";
        if (document.getElementById("pAge")) document.getElementById("pAge").value = prof.age || 20;
        if (document.getElementById("pGender")) document.getElementById("pGender").value = prof.gender || "Nam";
        if (document.getElementById("pAddress")) document.getElementById("pAddress").value = prof.address || "";
        if (document.getElementById("pInterest")) document.getElementById("pInterest").value = prof.interest || "Gaming";
        if (document.getElementById("profCardInterestTag")) document.getElementById("profCardInterestTag").innerText = prof.interest || "Gaming";
        if (document.getElementById("profCardAgeTag")) document.getElementById("profCardAgeTag").innerText = (prof.age || 20) + " tuổi";
    } catch (e) {
        console.error("Lỗi refreshProfileData:", e);
    }
}

async function initCustomerPortal() {
    const initials = getInitials(currentCus.fullName);
    if (document.getElementById("cusAvatarTop")) document.getElementById("cusAvatarTop").innerText = initials;
    if (document.getElementById("profAvatarBig")) document.getElementById("profAvatarBig").innerText = initials;
    if (document.getElementById("cusWelcome")) document.getElementById("cusWelcome").innerText = currentCus.fullName;
    if (document.getElementById("profCardFullName")) document.getElementById("profCardFullName").innerText = currentCus.fullName;
    if (document.getElementById("profCardUsername")) document.getElementById("profCardUsername").innerText = "@" + currentCus.username;
    if (document.getElementById("pUsernameDisplay")) document.getElementById("pUsernameDisplay").value = currentCus.username;
    if (document.getElementById("pEmailDisplay")) document.getElementById("pEmailDisplay").value = currentCus.email || (currentCus.username + "@gmail.com");

    try {
        const prof = await (await fetch(`${CUS_API}/profile/${currentCus.accountId}?username=${encodeURIComponent(currentCus.username || "")}`)).json();
        if (prof && prof.accountId) {
            currentCus.accountId = prof.accountId;
            if (prof.username) currentCus.username = prof.username;
            if (prof.fullName) currentCus.fullName = prof.fullName;
            localStorage.setItem("currentCustomer", JSON.stringify(currentCus));
        }
        if (document.getElementById("pFullName")) document.getElementById("pFullName").value = prof.fullName || currentCus.fullName;
        if (document.getElementById("pEmailDisplay") && prof.email) document.getElementById("pEmailDisplay").value = prof.email;
        if (document.getElementById("pPhone")) document.getElementById("pPhone").value = prof.phone || "";
        if (document.getElementById("pAge")) document.getElementById("pAge").value = prof.age || 20;
        if (document.getElementById("pGender")) document.getElementById("pGender").value = prof.gender || "Nam";
        if (document.getElementById("pAddress")) document.getElementById("pAddress").value = prof.address || "";
        if (document.getElementById("pInterest")) document.getElementById("pInterest").value = prof.interest || "Gaming";
        if (document.getElementById("profCardInterestTag")) document.getElementById("profCardInterestTag").innerText = prof.interest || "Gaming";
        if (document.getElementById("profCardAgeTag")) document.getElementById("profCardAgeTag").innerText = (prof.age || 20) + " tuổi";
    } catch (e) {
        console.error("Lỗi nạp hồ sơ khách hàng:", e);
    }

    await refreshCustomerDataSilently();
}

async function refreshCustomerDataSilently() {
    if (!currentCus) return;
    try {
        await Promise.all([
            loadProductShowcase(),
            loadCommunityFeedbacks(false),
            loadMySurveys()
        ]);

        const myFeedbacks = allFeedbacksCache.filter(f => f.accountId === currentCus.accountId);
        if (document.getElementById("profStatReviews")) {
            document.getElementById("profStatReviews").innerText = myFeedbacks.length;
        }

        const myCompletedSurveys = allSurveysCache.filter(s => s.isCompleted);
        if (document.getElementById("profStatSurveys")) {
            document.getElementById("profStatSurveys").innerText = myCompletedSurveys.length;
        }

        if (document.getElementById("reviewModal")?.classList.contains("show") && selectedModalProductId) {
            await loadModalProductReviews(selectedModalProductId);
        }
    } catch (err) {
        console.error("Lỗi refreshCustomerDataSilently:", err);
    }
}

// =========================================================
// 1. GỬI PHẢN HỒI VỀ SẢN PHẨM & DANH MỤC SẢN PHẨM
// =========================================================
async function loadProductShowcase() {
    try {
        allProductsCache = await (await fetch(PROD_API)).json();

        const filterSelect = document.getElementById("filterReviewProduct");
        if (filterSelect) {
            const currentSelected = filterSelect.value;
            filterSelect.innerHTML = `<option value="">Tất cả sản phẩm</option>` +
                allProductsCache.map(p => `<option value="${p.productId}">${p.productName}</option>`).join("");
            filterSelect.value = currentSelected;
        }

        const directSelect = document.getElementById("directFbProduct");
        if (directSelect) {
            const curVal = directSelect.value;
            directSelect.innerHTML = allProductsCache.map(p =>
                `<option value="${p.productId}">${p.productName} (${Number(p.price).toLocaleString("vi-VN")} ₫)</option>`
            ).join("");
            if (curVal) directSelect.value = curVal;
        }

        filterShowcaseProducts();
    } catch (e) {
        console.error("Lỗi loadProductShowcase:", e);
    }
}

async function submitDirectFeedback() {
    const productId = Number(document.getElementById("directFbProduct")?.value || 0);
    const rating = Number(document.getElementById("directFbRating")?.value || 5);
    const comment = (document.getElementById("directFbComment")?.value || "").trim();

    if (!productId) return alert("Vui lòng chọn sản phẩm cần phản hồi!");
    if (!comment) return alert("Vui lòng nhập nội dung phản hồi về sản phẩm!");

    try {
        const res = await fetch(`${CUS_API}/feedbacks/${currentCus.accountId}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ productId, rating, comment })
        });
        const data = await res.json();
        if (!res.ok) return alert(data.message || "Lỗi gửi phản hồi.");

        alert(data.message || "Đã gửi phản hồi về sản phẩm thành công!");
        document.getElementById("directFbComment").value = "";
        await refreshCustomerDataSilently();
        notifyDataChanged("feedbacks");
    } catch (err) {
        alert("Lỗi kết nối khi gửi phản hồi: " + err.message);
    }
}

function filterByCategory(catKeyword, btn) {
    selectedCategoryFilter = catKeyword;
    document.querySelectorAll(".cat-pill-btn").forEach(b => b.classList.remove("active"));
    if (btn) btn.classList.add("active");
    filterShowcaseProducts();
}

function filterShowcaseProducts() {
    const kw = (document.getElementById("cusSearchInput")?.value || "").trim().toLowerCase();
    const filtered = allProductsCache.filter(p => {
        if (selectedCategoryFilter) {
            const catName = (p.categoryName || "").toLowerCase();
            if (!catName.includes(selectedCategoryFilter.toLowerCase())) return false;
        }
        if (kw) {
            const nameMatch = p.productName.toLowerCase().includes(kw);
            const catMatch = p.categoryName && p.categoryName.toLowerCase().includes(kw);
            if (!nameMatch && !catMatch) return false;
        }
        return true;
    });
    renderProductCards(filtered);
}

function renderProductCards(list) {
    const gallery = document.getElementById("productGallery");
    if (!gallery) return;

    if (list.length === 0) {
        gallery.innerHTML = `
            <div style="grid-column: 1/-1; text-align:center; padding:40px; background:#ffffff; border:1px solid var(--brand-border); border-radius:var(--radius-lg); color:var(--text-muted);">
                <div style="font-weight:700; font-size:15px; color:var(--text-primary);">Không tìm thấy sản phẩm phù hợp</div>
                <div style="font-size:13px; margin-top:4px;">Vui lòng thử chọn danh mục khác hoặc nhập từ khóa tìm kiếm mới.</div>
            </div>
        `;
        return;
    }

    gallery.innerHTML = list.map(p => {
        let stockBadge = "";
        if (p.stockQuantity === 0) {
            stockBadge = `<span class="badge badge-stock-out">Hết hàng</span>`;
        } else if (p.stockQuantity < 10) {
            stockBadge = `<span class="badge badge-stock-low">Sắp hết (${p.stockQuantity})</span>`;
        } else {
            stockBadge = `<span class="badge badge-stock-high">Còn hàng</span>`;
        }

        return `
        <div class="product-card">
            <img src="${p.imageUrl || DEFAULT_IMG}" alt="${p.productName}" onerror="this.src='${DEFAULT_IMG}'">
            <div class="product-card-body">
                <div>
                    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
                        <span class="badge badge-info">${p.categoryName || 'Sản phẩm'}</span>
                        ${stockBadge}
                    </div>
                    <div class="product-card-title">${p.ProductName || p.productName}</div>
                    <div class="product-card-price">${Number(p.price).toLocaleString("vi-VN")} ₫</div>
                    <div style="display:flex; align-items:center; gap:5px; margin-bottom:14px;">
                        <span class="star-rating-box">
                            <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                            <span>${Number(p.avgRating ?? p.averageRating ?? 5).toFixed(1)} / 5</span>
                        </span>
                        <span style="font-size:11.5px; color:var(--text-muted);">(${p.reviewCount ?? p.totalReviews ?? 0} phản hồi)</span>
                    </div>
                </div>
                <button class="btn btn-primary" style="width:100%; padding:9px; font-size:13px; display:inline-flex; align-items:center; justify-content:center; gap:6px;" onclick="openReviewModal(${p.productId})">
                    <span>Gửi phản hồi về sản phẩm</span>
                </button>
            </div>
        </div>
        `;
    }).join("");
}

async function openReviewModal(productId) {
    const prod = allProductsCache.find(p => p.productId === productId) || allProductsCache[0];
    if (!prod) return;

    selectedModalProductId = prod.productId;
    document.getElementById("modalProdImg").src = prod.imageUrl || DEFAULT_IMG;
    document.getElementById("modalProdCat").innerText = prod.categoryName || "Sản phẩm";
    document.getElementById("modalProdName").innerText = prod.ProductName || prod.productName;
    document.getElementById("modalProdPrice").innerText = Number(prod.price).toLocaleString("vi-VN") + " ₫";
    document.getElementById("modalFbComment").value = "";

    selectStar(5);
    document.getElementById("reviewModal").classList.add("show");

    await loadModalProductReviews(prod.productId);
}

function closeReviewModal() {
    document.getElementById("reviewModal").classList.remove("show");
}

function selectStar(star) {
    selectedModalStar = star;
    const labels = {
        5: "5/5 - Rất hài lòng",
        4: "4/5 - Hài lòng",
        3: "3/5 - Bình thường",
        2: "2/5 - Chưa tốt",
        1: "1/5 - Không hài lòng"
    };
    document.getElementById("starTextLabel").innerText = labels[star];

    const stars = document.querySelectorAll("#reviewModal .star-btn");
    stars.forEach((btn, idx) => {
        btn.classList.toggle("active", idx < star);
    });
}

async function loadModalProductReviews(productId) {
    try {
        const list = await (await fetch(`${CUS_API}/all-feedbacks?productId=${productId}`)).json();
        document.getElementById("modalReviewCount").innerText = list.length;

        const box = document.getElementById("modalProductReviewsBox");
        if (list.length === 0) {
            box.innerHTML = `<p style="font-size:13px; color:var(--text-muted); padding:10px 0;">Chưa có phản hồi nào cho sản phẩm này.</p>`;
            return;
        }

        box.innerHTML = list.map(f => `
            <div class="review-item-card">
                <div style="display:flex; justify-content:space-between; align-items:center;">
                    <div style="display:flex; align-items:center; gap:6px;">
                        <b style="color:var(--text-primary); font-size:13px;">${f.customerName}</b>
                        ${f.accountId === currentCus.accountId ? '<span class="badge badge-active" style="font-size:10px; padding:1px 6px;">Bạn</span>' : ''}
                    </div>
                    <span class="star-rating-box">
                        <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                        <span>${f.rating}.0 / 5</span>
                    </span>
                </div>
                <div style="margin-top:5px; font-size:13px; color:var(--text-secondary); line-height:1.45;">"${f.comment}"</div>
                ${f.adminReply ? `
                    <div class="review-reply-box" style="margin-top:8px;">
                        <span style="font-weight:700; font-size:11.5px; text-transform:uppercase; letter-spacing:0.04em;">✓ Phản hồi từ Người quản lý:</span>
                        <div style="margin-top:3px;">${f.adminReply}</div>
                    </div>
                ` : ''}
            </div>
        `).join("");
    } catch (e) {
        console.error("Lỗi loadModalProductReviews:", e);
    }
}

async function submitModalFeedback() {
    const comment = document.getElementById("modalFbComment").value.trim();
    if (!comment) return alert("Vui lòng nhập nội dung phản hồi của bạn.");

    const body = {
        productId: selectedModalProductId,
        rating: selectedModalStar,
        comment
    };

    try {
        const res = await fetch(`${CUS_API}/feedbacks/${currentCus.accountId}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();
        alert(data.message || "Đã gửi phản hồi về sản phẩm thành công!");

        document.getElementById("modalFbComment").value = "";
        closeReviewModal();
        await refreshCustomerDataSilently();
        notifyDataChanged("feedbacks");
    } catch (err) {
        alert("Lỗi gửi phản hồi: " + err.message);
    }
}

// BỘ LỌC ĐÁNH GIÁ THÔNG MINH (ENTERPRISE FILTER SUITE)
let reviewFilterCategory = "";
let reviewFilterRating = null;
let reviewFilterRepliedOnly = false;

async function loadCommunityFeedbacks(resetFilter = false) {
    try {
        if (resetFilter) {
            reviewFilterCategory = "";
            reviewFilterRating = null;
            reviewFilterRepliedOnly = false;
            const searchEl = document.getElementById("reviewSearchInput");
            if (searchEl) searchEl.value = "";
            document.querySelectorAll(".review-filter-toolbar .filter-pill").forEach(p => p.classList.remove("active"));
            const pillAll = document.getElementById("pillReviewCatAll");
            if (pillAll) pillAll.classList.add("active");
        }

        const res = await fetch(`${CUS_API}/all-feedbacks`);
        allFeedbacksCache = await res.json();
        renderFilteredCommunityFeedbacks();
    } catch (e) {
        console.error("Lỗi loadCommunityFeedbacks:", e);
    }
}

function filterReviewByCategory(cat, btn) {
    reviewFilterCategory = cat;
    document.querySelectorAll(".review-filter-toolbar .filter-pill").forEach(p => {
        if (p.id !== "pillReview5Star" && p.id !== "pillReviewReplied") p.classList.remove("active");
    });
    if (btn) btn.classList.add("active");
    renderFilteredCommunityFeedbacks();
}

function filterReviewByRating(stars, btn) {
    if (reviewFilterRating === stars) {
        reviewFilterRating = null;
        if (btn) btn.classList.remove("active");
    } else {
        reviewFilterRating = stars;
        if (btn) btn.classList.add("active");
    }
    renderFilteredCommunityFeedbacks();
}

function filterReviewByReplied(btn) {
    reviewFilterRepliedOnly = !reviewFilterRepliedOnly;
    if (btn) btn.classList.toggle("active", reviewFilterRepliedOnly);
    renderFilteredCommunityFeedbacks();
}

function filterCommunityReviewsLive() {
    renderFilteredCommunityFeedbacks();
}

function resetReviewFilters() {
    loadCommunityFeedbacks(true);
}

function renderFilteredCommunityFeedbacks() {
    const tbody = document.getElementById("myFeedbackTable");
    if (!tbody) return;

    const kw = (document.getElementById("reviewSearchInput")?.value || "").trim().toLowerCase();

    const filtered = allFeedbacksCache.filter(f => {
        // Lọc theo danh mục sản phẩm
        if (reviewFilterCategory) {
            const prod = allProductsCache.find(p => p.productId === f.productId);
            const cat = ((prod && prod.categoryName) || f.categoryName || f.productName || "").toLowerCase();
            if (!cat.includes(reviewFilterCategory.toLowerCase())) return false;
        }

        // Lọc theo số sao
        if (reviewFilterRating !== null && f.rating !== reviewFilterRating) {
            return false;
        }

        // Lọc chỉ xem phản hồi đã có câu trả lời từ Quản lý
        if (reviewFilterRepliedOnly && !f.adminReply) {
            return false;
        }

        // Lọc theo từ khóa tìm kiếm
        if (kw) {
            const matchName = f.productName && f.productName.toLowerCase().includes(kw);
            const matchUser = f.customerName && f.customerName.toLowerCase().includes(kw);
            const matchComment = f.comment && f.comment.toLowerCase().includes(kw);
            const matchReply = f.adminReply && f.adminReply.toLowerCase().includes(kw);
            if (!matchName && !matchUser && !matchComment && !matchReply) return false;
        }

        return true;
    });

    const countBadge = document.getElementById("reviewFilterCountBadge");
    if (countBadge) {
        countBadge.innerText = `Đang hiển thị ${filtered.length} / ${allFeedbacksCache.length} phản hồi`;
    }

    if (filtered.length === 0) {
        tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:28px; color:var(--text-muted); font-size:13px;">Không tìm thấy phản hồi nào phù hợp tiêu chí lọc.</td></tr>`;
        return;
    }

    tbody.innerHTML = filtered.map(f => {
        const isMine = f.accountId === currentCus.accountId;
        return `
        <tr>
            <td><img src="${f.productImage || DEFAULT_IMG}" class="prod-thumb" alt="${f.productName}" onerror="this.src='${DEFAULT_IMG}'"></td>
            <td><b style="color:var(--text-primary); font-size:13.5px;">${f.productName}</b></td>
            <td>
                <div style="font-weight:700; color:#0F172A;">${f.customerName}</div>
                ${isMine ? '<span class="badge badge-customer" style="margin-top:2px; font-size:10px; padding:1px 6px;">Của bạn</span>' : ''}
            </td>
            <td>
                <span class="star-rating-box">
                    <svg viewBox="0 0 24 24"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                    <span>${f.rating}.0 / 5</span>
                </span>
            </td>
            <td style="line-height:1.5;">"${f.comment}"</td>
            <td>
                ${f.adminReply ? `
                    <div style="background:#FFF7ED; border-left:3px solid #FF5B00; padding:8px 12px; border-radius:6px; font-size:12.5px; color:#9A3412; line-height:1.5;">
                        <div style="font-weight:800; font-size:11px; text-transform:uppercase; letter-spacing:0.04em; margin-bottom:2px;">✓ Người quản lý CRM giải đáp:</div>
                        <div>${f.adminReply}</div>
                    </div>
                ` : `<span style="color:var(--text-muted); font-size:12px;">Đang chờ bộ phận Quản lý tiếp nhận...</span>`}
            </td>
        </tr>
        `;
    }).join("");
}

// =========================================================
// 2. NHẬN ĐƯỢC KHẢO SÁT ĐA CÂU HỎI & ĐA YÊU CẦU VÀ THỰC HIỆN
// =========================================================
let currentModalQuestions = [];

function getFallbackSurveyQuestions() {
    return [
        {
            id: 1,
            requirement: "Yêu cầu đánh giá mức độ quan tâm",
            question: "Mức độ quan tâm và hào hứng của bạn đối với sản phẩm mới này?",
            type: "rating",
            required: true,
            options: ["1 - Rất thờ ơ", "2 - Ít quan tâm", "3 - Bình thường", "4 - Khá quan tâm", "5 - Rất hào hứng"]
        },
        {
            id: 2,
            requirement: "Yêu cầu thẩm định mức giá dự kiến",
            question: "Bạn đánh giá thế nào về mức giá dự kiến mở bán so với công nghệ mang lại?",
            type: "single",
            required: true,
            options: ["Giá rất hợp lý / Đáng đầu tư", "Mức giá hơi cao nhưng chấp nhận được", "Mức giá quá đắt / Cần giảm thêm", "Chưa phù hợp với ngân sách"]
        },
        {
            id: 3,
            requirement: "Yêu cầu khảo sát tính năng & cấu hình",
            question: "Những tiêu chí kỹ thuật & tính năng nào bạn yêu cầu bắt buộc phải có trên sản phẩm?",
            type: "multi",
            required: true,
            options: ["Hiệu năng mạnh mẽ vượt trội", "Thời lượng pin bền bỉ & Sạc nhanh", "Thiết kế mỏng nhẹ cao cấp", "Tích hợp công nghệ AI thông minh", "Màn hình chuẩn màu độ phân giải cao", "Tản nhiệt êm ái & Bền bỉ"]
        },
        {
            id: 4,
            requirement: "Yêu cầu chính sách ưu đãi & hậu mãi",
            question: "Chính sách ưu đãi hoặc dịch vụ hậu mãi nào bạn mong muốn nhất khi mở bán?",
            type: "multi",
            required: true,
            options: ["Trả góp 0% lãi suất", "Bảo hành VIP 1 đổi 1 trong 24 tháng", "Tặng kèm bộ phụ kiện chính hãng", "Trợ giá thu cũ đổi mới lên đời", "Voucher giảm giá trực tiếp đợt đầu"]
        },
        {
            id: 5,
            requirement: "Yêu cầu xác định kế hoạch mua sắm",
            question: "Kế hoạch và ý định mua sắm của bạn khi sản phẩm chính thức mở bán tại SGU Tech?",
            type: "single",
            required: true,
            options: ["Rất muốn mua (Đặt trước Pre-order ngay)", "Đang cân nhắc (Chờ xem đánh giá thực tế)", "Đang cân nhắc (Đợi đợt khuyến mãi giảm giá)", "Không mua (Chưa có nhu cầu)"]
        },
        {
            id: 6,
            requirement: "Yêu cầu đề xuất mức giá & góp ý riêng",
            question: "Mức giá bạn sẵn sàng chi trả và các yêu cầu / góp ý chi tiết khác cho sản phẩm:",
            type: "text",
            required: false,
            options: []
        }
    ];
}

function formatCustomerMySurveyResponseHtml(myResp) {
    let detailsHtml = "";
    if (myResp.answersJson) {
        try {
            const parsed = JSON.parse(myResp.answersJson);
            if (Array.isArray(parsed) && parsed.length > 0) {
                detailsHtml = parsed.map((a, idx) => {
                    const ansVal = Array.isArray(a.answer) ? a.answer.join(", ") : (a.answer || "-");
                    return `<div style="font-size:11.5px; color:#334155; margin-top:2px;">&bull; <b>Câu ${idx + 1} (${a.requirement || "Yêu cầu"}):</b> <span style="color:#1E40AF; font-weight:600;">${ansVal}</span></div>`;
                }).join("");
            }
        } catch (e) {}
    }

    if (!detailsHtml && myResp.customerOpinion) {
        detailsHtml = `<div style="color:#475569; margin-top:3px; font-size:11.5px;"><i>"${myResp.customerOpinion}"</i></div>`;
    }

    const hasManagerReply = myResp.adminReply && myResp.adminReply.trim().length > 0;
    const managerReplyHtml = hasManagerReply
        ? `
            <div style="margin-top:8px; background:#ECFDF5; border-left:3.5px solid #059669; padding:8px 10px; border-radius:6px; font-size:12px; color:#065F46; line-height:1.45;">
                <div style="font-weight:800; font-size:11px; text-transform:uppercase; letter-spacing:0.03em; margin-bottom:2px;">✓ Người quản lý CRM đã tiếp nhận & phản hồi:</div>
                <div>${myResp.adminReply}</div>
            </div>
        `
        : `
            <div style="margin-top:6px; font-size:11.5px; color:#D97706; font-weight:600;">
                ⏳ Đã gửi tới Người quản lý CRM (Đang chờ tiếp nhận & phản hồi)
            </div>
        `;

    return `
        <div style="font-size:12px; line-height:1.45;">
            <div style="margin-bottom:4px;">
                <b>Điểm đánh giá:</b> <span style="color:#EA580C; font-weight:800;">${myResp.score}/5 ★</span>
                &bull; <b>Ý định:</b> <span class="badge badge-info" style="font-size:10.5px;">${myResp.buyingIntent}</span>
            </div>
            ${detailsHtml}
            ${managerReplyHtml}
        </div>
    `;
}

async function loadMySurveys() {
    try {
        const res = await fetch(`${CUS_API}/surveys/${currentCus.accountId}?username=${encodeURIComponent(currentCus.username || "")}`);
        allSurveysCache = await res.json();

        const totalCount = allSurveysCache.length;
        const doneCount = allSurveysCache.filter(s => s.isCompleted).length;
        const pendingCount = allSurveysCache.filter(s => !s.isCompleted && s.isActive && !s.isExpired).length;

        if (document.getElementById("cusKpiTotalSurveys")) document.getElementById("cusKpiTotalSurveys").innerText = totalCount;
        if (document.getElementById("cusKpiPendingSurveys")) document.getElementById("cusKpiPendingSurveys").innerText = pendingCount;
        if (document.getElementById("cusKpiDoneSurveys")) document.getElementById("cusKpiDoneSurveys").innerText = doneCount;

        const badge = document.getElementById("navSurveyPendingBadge");
        if (badge) {
            if (pendingCount > 0) {
                badge.style.display = "inline-block";
                badge.innerText = `${pendingCount} mới`;
            } else {
                badge.style.display = "none";
            }
        }

        const tbody = document.getElementById("mySurveyTable");
        if (!tbody) return;

        if (allSurveysCache.length === 0) {
            tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:20px; color:var(--text-muted);">Hiện tại chưa có bảng khảo sát nào được gửi đến tài khoản của bạn.</td></tr>`;
            return;
        }

        tbody.innerHTML = allSurveysCache.map(s => {
            let expireLabel = `<span class="badge badge-info">Còn hiệu lực</span>`;
            if (s.expiresAt) {
                const d = new Date(s.expiresAt).toLocaleDateString("vi-VN");
                expireLabel = s.isExpired
                    ? `<span class="badge badge-locked">Đã hết hạn (${d})</span>`
                    : `<span class="badge badge-info">Đến ngày ${d}</span>`;
            }

            let qCount = 6;
            let reqCount = 4;
            try {
                if (s.questionsJson) {
                    const qArr = JSON.parse(s.questionsJson);
                    if (Array.isArray(qArr) && qArr.length > 0) qCount = qArr.length;
                }
                if (s.requirementsJson) {
                    const rArr = JSON.parse(s.requirementsJson);
                    if (Array.isArray(rArr) && rArr.length > 0) reqCount = rArr.length;
                }
            } catch (e) {}

            let myAnswerHtml = `<span style="color:#d97706; font-size:12px; font-weight:600;">Chưa thực hiện (${qCount} câu hỏi đang chờ bạn đánh giá)</span>`;
            if (s.isCompleted && s.myResponse) {
                myAnswerHtml = formatCustomerMySurveyResponseHtml(s.myResponse);
            } else if (s.isCompleted) {
                myAnswerHtml = `<span class="badge badge-active">Đã gửi kết quả</span>`;
            }

            let actionHtml = "";
            if (s.isCompleted) {
                actionHtml = `
                    <div style="display:flex; flex-direction:column; gap:6px; align-items:center;">
                        <span class="badge badge-active" style="padding:4px 10px; font-size:11.5px;">✓ Đã gửi đánh giá</span>
                        ${(s.isActive && !s.isExpired) ? `<button class="btn btn-warning" style="padding:4px 10px; font-size:11.5px;" onclick="openSurveyModal(${s.surveyId})">Cập nhật lại</button>` : ''}
                    </div>
                `;
            } else if (!s.isActive) {
                actionHtml = `<button class="btn btn-warning" disabled style="padding:4px 10px; font-size:12px;">Đã đóng</button>`;
            } else if (s.isExpired) {
                actionHtml = `<button class="btn btn-warning" disabled style="padding:4px 10px; font-size:12px;">Đã hết hạn</button>`;
            } else {
                actionHtml = `<button class="btn" style="padding:7px 16px; font-size:12.5px; border-radius:6px;" onclick="openSurveyModal(${s.surveyId})">Thực hiện khảo sát (${qCount} câu)</button>`;
            }

            return `
            <tr>
                <td><b>#${s.surveyId}</b></td>
                <td>
                    <b style="font-size:13.5px; color:var(--text-primary);">${s.title}</b>
                    <div style="color:var(--text-muted); font-size:11.5px; margin-top:2px; line-height:1.4;">${s.description || ""}</div>
                    <div style="margin-top:5px; display:flex; gap:5px; flex-wrap:wrap;">
                        <span class="badge-tag" style="background:#FFF7ED; color:#EA580C; border:1px solid #FED7AA; font-size:10.5px;">📋 ${reqCount} yêu cầu</span>
                        <span class="badge-tag" style="background:#EFF6FF; color:#1D4ED8; border:1px solid #BFDBFE; font-size:10.5px;">❓ ${qCount} câu hỏi</span>
                    </div>
                </td>
                <td>
                    <b style="color:#1d4ed8;">${s.targetProduct}</b>
                    <div style="font-size:12px; color:#059669; font-weight:700; margin-top:2px;">${Number(s.expectedPrice).toLocaleString("vi-VN")} ₫</div>
                </td>
                <td>${expireLabel}</td>
                <td>${myAnswerHtml}</td>
                <td style="text-align:center;">${actionHtml}</td>
            </tr>
            `;
        }).join("");
    } catch (e) {
        console.error("Lỗi loadMySurveys:", e);
    }
}

function selectDynamicRating(qIdx, scoreVal, btnEl) {
    const group = document.getElementById(`dynRatingGroup_${qIdx}`);
    if (group) {
        group.querySelectorAll(".survey-score-btn").forEach(b => b.classList.remove("active"));
    }
    if (btnEl) btnEl.classList.add("active");
    const hidden = document.getElementById(`dynAnswer_${qIdx}`);
    if (hidden) hidden.value = String(scoreVal);
}

function selectDynamicSingleChoice(qIdx, val, cardEl) {
    const group = document.getElementById(`dynSingleGroup_${qIdx}`);
    if (group) {
        group.querySelectorAll(".survey-choice-card").forEach(c => c.classList.remove("active"));
    }
    if (cardEl) cardEl.classList.add("active");
    const hidden = document.getElementById(`dynAnswer_${qIdx}`);
    if (hidden) hidden.value = val;
}

function toggleDynamicMultiChip(chipEl) {
    if (chipEl) chipEl.classList.toggle("active");
}

function openSurveyModal(surveyId) {
    const sv = allSurveysCache.find(s => s.surveyId === surveyId);
    if (!sv) return;

    selectedModalSurveyId = sv.surveyId;
    document.getElementById("svModalTitle").innerText = sv.title;
    document.getElementById("svModalDesc").innerText = sv.description || "";
    document.getElementById("svModalProduct").innerText = sv.targetProduct;
    document.getElementById("svModalPrice").innerText = Number(sv.expectedPrice).toLocaleString("vi-VN") + " ₫";

    // Render các Yêu cầu Khảo sát trọng tâm
    let reqs = ["Yêu cầu đánh giá mức độ quan tâm & thiết kế", "Yêu cầu thẩm định mức giá dự kiến", "Yêu cầu khảo sát tính năng kỹ thuật", "Yêu cầu xác định kế hoạch mua sắm"];
    try {
        if (sv.requirementsJson) {
            const parsedReqs = JSON.parse(sv.requirementsJson);
            if (Array.isArray(parsedReqs) && parsedReqs.length > 0) reqs = parsedReqs;
        }
    } catch (e) {}

    const reqBox = document.getElementById("svModalRequirementsBox");
    if (reqBox) {
        reqBox.innerHTML = `
            <div style="font-size:11.5px; font-weight:800; color:#9A3412; margin-bottom:5px;">CÁC YÊU CẦU KHẢO SÁT TRỌNG TÂM CỦA NGƯỜI QUẢN LÝ (${reqs.length} YÊU CẦU):</div>
            <div style="display:flex; flex-wrap:wrap; gap:6px;">
                ${reqs.map(r => `<span style="background:#FFFFFF; color:#C2410C; border:1px solid #FDBA74; font-size:11px; font-weight:700; padding:3px 8px; border-radius:6px;">✓ ${r}</span>`).join("")}
            </div>
        `;
    }

    // Parse danh sách câu hỏi động của bài khảo sát
    let questions = getFallbackSurveyQuestions();
    try {
        if (sv.questionsJson) {
            const parsedQ = JSON.parse(sv.questionsJson);
            if (Array.isArray(parsedQ) && parsedQ.length > 0) {
                questions = parsedQ;
            }
        }
    } catch (e) {}
    currentModalQuestions = questions;

    const qContainer = document.getElementById("svDynamicQuestionsBox");
    if (qContainer) {
        qContainer.innerHTML = currentModalQuestions.map((q, idx) => {
            const qType = q.type || "single";
            const reqTag = q.requirement
                ? `<span style="background:#FFF7ED; color:#EA580C; border:1px solid #FED7AA; font-size:11px; font-weight:700; padding:2px 8px; border-radius:4px; margin-left:6px;">${q.requirement}</span>`
                : "";

            if (qType === "rating") {
                const labels = Array.isArray(q.options) && q.options.length >= 5
                    ? q.options
                    : ["1 - Rất thờ ơ", "2 - Ít quan tâm", "3 - Bình thường", "4 - Khá quan tâm", "5 - Rất hào hứng"];
                return `
                    <div class="survey-section-box" data-qidx="${idx}">
                        <div class="survey-q-title">
                            <span style="color:#FF5B00;">Câu ${idx + 1}.</span> ${q.question} * ${reqTag}
                        </div>
                        <div class="survey-q-desc">Chọn mức điểm từ 1 (Thấp nhất) đến 5 (Cao nhất)</div>
                        <div class="survey-score-grid" id="dynRatingGroup_${idx}">
                            ${[1, 2, 3, 4, 5].map(num => {
                                const lbl = (labels[num - 1] || `${num} điểm`).replace(/^\d+\s*-\s*/, "");
                                return `
                                    <div class="survey-score-btn ${num === 5 ? 'active' : ''}" onclick="selectDynamicRating(${idx}, ${num}, this)">
                                        <div class="survey-score-num">${num}</div>
                                        <div class="survey-score-label">${lbl}</div>
                                    </div>
                                `;
                            }).join("")}
                        </div>
                        <input type="hidden" id="dynAnswer_${idx}" value="5">
                    </div>
                `;
            } else if (qType === "single") {
                const opts = Array.isArray(q.options) && q.options.length > 0
                    ? q.options
                    : ["Rất phù hợp / Đồng ý", "Đang cân nhắc thêm", "Chưa phù hợp"];
                const defaultOpt = opts[0];
                return `
                    <div class="survey-section-box" data-qidx="${idx}">
                        <div class="survey-q-title">
                            <span style="color:#FF5B00;">Câu ${idx + 1}.</span> ${q.question} * ${reqTag}
                        </div>
                        <div class="survey-q-desc">Chọn 1 phương án phù hợp nhất với đánh giá của bạn</div>
                        <div class="survey-choice-grid" id="dynSingleGroup_${idx}">
                            ${opts.map((opt, oIdx) => {
                                const safeOpt = String(opt).replace(/'/g, "\\'").replace(/"/g, "&quot;");
                                return `
                                    <div class="survey-choice-card ${oIdx === 0 ? 'active' : ''}" onclick="selectDynamicSingleChoice(${idx}, '${safeOpt}', this)">
                                        <div class="survey-choice-radio"></div>
                                        <div>
                                            <div class="survey-choice-title">${opt}</div>
                                        </div>
                                    </div>
                                `;
                            }).join("")}
                        </div>
                        <input type="hidden" id="dynAnswer_${idx}" value="${String(defaultOpt).replace(/"/g, '&quot;')}">
                    </div>
                `;
            } else if (qType === "multi") {
                const opts = Array.isArray(q.options) && q.options.length > 0
                    ? q.options
                    : ["Hiệu năng mạnh mẽ", "Pin bền bỉ & Sạc nhanh", "Thiết kế mỏng nhẹ", "Giá ưu đãi & Quà tặng"];
                return `
                    <div class="survey-section-box" data-qidx="${idx}">
                        <div class="survey-q-title">
                            <span style="color:#FF5B00;">Câu ${idx + 1}.</span> ${q.question} * ${reqTag}
                        </div>
                        <div class="survey-q-desc">Bấm chọn nhiều yêu cầu / tiêu chí bạn mong muốn (có thể chọn nhiều ô)</div>
                        <div class="survey-chips-grid" id="dynMultiGroup_${idx}">
                            ${opts.map((opt, oIdx) => `
                                <div class="survey-chip-item ${oIdx < 2 ? 'active' : ''}" onclick="toggleDynamicMultiChip(this)" data-val="${String(opt).replace(/"/g, '&quot;')}">
                                    ${opt}
                                </div>
                            `).join("")}
                        </div>
                    </div>
                `;
            } else {
                // type === "text"
                const defaultPriceStr = Number(sv.expectedPrice).toLocaleString("vi-VN") + " ₫";
                return `
                    <div class="survey-section-box" data-qidx="${idx}" style="margin-bottom:10px;">
                        <div class="survey-q-title">
                            <span style="color:#FF5B00;">Câu ${idx + 1}.</span> ${q.question} ${reqTag}
                        </div>
                        <div class="grid-form" style="grid-template-columns: 1fr; margin-bottom: 10px;">
                            <div>
                                <label style="font-weight:600; font-size:12.5px;">Mức giá kỳ vọng bạn sẵn sàng chi trả cho sản phẩm (VNĐ):</label>
                                <input type="text" id="dynWillingPrice_${idx}" value="${defaultPriceStr}" placeholder="VD: 25.000.000 ₫">
                            </div>
                        </div>
                        <div>
                            <label style="font-weight:600; font-size:12.5px;">Ý kiến đóng góp & Yêu cầu chi tiết gửi Người quản lý CRM:</label>
                            <textarea id="dynTextAnswer_${idx}" rows="3" placeholder="Chia sẻ cụ thể yêu cầu của bạn về cấu hình, mức giá, màu sắc hoặc chính sách bảo hành..."></textarea>
                        </div>
                    </div>
                `;
            }
        }).join("");
    }

    document.getElementById("surveyModal").classList.add("show");
}

function closeSurveyModal() {
    document.getElementById("surveyModal").classList.remove("show");
}

async function submitModalSurvey() {
    let overallScore = 5;
    let overallIntent = "Rất muốn mua (Đặt trước Pre-order ngay)";
    let summaryParts = [];
    let answersList = [];

    for (let idx = 0; idx < currentModalQuestions.length; idx++) {
        const q = currentModalQuestions[idx];
        const qType = q.type || "single";
        let ansVal = "";

        if (qType === "rating") {
            const val = Number(document.getElementById(`dynAnswer_${idx}`)?.value || 5);
            overallScore = val;
            ansVal = `${val} / 5 điểm`;
            summaryParts.push(`[${q.requirement || "Điểm đánh giá"}: ${ansVal}]`);
        } else if (qType === "single") {
            const val = (document.getElementById(`dynAnswer_${idx}`)?.value || "").trim();
            ansVal = val;
            const qLower = (q.question + " " + (q.requirement || "")).toLowerCase();
            if (qLower.includes("mua") || qLower.includes("kế hoạch") || qLower.includes("ý định")) {
                overallIntent = val;
            }
            summaryParts.push(`[${q.requirement || `Câu ${idx + 1}`}: ${val}]`);
        } else if (qType === "multi") {
            const chips = Array.from(document.querySelectorAll(`#dynMultiGroup_${idx} .survey-chip-item.active`))
                .map(c => c.getAttribute("data-val") || c.innerText.trim())
                .filter(Boolean);
            if (q.required && chips.length === 0) {
                return alert(`Vui lòng chọn ít nhất 1 tiêu chí cho Câu hỏi #${idx + 1} (${q.question})!`);
            }
            ansVal = chips.join(", ");
            summaryParts.push(`[${q.requirement || `Tiêu chí câu ${idx + 1}`}: ${ansVal}]`);
        } else {
            const wPrice = (document.getElementById(`dynWillingPrice_${idx}`)?.value || "").trim();
            const txt = (document.getElementById(`dynTextAnswer_${idx}`)?.value || "").trim();
            const combined = [];
            if (wPrice) {
                combined.push(`Giá kỳ vọng: ${wPrice}`);
                summaryParts.push(`[Giá sẵn sàng chi: ${wPrice}]`);
            }
            if (txt) {
                combined.push(`Góp ý: ${txt}`);
                summaryParts.push(`[Góp ý: ${txt}]`);
            }
            ansVal = combined.length > 0 ? combined.join(" | ") : "Đồng ý với cấu hình và chính sách đề xuất";
        }

        answersList.push({
            questionId: q.id || (idx + 1),
            requirement: q.requirement || `Yêu cầu #${idx + 1}`,
            question: q.question,
            type: qType,
            answer: ansVal
        });
    }

    const formattedOpinion = summaryParts.join(" ");

    try {
        const res = await fetch(`${CUS_API}/surveys/${selectedModalSurveyId}/submit/${currentCus.accountId}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                score: overallScore,
                buyingIntent: overallIntent,
                customerOpinion: formattedOpinion,
                answersJson: JSON.stringify(answersList),
                username: currentCus.username
            })
        });
        const data = await res.json();
        if (!res.ok) {
            return alert(data.message || "Không thể gửi kết quả khảo sát. Vui lòng thử lại!");
        }

        if (data && data.accountId) {
            currentCus.accountId = data.accountId;
            localStorage.setItem("currentCustomer", JSON.stringify(currentCus));
        }

        alert(data.message || "Đã gửi đánh giá khảo sát thành công! Người quản lý CRM đã nhận được câu trả lời của bạn.");
        closeSurveyModal();
        await loadMySurveys();
        notifyDataChanged("surveys");
    } catch (err) {
        alert("Lỗi kết nối khi gửi khảo sát: " + err.message);
    }
}

// =========================================================
// 3. CHỈNH SỬA THÔNG TIN CÁ NHÂN
// =========================================================
async function updateProfile() {
    const fullName = document.getElementById("pFullName").value.trim();
    const email = document.getElementById("pEmailDisplay")?.value.trim() || "";
    const phone = document.getElementById("pPhone").value.trim();
    const age = Number(document.getElementById("pAge").value || 20);
    const gender = document.getElementById("pGender")?.value || "Nam";
    const address = document.getElementById("pAddress").value.trim();
    const interest = document.getElementById("pInterest").value;

    if (!fullName) return alert("Vui lòng nhập Họ và tên khách hàng.");

    const body = {
        fullName,
        email,
        phone,
        age,
        gender,
        address,
        interest
    };

    try {
        const res = await fetch(`${CUS_API}/profile/${currentCus.accountId}`, {
            method: "PUT",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(body)
        });
        const data = await res.json();
        alert(data.message || "Đã lưu chỉnh sửa thông tin cá nhân thành công!");

        currentCus.fullName = fullName;
        localStorage.setItem("currentCustomer", JSON.stringify(currentCus));

        const initials = getInitials(fullName);
        if (document.getElementById("cusAvatarTop")) document.getElementById("cusAvatarTop").innerText = initials;
        if (document.getElementById("profAvatarBig")) document.getElementById("profAvatarBig").innerText = initials;
        if (document.getElementById("cusWelcome")) document.getElementById("cusWelcome").innerText = fullName;
        if (document.getElementById("profCardFullName")) document.getElementById("profCardFullName").innerText = fullName;
        if (document.getElementById("profCardInterestTag")) document.getElementById("profCardInterestTag").innerText = interest;
        if (document.getElementById("profCardAgeTag")) document.getElementById("profCardAgeTag").innerText = age + " tuổi";

        notifyDataChanged("customers");
    } catch (err) {
        alert("Lỗi khi cập nhật thông tin: " + err.message);
    }
}

function logoutCustomer() {
    localStorage.removeItem("currentCustomer");
    window.location.href = "customer_login.html";
}
