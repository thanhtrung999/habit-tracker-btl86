/**
 * Habit & Goal Tracker - Main Application Logic
 * Clean, Modular, Offline-First (LocalStorage)
 */

(function () {
  'use strict';

  // --- Constants & Defaults ---
  const STORAGE_KEYS = {
    GOALS: 'habit_goals_v1',
    RECORDS: 'habit_records_v1',
    SETTINGS: 'habit_settings_v1'
  };

  const CATEGORIES = [
    { id: 'health', name: 'Sức khỏe', color: '#10B981' },
    { id: 'study', name: 'Học tập', color: '#3B82F6' },
    { id: 'work', name: 'Công việc', color: '#6366F1' },
    { id: 'mind', name: 'Tinh thần', color: '#8B5CF6' },
    { id: 'life', name: 'Lối sống', color: '#F59E0B' }
  ];

  const COLOR_PALETTE = [
    '#2D6A4F', // Sage/Forest Green
    '#3B82F6', // Ocean Blue
    '#8B5CF6', // Purple Lavender
    '#F59E0B', // Warm Amber
    '#EF4444', // Coral Red
    '#06B6D4', // Cyan
    '#EC4899'  // Pink Rose
  ];

  // Helper date formatting
  function formatDate(d) {
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  function parseDate(str) {
    const [y, m, d] = str.split('-').map(Number);
    return new Date(y, m - 1, d);
  }

  function getFriendlyDateString(dateStr) {
    const todayStr = formatDate(new Date());
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = formatDate(yesterday);
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    const tomorrowStr = formatDate(tomorrow);

    const d = parseDate(dateStr);
    const dayOfWeek = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'][d.getDay()];
    const formatted = `${d.getDate()} thg ${d.getMonth() + 1}, ${d.getFullYear()}`;

    if (dateStr === todayStr) return { label: 'Hôm nay', full: `${dayOfWeek}, ${formatted}` };
    if (dateStr === yesterdayStr) return { label: 'Hôm qua', full: `${dayOfWeek}, ${formatted}` };
    if (dateStr === tomorrowStr) return { label: 'Ngày mai', full: `${dayOfWeek}, ${formatted}` };
    return { label: dayOfWeek, full: `${dayOfWeek}, ${formatted}` };
  }

  // --- Storage Service ---
  const Storage = {
    getGoals() {
      const data = localStorage.getItem(STORAGE_KEYS.GOALS);
      return data ? JSON.parse(data) : [];
    },
    saveGoals(goals) {
      localStorage.setItem(STORAGE_KEYS.GOALS, JSON.stringify(goals));
    },
    getRecords() {
      const data = localStorage.getItem(STORAGE_KEYS.RECORDS);
      return data ? JSON.parse(data) : {};
    },
    saveRecords(records) {
      localStorage.setItem(STORAGE_KEYS.RECORDS, JSON.stringify(records));
    },
    initSampleDataIfEmpty() {
      const existing = this.getGoals();
      if (existing && existing.length > 0) return;

      const sampleGoals = [
        {
          id: 'g_1',
          title: 'Uống đủ 2 lít nước',
          description: 'Giữ cơ thể luôn đủ nước và thanh lọc mỗi ngày',
          category: 'health',
          color: '#3B82F6',
          targetFrequency: 'all',
          weekdays: [0, 1, 2, 3, 4, 5, 6],
          targetCount: 4,
          unit: 'ly nước',
          createdAt: new Date().toISOString()
        },
        {
          id: 'g_2',
          title: 'Đọc sách phát triển bản thân',
          description: 'Đọc ít nhất 15-20 trang sách mỗi ngày',
          category: 'study',
          color: '#2D6A4F',
          targetFrequency: 'all',
          weekdays: [0, 1, 2, 3, 4, 5, 6],
          targetCount: 1,
          unit: 'lần',
          createdAt: new Date().toISOString()
        },
        {
          id: 'g_3',
          title: 'Tập thể dục 30 phút',
          description: 'Chạy bộ, gym hoặc cardio nhẹ nhàng',
          category: 'health',
          color: '#F59E0B',
          targetFrequency: 'custom',
          weekdays: [1, 2, 3, 4, 5, 6], // T2 - T7
          targetCount: 1,
          unit: 'lần',
          createdAt: new Date().toISOString()
        },
        {
          id: 'g_4',
          title: 'Viết nhật ký & Ghi nhận biết ơn',
          description: 'Tổng kết 3 điều tích cực đã xảy ra trong ngày',
          category: 'mind',
          color: '#8B5CF6',
          targetFrequency: 'all',
          weekdays: [0, 1, 2, 3, 4, 5, 6],
          targetCount: 1,
          unit: 'lần',
          createdAt: new Date().toISOString()
        }
      ];

      // Sample records to showcase different milestone tiers:
      // g_1: 12 days (Tier RED >= 10)
      // g_2: 6 days (Tier ORANGE >= 5)
      // g_3: 35 days (Tier PURPLE >= 30)
      // g_4: 2 days (Tier STARTER < 5)
      const sampleRecords = {};
      const today = new Date();

      // g_1: 12 days completed
      for (let i = 0; i < 12; i++) {
        const d = new Date();
        d.setDate(today.getDate() - i);
        const dStr = formatDate(d);
        sampleRecords[`g_1_${dStr}`] = {
          goalId: 'g_1',
          date: dStr,
          completed: true,
          currentCount: 4,
          note: i === 0 ? 'Uống đủ nước cảm thấy rất sảng khoái và tỉnh táo!' : ''
        };
      }

      // g_2: 6 days completed
      for (let i = 0; i < 6; i++) {
        const d = new Date();
        d.setDate(today.getDate() - i);
        const dStr = formatDate(d);
        sampleRecords[`g_2_${dStr}`] = {
          goalId: 'g_2',
          date: dStr,
          completed: true,
          currentCount: 1,
          note: i === 0 ? 'Đọc xong chương 3 về thói quen nguyên tử.' : ''
        };
      }

      // g_3: 35 days completed
      for (let i = 0; i < 35; i++) {
        const d = new Date();
        d.setDate(today.getDate() - i);
        const dStr = formatDate(d);
        sampleRecords[`g_3_${dStr}`] = {
          goalId: 'g_3',
          date: dStr,
          completed: true,
          currentCount: 1,
          note: ''
        };
      }

      // g_4: 2 days completed
      for (let i = 0; i < 2; i++) {
        const d = new Date();
        d.setDate(today.getDate() - i);
        const dStr = formatDate(d);
        sampleRecords[`g_4_${dStr}`] = {
          goalId: 'g_4',
          date: dStr,
          completed: true,
          currentCount: 1,
          note: i === 0 ? 'Biết ơn vì ngày hôm nay mọi việc suôn sẻ.' : ''
        };
      }

      this.saveGoals(sampleGoals);
      this.saveRecords(sampleRecords);
    }
  };

  // --- App State ---
  const state = {
    currentDateStr: formatDate(new Date()), // Date being viewed in Today tab
    selectedCalendarDateStr: formatDate(new Date()), // Date selected in Calendar
    calendarMonth: new Date().getMonth(),
    calendarYear: new Date().getFullYear(),
    activeTab: 'tab-today',
    editingGoalId: null,
    editingNoteGoalId: null,
    editingNoteDateStr: null,
    selectedColor: COLOR_PALETTE[0],
    selectedWeekdays: [0, 1, 2, 3, 4, 5, 6]
  };

  // --- DOM Elements Cache ---
  const DOM = {};

  function initDOMElements() {
    DOM.navItems = document.querySelectorAll('.nav-item');
    DOM.tabPanels = document.querySelectorAll('.tab-panel');
    DOM.fabAddGoal = document.getElementById('fabAddGoal');

    // Today Tab
    DOM.todayPercent = document.getElementById('todayPercent');
    DOM.todayRatio = document.getElementById('todayRatio');
    DOM.todayProgressBar = document.getElementById('todayProgressBar');
    DOM.todayStreak = document.getElementById('todayStreak');
    DOM.todayGoalCountBadge = document.getElementById('todayGoalCountBadge');
    DOM.currentDateLabel = document.getElementById('currentDateLabel');
    DOM.currentDateFull = document.getElementById('currentDateFull');
    DOM.dateDisplay = document.querySelector('.date-display');
    DOM.btnPrevDate = document.getElementById('btnPrevDate');
    DOM.btnNextDate = document.getElementById('btnNextDate');
    DOM.goalsListToday = document.getElementById('goalsListToday');

    // Goals Tab
    DOM.goalsListManage = document.getElementById('goalsListManage');
    DOM.btnOpenAddGoal = document.getElementById('btnOpenAddGoal');

    // Calendar & Analytics Tab
    DOM.calMonthTitle = document.getElementById('calMonthTitle');
    DOM.calPrevMonth = document.getElementById('calPrevMonth');
    DOM.calNextMonth = document.getElementById('calNextMonth');
    DOM.calGrid = document.getElementById('calGrid');
    DOM.statTotalCompleted = document.getElementById('statTotalCompleted');
    DOM.statCurrentStreak = document.getElementById('statCurrentStreak');
    DOM.statCompletionRate = document.getElementById('statCompletionRate');
    DOM.goalMilestonesList = document.getElementById('goalMilestonesList');
    DOM.milestonesTotalGoalsBadge = document.getElementById('milestonesTotalGoalsBadge');
    DOM.chartCanvas = document.getElementById('completionChart');
    DOM.calSelectedDayBanner = document.getElementById('calSelectedDayBanner');
    DOM.calSelectedDateText = document.getElementById('calSelectedDateText');
    DOM.calSelectedStatusText = document.getElementById('calSelectedStatusText');
    DOM.btnOpenDayCheckinModal = document.getElementById('btnOpenDayCheckinModal');

    // Day Checkin Modal (Calendar Tab)
    DOM.modalDayCheckin = document.getElementById('modalDayCheckin');
    DOM.dayCheckinModalDate = document.getElementById('dayCheckinModalDate');
    DOM.dayCheckinGoalsList = document.getElementById('dayCheckinGoalsList');
    DOM.btnCloseDayCheckinModal = document.getElementById('btnCloseDayCheckinModal');
    DOM.btnDoneDayCheckin = document.getElementById('btnDoneDayCheckin');

    // Settings Tab
    DOM.btnExportData = document.getElementById('btnExportData');
    DOM.btnImportData = document.getElementById('btnImportData');
    DOM.fileImport = document.getElementById('fileImport');
    DOM.btnResetData = document.getElementById('btnResetData');
    DOM.btnLoadSampleData = document.getElementById('btnLoadSampleData');

    // Goal Modal
    DOM.modalGoal = document.getElementById('modalGoal');
    DOM.modalGoalTitle = document.getElementById('modalGoalTitle');
    DOM.formGoal = document.getElementById('formGoal');
    DOM.goalTitleInput = document.getElementById('goalTitleInput');
    DOM.goalDescInput = document.getElementById('goalDescInput');
    DOM.goalCategorySelect = document.getElementById('goalCategorySelect');
    DOM.goalCountInput = document.getElementById('goalCountInput');
    DOM.goalUnitInput = document.getElementById('goalUnitInput');
    DOM.colorPickerContainer = document.getElementById('colorPickerContainer');
    DOM.weekdayContainer = document.getElementById('weekdayContainer');
    DOM.btnDeleteGoal = document.getElementById('btnDeleteGoal');
    DOM.btnCloseGoalModal = document.getElementById('btnCloseGoalModal');

    // Note Modal
    DOM.modalNote = document.getElementById('modalNote');
    DOM.noteGoalTitle = document.getElementById('noteGoalTitle');
    DOM.noteDateDisplay = document.getElementById('noteDateDisplay');
    DOM.noteTextarea = document.getElementById('noteTextarea');
    DOM.btnSaveNote = document.getElementById('btnSaveNote');
    DOM.btnCloseNoteModal = document.getElementById('btnCloseNoteModal');

    // Toast
    DOM.toast = document.getElementById('toast');
  }

  // --- Notification Toast ---
  function showToast(message) {
    DOM.toast.textContent = message;
    DOM.toast.classList.add('show');
    setTimeout(() => {
      DOM.toast.classList.remove('show');
    }, 2400);
  }

  // --- Logic Helpers ---
  function isGoalScheduledForDate(goal, dateStr) {
    if (!goal.targetFrequency || goal.targetFrequency === 'all') return true;
    const d = parseDate(dateStr);
    const dayOfWeek = d.getDay(); // 0: Sun, 1: Mon...
    return goal.weekdays ? goal.weekdays.includes(dayOfWeek) : true;
  }

  function getRecord(goalId, dateStr) {
    const records = Storage.getRecords();
    const key = `${goalId}_${dateStr}`;
    return records[key] || {
      goalId,
      date: dateStr,
      completed: false,
      currentCount: 0,
      note: ''
    };
  }

  function saveRecord(record) {
    const records = Storage.getRecords();
    const key = `${record.goalId}_${record.date}`;
    records[key] = record;
    Storage.saveRecords(records);
  }

  // Calculate Streak
  function calculateStreak() {
    const goals = Storage.getGoals();
    if (goals.length === 0) return 0;

    const records = Storage.getRecords();
    let streak = 0;
    const checkDate = new Date();

    // If today is not yet completed, check if yesterday was completed
    let isTodayEvaluated = false;
    let offset = 0;

    while (offset < 365) {
      const d = new Date();
      d.setDate(checkDate.getDate() - offset);
      const dStr = formatDate(d);

      const activeGoals = goals.filter(g => isGoalScheduledForDate(g, dStr));
      if (activeGoals.length === 0) {
        offset++;
        continue;
      }

      let completedCount = 0;
      activeGoals.forEach(g => {
        const rec = records[`${g.id}_${dStr}`];
        if (rec && rec.completed) completedCount++;
      });

      const rate = completedCount / activeGoals.length;

      // Allow today to be incomplete without breaking streak immediately
      if (offset === 0 && rate < 0.5) {
        offset++;
        continue;
      }

      if (rate >= 0.5) {
        streak++;
        offset++;
      } else {
        break;
      }
    }

    return streak;
  }

  // Calculate Consecutive Streak for an individual goal (Chuỗi ngày liên tiếp)
  function getGoalStreak(goalId) {
    const goals = Storage.getGoals();
    const goal = goals.find(g => g.id === goalId);
    if (!goal) return 0;

    const records = Storage.getRecords();
    let streak = 0;
    const now = new Date();
    const todayStr = formatDate(now);

    const isTodayScheduled = isGoalScheduledForDate(goal, todayStr);
    const todayRec = records[`${goalId}_${todayStr}`];

    let offset = 0;
    if (isTodayScheduled) {
      if (todayRec && todayRec.completed) {
        streak = 1;
        offset = 1;
      } else {
        // Today is not completed yet; start checking backwards from yesterday
        // so current unbroken streak is preserved during the day
        offset = 1;
      }
    } else {
      // Goal is not scheduled today (e.g. weekend); start checking from yesterday
      offset = 1;
    }

    // Traverse past scheduled days backwards (up to 1000 days)
    while (offset < 1000) {
      const d = new Date();
      d.setDate(now.getDate() - offset);
      const dStr = formatDate(d);

      if (!isGoalScheduledForDate(goal, dStr)) {
        // Unscheduled day does not break streak
        offset++;
        continue;
      }

      const rec = records[`${goalId}_${dStr}`];
      if (rec && rec.completed) {
        streak++;
        offset++;
      } else {
        // Streak ends when a scheduled day was missed
        break;
      }
    }

    return streak;
  }

  // Calculate stats for a date
  function getDateProgress(dateStr) {
    const goals = Storage.getGoals();
    const activeGoals = goals.filter(g => isGoalScheduledForDate(g, dateStr));
    if (activeGoals.length === 0) return { total: 0, completed: 0, percent: 0 };

    let completed = 0;
    activeGoals.forEach(g => {
      const rec = getRecord(g.id, dateStr);
      if (rec.completed) completed++;
    });

    const percent = Math.round((completed / activeGoals.length) * 100);
    return { total: activeGoals.length, completed, percent };
  }

  // --- Render Functions ---

  // 1. Render Today Tab
  function renderTodayTab() {
    const friendly = getFriendlyDateString(state.currentDateStr);
    DOM.currentDateLabel.textContent = friendly.label;
    DOM.currentDateFull.textContent = friendly.full;

    const progress = getDateProgress(state.currentDateStr);
    DOM.todayPercent.textContent = `${progress.percent}%`;
    DOM.todayRatio.textContent = `${progress.completed}/${progress.total} mục tiêu`;
    DOM.todayProgressBar.style.width = `${progress.percent}%`;

    const streak = calculateStreak();
    DOM.todayStreak.innerHTML = `🔥 <span>${streak} ngày liên tục</span>`;

    const goals = Storage.getGoals();
    const activeGoals = goals.filter(g => isGoalScheduledForDate(g, state.currentDateStr));

    if (DOM.todayGoalCountBadge) {
      if (activeGoals.length === 0) {
        DOM.todayGoalCountBadge.textContent = 'Chưa lên lịch';
      } else if (progress.completed === activeGoals.length) {
        DOM.todayGoalCountBadge.textContent = '🎉 Đạt 100%';
      } else {
        DOM.todayGoalCountBadge.textContent = `${progress.completed}/${activeGoals.length} hoàn thành`;
      }
    }

    DOM.goalsListToday.innerHTML = '';

    if (activeGoals.length === 0) {
      DOM.goalsListToday.innerHTML = `
        <div class="empty-state">
          <div class="empty-icon">🌱</div>
          <p>Không có mục tiêu nào được lên lịch cho ngày này.</p>
          <button class="btn-primary" id="btnEmptyAddGoal" style="max-width: 200px; margin: 0 auto;">+ Thêm mục tiêu</button>
        </div>
      `;
      const btnEmpty = document.getElementById('btnEmptyAddGoal');
      if (btnEmpty) btnEmpty.onclick = () => openGoalModal();
      return;
    }

    activeGoals.forEach(goal => {
      const rec = getRecord(goal.id, state.currentDateStr);
      const isCompleted = rec.completed;
      const targetCount = goal.targetCount || 1;
      const hasCounter = targetCount > 1;
      const hasNote = rec.note && rec.note.trim().length > 0;

      const card = document.createElement('div');
      card.className = `goal-card ${isCompleted ? 'completed' : ''}`;
      card.innerHTML = `
        <div class="goal-color-stripe" style="background-color: ${goal.color};"></div>
        <button class="goal-check-btn" data-goal-id="${goal.id}">✓</button>
        <div class="goal-content">
          <div class="goal-header-row">
            <span class="goal-title">${escapeHTML(goal.title)}</span>
            <span class="goal-category-badge" style="background: ${getCategoryBg(goal.category)}; color: ${getCategoryColor(goal.category)}">
              ${getCategoryName(goal.category)}
            </span>
          </div>
          ${goal.description ? `<div class="goal-desc">${escapeHTML(goal.description)}</div>` : ''}

          ${hasCounter ? `
            <div class="goal-counter-row">
              <button class="counter-btn btn-minus" data-goal-id="${goal.id}">-</button>
              <span class="counter-text">${rec.currentCount || 0}/${targetCount} ${escapeHTML(goal.unit || 'lần')}</span>
              <button class="counter-btn btn-plus" data-goal-id="${goal.id}">+</button>
            </div>
          ` : ''}

          ${hasNote ? `
            <div class="goal-note-snippet" data-goal-id="${goal.id}">
              <span>📝</span>
              <span style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 280px;">${escapeHTML(rec.note)}</span>
            </div>
          ` : ''}

          <div class="goal-actions-row">
            <button class="btn-pill-small ${hasNote ? 'has-note' : ''} btn-action-note" data-goal-id="${goal.id}">
              ${hasNote ? '✏️ Sửa ghi chú' : '+ Thêm ghi chú'}
            </button>
          </div>
        </div>
      `;

      // Event: Checkmark click
      const checkBtn = card.querySelector('.goal-check-btn');
      checkBtn.addEventListener('click', () => {
        toggleGoalCompletion(goal.id, state.currentDateStr);
      });

      // Event: Counter + / -
      if (hasCounter) {
        const btnMinus = card.querySelector('.btn-minus');
        const btnPlus = card.querySelector('.btn-plus');
        btnMinus.addEventListener('click', () => updateGoalCount(goal.id, state.currentDateStr, -1));
        btnPlus.addEventListener('click', () => updateGoalCount(goal.id, state.currentDateStr, 1));
      }

      // Event: Note button
      const noteBtn = card.querySelector('.btn-action-note');
      noteBtn.addEventListener('click', () => openNoteModal(goal.id, state.currentDateStr));

      const noteSnippet = card.querySelector('.goal-note-snippet');
      if (noteSnippet) {
        noteSnippet.addEventListener('click', () => openNoteModal(goal.id, state.currentDateStr));
      }

      DOM.goalsListToday.appendChild(card);
    });
  }

  // 2. Render Goals Management Tab
  function renderGoalsTab() {
    const goals = Storage.getGoals();
    DOM.goalsListManage.innerHTML = '';

    if (goals.length === 0) {
      DOM.goalsListManage.innerHTML = `
        <div class="empty-state">
          <div class="empty-icon">🎯</div>
          <p>Chưa có mục tiêu nào được tạo.</p>
          <button class="btn-primary" onclick="window.appOpenAddGoal()" style="max-width: 200px; margin: 0 auto;">+ Tạo mục tiêu đầu tiên</button>
        </div>
      `;
      return;
    }

    goals.forEach(goal => {
      const card = document.createElement('div');
      card.className = 'goal-card';
      card.innerHTML = `
        <div class="goal-color-stripe" style="background-color: ${goal.color};"></div>
        <div class="goal-content" style="padding-left: 6px;">
          <div class="goal-header-row">
            <span class="goal-title">${escapeHTML(goal.title)}</span>
            <span class="goal-category-badge" style="background: ${getCategoryBg(goal.category)}; color: ${getCategoryColor(goal.category)}">
              ${getCategoryName(goal.category)}
            </span>
          </div>
          ${goal.description ? `<div class="goal-desc">${escapeHTML(goal.description)}</div>` : ''}
          <div style="font-size: 0.76rem; color: var(--text-muted); margin-top: 4px;">
            ⏰ Tần suất: <strong>${getFrequencyText(goal)}</strong> 
            • Mục tiêu: <strong>${goal.targetCount || 1} ${escapeHTML(goal.unit || 'lần')}/ngày</strong>
          </div>
          <div class="goal-actions-row" style="margin-top: 10px;">
            <button class="btn-pill-small btn-edit-goal" data-id="${goal.id}">✏️ Chỉnh sửa</button>
            <button class="btn-pill-small btn-delete-goal" data-id="${goal.id}" style="color: var(--danger); border-color: #FECACA;">🗑️ Xóa</button>
          </div>
        </div>
      `;

      card.querySelector('.btn-edit-goal').addEventListener('click', () => openGoalModal(goal.id));
      card.querySelector('.btn-delete-goal').addEventListener('click', () => confirmDeleteGoal(goal.id));

      DOM.goalsListManage.appendChild(card);
    });
  }

  // 3. Render Calendar & Stats Tab
  function renderCalendarTab() {
    renderCalendarGrid();
    renderStatsOverview();
    renderChart();
    updateSelectedDayBanner(state.selectedCalendarDateStr);
  }

  function renderCalendarGrid() {
    const monthNames = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
      'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    DOM.calMonthTitle.textContent = `${monthNames[state.calendarMonth]} ${state.calendarYear}`;

    DOM.calGrid.innerHTML = '';

    const firstDayIndex = new Date(state.calendarYear, state.calendarMonth, 1).getDay();
    const daysInMonth = new Date(state.calendarYear, state.calendarMonth + 1, 0).getDate();
    const daysInPrevMonth = new Date(state.calendarYear, state.calendarMonth, 0).getDate();

    const todayStr = formatDate(new Date());

    // Previous month filler days
    for (let i = firstDayIndex - 1; i >= 0; i--) {
      const cell = document.createElement('div');
      cell.className = 'cal-day-cell other-month';
      cell.textContent = daysInPrevMonth - i;
      DOM.calGrid.appendChild(cell);
    }

    // Current month days
    for (let day = 1; day <= daysInMonth; day++) {
      const cellDate = new Date(state.calendarYear, state.calendarMonth, day);
      const dateStr = formatDate(cellDate);
      const progress = getDateProgress(dateStr);

      const cell = document.createElement('div');
      cell.className = 'cal-day-cell';
      cell.dataset.date = dateStr;

      if (dateStr === todayStr) cell.classList.add('today');
      if (dateStr === state.selectedCalendarDateStr) cell.classList.add('selected');

      // Status indicator class
      if (progress.total > 0) {
        if (progress.percent === 100) {
          cell.classList.add('status-perfect');
        } else if (progress.percent > 0) {
          cell.classList.add('status-partial');
        } else {
          cell.classList.add('status-empty');
        }
      }

      cell.innerHTML = `
        <span>${day}</span>
        ${progress.percent > 0 ? `<div class="cal-dot"></div>` : ''}
      `;

      cell.addEventListener('click', () => {
        state.selectedCalendarDateStr = dateStr;
        document.querySelectorAll('.cal-day-cell').forEach(c => c.classList.remove('selected'));
        cell.classList.add('selected');
        updateSelectedDayBanner(dateStr);
      });

      DOM.calGrid.appendChild(cell);
    }
  }

  function updateSelectedDayBanner(dateStr) {
    if (!DOM.calSelectedDayBanner) return;
    const goals = Storage.getGoals();
    const activeGoals = goals.filter(g => isGoalScheduledForDate(g, dateStr));
    const friendly = getFriendlyDateString(dateStr);

    if (DOM.calSelectedDateText) {
      DOM.calSelectedDateText.textContent = friendly.full;
    }

    if (DOM.calSelectedStatusText) {
      if (activeGoals.length === 0) {
        DOM.calSelectedStatusText.textContent = 'Không có mục tiêu nào vào ngày này';
      } else {
        const progress = getDateProgress(dateStr);
        const completedCount = activeGoals.filter(g => getRecord(g.id, dateStr).completed).length;
        DOM.calSelectedStatusText.textContent = `${completedCount}/${activeGoals.length} mục tiêu hoàn thành (${progress.percent}%)`;
      }
    }
  }

  function refreshCalendarDayCell(dateStr) {
    if (!DOM.calGrid) return;
    const cell = DOM.calGrid.querySelector(`.cal-day-cell[data-date="${dateStr}"]`);
    if (!cell) return;
    const progress = getDateProgress(dateStr);

    cell.classList.remove('status-perfect', 'status-partial', 'status-empty');
    if (progress.total > 0) {
      if (progress.percent === 100) {
        cell.classList.add('status-perfect');
      } else if (progress.percent > 0) {
        cell.classList.add('status-partial');
      } else {
        cell.classList.add('status-empty');
      }
    }

    let dot = cell.querySelector('.cal-dot');
    if (progress.percent > 0) {
      if (!dot) {
        dot = document.createElement('div');
        dot.className = 'cal-dot';
        cell.appendChild(dot);
      }
    } else {
      if (dot) dot.remove();
    }
  }

  function openDayCheckinModal(dateStr) {
    state.selectedCalendarDateStr = dateStr;
    const goals = Storage.getGoals();
    const activeGoals = goals.filter(g => isGoalScheduledForDate(g, dateStr));
    const friendly = getFriendlyDateString(dateStr);

    if (DOM.dayCheckinModalDate) {
      DOM.dayCheckinModalDate.textContent = `Ngày: ${friendly.full}`;
    }

    if (!DOM.dayCheckinGoalsList) return;
    DOM.dayCheckinGoalsList.innerHTML = '';

    if (activeGoals.length === 0) {
      DOM.dayCheckinGoalsList.innerHTML = `
        <div style="text-align: center; padding: 24px 12px; color: var(--text-muted); font-size: 0.88rem;">
          Không có mục tiêu nào được lên lịch vào ngày này.
        </div>
      `;
      openModal(DOM.modalDayCheckin);
      return;
    }

    activeGoals.forEach(goal => {
      const rec = getRecord(goal.id, dateStr);
      const isCompleted = !!rec.completed;
      const targetCount = goal.targetCount || 1;
      const currentCount = rec.currentCount || 0;

      const item = document.createElement('div');
      item.className = 'day-checkin-goal-item';
      item.style.borderLeft = `4px solid ${goal.color || 'var(--primary)'}`;

      item.innerHTML = `
        <div class="day-checkin-goal-top">
          <div class="day-checkin-goal-info">
            <div class="day-checkin-goal-title">${escapeHTML(goal.title)}</div>
            <div class="day-checkin-goal-sub">
              ${targetCount > 1 ? `Mục tiêu: <strong id="dayCheckinCountDisplay_${goal.id}">${currentCount}/${targetCount}</strong> ${escapeHTML(goal.unit || 'lần')}` : getCategoryName(goal.category)}
            </div>
          </div>
          <button type="button" class="day-checkin-toggle-btn ${isCompleted ? 'completed' : ''}" data-goal-id="${goal.id}">
            ${isCompleted ? '✅ Đã hoàn thành' : '⚪ Chưa đạt'}
          </button>
        </div>

        ${targetCount > 1 ? `
          <div class="day-checkin-counter-row">
            <span style="font-size: 0.78rem; color: var(--text-muted); font-weight: 500;">Cập nhật số lần:</span>
            <button type="button" class="counter-btn btn-counter-dec" data-goal-id="${goal.id}">-</button>
            <span class="counter-display" id="dayCheckinCountNum_${goal.id}">${currentCount}</span>
            <button type="button" class="counter-btn btn-counter-inc" data-goal-id="${goal.id}">+</button>
          </div>
        ` : ''}

        <div class="day-checkin-note-row">
          <textarea class="day-checkin-note-field" data-goal-id="${goal.id}" rows="2" placeholder="Ghi chú kết quả, cảm nhận cho mục tiêu này...">${escapeHTML(rec.note || '')}</textarea>
        </div>
      `;

      // Event listener for toggle button
      const toggleBtn = item.querySelector('.day-checkin-toggle-btn');
      toggleBtn.addEventListener('click', () => {
        const currentRec = getRecord(goal.id, dateStr);
        const newCompleted = !currentRec.completed;
        currentRec.completed = newCompleted;
        if (newCompleted && targetCount > 1 && (currentRec.currentCount || 0) < targetCount) {
          currentRec.currentCount = targetCount;
        } else if (!newCompleted && targetCount > 1 && (currentRec.currentCount || 0) >= targetCount) {
          currentRec.currentCount = 0;
        }
        saveRecord(currentRec);

        // Update UI
        toggleBtn.classList.toggle('completed', newCompleted);
        toggleBtn.innerHTML = newCompleted ? '✅ Đã hoàn thành' : '⚪ Chưa đạt';
        if (targetCount > 1) {
          const countDisplay = item.querySelector(`#dayCheckinCountDisplay_${goal.id}`);
          const countNum = item.querySelector(`#dayCheckinCountNum_${goal.id}`);
          if (countDisplay) countDisplay.textContent = `${currentRec.currentCount}/${targetCount}`;
          if (countNum) countNum.textContent = currentRec.currentCount;
        }

        handleDayCheckinDataChange(dateStr);
      });

      // Event listeners for counter controls if targetCount > 1
      if (targetCount > 1) {
        const decBtn = item.querySelector('.btn-counter-dec');
        const incBtn = item.querySelector('.btn-counter-inc');
        const countDisplay = item.querySelector(`#dayCheckinCountDisplay_${goal.id}`);
        const countNum = item.querySelector(`#dayCheckinCountNum_${goal.id}`);

        decBtn.addEventListener('click', () => {
          const currentRec = getRecord(goal.id, dateStr);
          if ((currentRec.currentCount || 0) > 0) {
            currentRec.currentCount--;
            currentRec.completed = currentRec.currentCount >= targetCount;
            saveRecord(currentRec);
            if (countDisplay) countDisplay.textContent = `${currentRec.currentCount}/${targetCount}`;
            if (countNum) countNum.textContent = currentRec.currentCount;
            toggleBtn.classList.toggle('completed', currentRec.completed);
            toggleBtn.innerHTML = currentRec.completed ? '✅ Đã hoàn thành' : '⚪ Chưa đạt';
            handleDayCheckinDataChange(dateStr);
          }
        });

        incBtn.addEventListener('click', () => {
          const currentRec = getRecord(goal.id, dateStr);
          currentRec.currentCount = (currentRec.currentCount || 0) + 1;
          currentRec.completed = currentRec.currentCount >= targetCount;
          saveRecord(currentRec);
          if (countDisplay) countDisplay.textContent = `${currentRec.currentCount}/${targetCount}`;
          if (countNum) countNum.textContent = currentRec.currentCount;
          toggleBtn.classList.toggle('completed', currentRec.completed);
          toggleBtn.innerHTML = currentRec.completed ? '✅ Đã hoàn thành' : '⚪ Chưa đạt';
          handleDayCheckinDataChange(dateStr);
        });
      }

      // Note input event listener
      const noteInput = item.querySelector('.day-checkin-note-field');
      noteInput.addEventListener('input', () => {
        const currentRec = getRecord(goal.id, dateStr);
        currentRec.note = noteInput.value.trim();
        saveRecord(currentRec);
      });

      DOM.dayCheckinGoalsList.appendChild(item);
    });

    openModal(DOM.modalDayCheckin);
  }

  function handleDayCheckinDataChange(dateStr) {
    refreshCalendarDayCell(dateStr);
    updateSelectedDayBanner(dateStr);
    renderStatsOverview();
    renderChart();
    if (dateStr === state.currentDateStr) {
      renderTodayTab();
    }
  }

  function closeDayCheckinModal() {
    if (DOM.dayCheckinGoalsList) {
      DOM.dayCheckinGoalsList.querySelectorAll('.day-checkin-note-field').forEach(input => {
        const goalId = input.dataset.goalId;
        const currentRec = getRecord(goalId, state.selectedCalendarDateStr);
        const newNote = input.value.trim();
        if (currentRec.note !== newNote) {
          currentRec.note = newNote;
          saveRecord(currentRec);
        }
      });
    }
    closeModal(DOM.modalDayCheckin);
    renderCalendarTab();
  }

  // --- Milestone Tiers & Color Specification ---
  // < 5 ngày: Xanh (Mới bắt đầu)
  // ≥ 5 ngày: Cam (#F97316)
  // ≥ 10 ngày: Đỏ (#EF4444)
  // ≥ 30 ngày: Tím (#8B5CF6)
  // ≥ 60 ngày: Pastel Mint (#0D9488 / #2DD4BF)
  // ≥ 100 ngày: Vàng Kim (#D97706 / #F59E0B)
  // ≥ 200 ngày: Hồng Ngọc (#DB2777 / #EC4899)
  // ≥ 365 ngày: Kim Cương Tinh Thể (#4F46E5 / #6366F1)
  const MILESTONE_TIERS = [
    {
      minDays: 365,
      nextDays: null,
      tier: 'diamond',
      label: 'Huyền thoại (≥ 365 ngày liên tiếp)',
      color: '#4F46E5',
      badgeBg: '#EEF2FF',
      badgeBorder: '#C7D2FE',
      gradient: 'linear-gradient(135deg, #4F46E5 0%, #7C3AED 50%, #EC4899 100%)',
      icon: '💎',
      colorName: 'Kim Cương'
    },
    {
      minDays: 200,
      nextDays: 365,
      tier: 'ruby',
      label: 'Siêu Kỷ Luật (≥ 200 ngày liên tiếp)',
      color: '#DB2777',
      badgeBg: '#FDF2F8',
      badgeBorder: '#FBCFE8',
      gradient: 'linear-gradient(135deg, #DB2777 0%, #F43F5E 100%)',
      icon: '💖',
      colorName: 'Hồng Ngọc'
    },
    {
      minDays: 100,
      nextDays: 200,
      tier: 'gold',
      label: 'Bậc Thầy (≥ 100 ngày liên tiếp)',
      color: '#D97706',
      badgeBg: '#FFFBEB',
      badgeBorder: '#FDE68A',
      gradient: 'linear-gradient(135deg, #D97706 0%, #F59E0B 100%)',
      icon: '🟡',
      colorName: 'Vàng Kim'
    },
    {
      minDays: 60,
      nextDays: 100,
      tier: 'pastel',
      label: 'Kiên Định (≥ 60 ngày liên tiếp)',
      color: '#0D9488',
      badgeBg: '#F0FDFA',
      badgeBorder: '#99F6E4',
      gradient: 'linear-gradient(135deg, #0D9488 0%, #2DD4BF 100%)',
      icon: '🩵',
      colorName: 'Pastel'
    },
    {
      minDays: 30,
      nextDays: 60,
      tier: 'purple',
      label: 'Thói Quen Thép (≥ 30 ngày liên tiếp)',
      color: '#8B5CF6',
      badgeBg: '#F5F3FF',
      badgeBorder: '#DDD6FE',
      gradient: 'linear-gradient(135deg, #8B5CF6 0%, #A855F7 100%)',
      icon: '🟣',
      colorName: 'Màu Tím'
    },
    {
      minDays: 10,
      nextDays: 30,
      tier: 'red',
      label: 'Quyết Tâm (≥ 10 ngày liên tiếp)',
      color: '#EF4444',
      badgeBg: '#FEF2F2',
      badgeBorder: '#FECACA',
      gradient: 'linear-gradient(135deg, #EF4444 0%, #DC2626 100%)',
      icon: '🔴',
      colorName: 'Màu Đỏ'
    },
    {
      minDays: 5,
      nextDays: 10,
      tier: 'orange',
      label: 'Bắt Nhịp (≥ 5 ngày liên tiếp)',
      color: '#F97316',
      badgeBg: '#FFF7ED',
      badgeBorder: '#FED7AA',
      gradient: 'linear-gradient(135deg, #F97316 0%, #EA580C 100%)',
      icon: '🟠',
      colorName: 'Màu Cam'
    },
    {
      minDays: 0,
      nextDays: 5,
      tier: 'starter',
      label: 'Khởi Đầu (< 5 ngày liên tiếp)',
      color: '#10B981',
      badgeBg: '#ECFDF5',
      badgeBorder: '#A7F3D0',
      gradient: 'linear-gradient(135deg, #10B981 0%, #059669 100%)',
      icon: '🟢',
      colorName: 'Xanh'
    }
  ];

  function getMilestoneTier(days) {
    for (const tier of MILESTONE_TIERS) {
      if (days >= tier.minDays) return tier;
    }
    return MILESTONE_TIERS[MILESTONE_TIERS.length - 1];
  }

  function getGoalCompletedDaysCount(goalId) {
    const records = Storage.getRecords();
    let count = 0;
    Object.values(records).forEach(rec => {
      if (rec.goalId === goalId && rec.completed) {
        count++;
      }
    });
    return count;
  }

  function renderStatsOverview() {
    const goals = Storage.getGoals();
    const records = Storage.getRecords();

    if (DOM.milestonesTotalGoalsBadge) {
      DOM.milestonesTotalGoalsBadge.textContent = `${goals.length} mục tiêu`;
    }

    // Sort by consecutive streak descending
    const sortedGoals = [...goals].map(g => {
      return {
        ...g,
        streak: getGoalStreak(g.id),
        completedDays: getGoalCompletedDaysCount(g.id)
      };
    }).sort((a, b) => b.streak - a.streak);

    const maxStreak = sortedGoals.length > 0 ? Math.max(...sortedGoals.map(g => g.streak)) : 0;
    if (DOM.statCurrentStreak) {
      DOM.statCurrentStreak.textContent = `${maxStreak} ngày`;
    }

    // Total completions count across all goals
    let totalCompleted = 0;
    Object.values(records).forEach(rec => {
      if (rec.completed) totalCompleted++;
    });
    if (DOM.statTotalCompleted) {
      DOM.statTotalCompleted.textContent = totalCompleted;
    }

    // Average rate in the last 7 days
    let sumRate = 0;
    for (let i = 0; i < 7; i++) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      sumRate += getDateProgress(formatDate(d)).percent;
    }
    const avgRate = Math.round(sumRate / 7);
    if (DOM.statCompletionRate) {
      DOM.statCompletionRate.textContent = `${avgRate}%`;
    }

    // Render Milestone Progress Items for Each Goal (based on consecutive streak)
    if (DOM.goalMilestonesList) {
      DOM.goalMilestonesList.innerHTML = '';

      if (goals.length === 0) {
        DOM.goalMilestonesList.innerHTML = `
          <div style="text-align: center; padding: 20px; color: var(--text-muted); font-size: 0.85rem;">
            Chưa có mục tiêu nào. Hãy thêm mục tiêu để bắt đầu theo dõi chuỗi ngày liên tiếp!
          </div>
        `;
        return;
      }

      sortedGoals.forEach(goal => {
        const streak = goal.streak;
        const tier = getMilestoneTier(streak);

        let progressPercent = 0;
        let hintText = '';

        if (tier.nextDays) {
          const needed = tier.nextDays - streak;
          const range = tier.nextDays - tier.minDays;
          const currentInRange = streak - tier.minDays;
          progressPercent = Math.min(100, Math.max(10, Math.round((currentInRange / range) * 100)));
          const nextTier = getMilestoneTier(tier.nextDays);
          hintText = `Còn <strong>${needed} ngày liên tiếp</strong> nữa để lên mốc <strong>${nextTier.colorName}</strong> (≥ ${tier.nextDays} ngày)`;
        } else {
          progressPercent = 100;
          hintText = `Đã đạt mốc Kim Cương tối thượng! Xuất sắc 💎`;
        }

        const item = document.createElement('div');
        item.className = 'goal-milestone-item';
        item.style.borderLeft = `5px solid ${tier.color}`;

        item.innerHTML = `
          <div class="goal-milestone-header">
            <div class="goal-milestone-title-box">
              <span class="goal-milestone-title">${escapeHTML(goal.title)}</span>
              <span style="font-size: 0.72rem; color: ${getCategoryColor(goal.category)}; font-weight: 500;">
                ${getCategoryName(goal.category)}
              </span>
            </div>
            <div class="goal-milestone-badge" style="background: ${tier.badgeBg}; color: ${tier.color}; border: 1px solid ${tier.badgeBorder};">
              <span>${tier.icon}</span>
              <span>${tier.label}</span>
            </div>
          </div>

          <div class="goal-milestone-count-row">
            <div>
              <span class="goal-milestone-days-big" style="color: ${tier.color};">${streak}</span>
              <span class="goal-milestone-days-unit">ngày liên tiếp</span>
            </div>
            <span style="font-size: 0.78rem; font-weight: 700; color: ${tier.color};">
              Mốc: ${tier.colorName}
            </span>
          </div>

          <div class="goal-milestone-bar-bg">
            <div class="goal-milestone-bar-fill" style="width: ${progressPercent}%; background: ${tier.gradient};"></div>
          </div>

          <div class="goal-milestone-sub">
            <span>${hintText}</span>
            <span style="font-weight: 700; color: ${tier.color};">${progressPercent}%</span>
          </div>
        `;

        DOM.goalMilestonesList.appendChild(item);
      });
    }
  }

  // 4. Standalone Canvas Chart Renderer (Runs 100% Offline with zero external dependencies)
  function renderChart() {
    const canvas = DOM.chartCanvas;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    const width = canvas.parentElement.clientWidth || 360;
    const height = 180;

    // Set high-DPI resolution
    const dpr = window.devicePixelRatio || 1;
    canvas.width = width * dpr;
    canvas.height = height * dpr;
    canvas.style.width = `${width}px`;
    canvas.style.height = `${height}px`;
    ctx.scale(dpr, dpr);

    ctx.clearRect(0, 0, width, height);

    // Fetch last 7 days data
    const daysData = [];
    const dayLabels = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const dStr = formatDate(d);
      const prog = getDateProgress(dStr);
      daysData.push({
        dayName: dayLabels[d.getDay()],
        dateStr: dStr,
        percent: prog.percent
      });
    }

    // Chart layout specs
    const padding = { top: 20, right: 16, bottom: 30, left: 34 };
    const chartWidth = width - padding.left - padding.right;
    const chartHeight = height - padding.top - padding.bottom;

    // Background Grid lines
    ctx.strokeStyle = '#E2E8F0';
    ctx.lineWidth = 1;
    ctx.beginPath();
    [0, 50, 100].forEach(val => {
      const y = padding.top + chartHeight - (val / 100) * chartHeight;
      ctx.moveTo(padding.left, y);
      ctx.lineTo(width - padding.right, y);

      ctx.fillStyle = '#94A3B8';
      ctx.font = '10px -apple-system, sans-serif';
      ctx.textAlign = 'right';
      ctx.fillText(`${val}%`, padding.left - 6, y + 3);
    });
    ctx.stroke();

    // Draw Bars
    const barWidth = Math.min(28, (chartWidth / daysData.length) * 0.55);
    const step = chartWidth / daysData.length;

    daysData.forEach((item, index) => {
      const x = padding.left + index * step + (step - barWidth) / 2;
      const barH = (item.percent / 100) * chartHeight;
      const y = padding.top + chartHeight - barH;

      // Bar rounded top
      ctx.fillStyle = item.percent === 100 ? '#2D6A4F' : item.percent > 0 ? '#52B788' : '#E2E8F0';
      roundRect(ctx, x, y, barWidth, Math.max(barH, 4), 6);
      ctx.fill();

      // Bottom Label (T2, T3, etc.)
      ctx.fillStyle = '#64748B';
      ctx.font = '11px -apple-system, sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText(item.dayName, x + barWidth / 2, height - 10);

      // Percentage on top of bar
      if (item.percent > 0) {
        ctx.fillStyle = '#1E293B';
        ctx.font = 'bold 9px -apple-system, sans-serif';
        ctx.fillText(`${item.percent}%`, x + barWidth / 2, y - 5);
      }
    });
  }

  function roundRect(ctx, x, y, width, height, radius) {
    if (height < radius) radius = height / 2;
    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + width - radius, y);
    ctx.quadraticCurveTo(x + width, y, x + width, y + radius);
    ctx.lineTo(x + width, y + height);
    ctx.lineTo(x, y + height);
    ctx.lineTo(x, y + radius);
    ctx.quadraticCurveTo(x, y, x + radius, y);
    ctx.closePath();
  }

  // --- Actions & Handlers ---

  function toggleGoalCompletion(goalId, dateStr) {
    const goals = Storage.getGoals();
    const goal = goals.find(g => g.id === goalId);
    if (!goal) return;

    const rec = getRecord(goalId, dateStr);
    rec.completed = !rec.completed;
    if (rec.completed) {
      rec.currentCount = goal.targetCount || 1;
      showToast(`🎉 Đã hoàn thành: ${goal.title}`);
    } else {
      rec.currentCount = 0;
    }
    saveRecord(rec);
    renderTodayTab();
  }

  function updateGoalCount(goalId, dateStr, delta) {
    const goals = Storage.getGoals();
    const goal = goals.find(g => g.id === goalId);
    if (!goal) return;

    const rec = getRecord(goalId, dateStr);
    const target = goal.targetCount || 1;
    let count = (rec.currentCount || 0) + delta;
    if (count < 0) count = 0;
    rec.currentCount = count;
    rec.completed = count >= target;
    saveRecord(rec);
    renderTodayTab();
  }

  // Goal Modal Handlers
  function openGoalModal(goalId = null) {
    state.editingGoalId = goalId;
    renderColorPicker();
    renderWeekdayPicker();

    if (goalId) {
      const goals = Storage.getGoals();
      const goal = goals.find(g => g.id === goalId);
      if (!goal) return;

      DOM.modalGoalTitle.textContent = 'Chỉnh sửa mục tiêu';
      DOM.goalTitleInput.value = goal.title;
      DOM.goalDescInput.value = goal.description || '';
      DOM.goalCategorySelect.value = goal.category || 'health';
      DOM.goalCountInput.value = goal.targetCount || 1;
      DOM.goalUnitInput.value = goal.unit || 'lần';
      state.selectedColor = goal.color || COLOR_PALETTE[0];
      state.selectedWeekdays = goal.weekdays || [0, 1, 2, 3, 4, 5, 6];
      DOM.btnDeleteGoal.style.display = 'block';
    } else {
      DOM.modalGoalTitle.textContent = 'Thêm mục tiêu mới';
      DOM.formGoal.reset();
      DOM.goalCountInput.value = 1;
      DOM.goalUnitInput.value = 'lần';
      state.selectedColor = COLOR_PALETTE[0];
      state.selectedWeekdays = [0, 1, 2, 3, 4, 5, 6];
      DOM.btnDeleteGoal.style.display = 'none';
    }

    renderColorPicker();
    renderWeekdayPicker();
    DOM.modalGoal.classList.add('open');
    DOM.goalTitleInput.focus();
  }

  function closeGoalModal() {
    DOM.modalGoal.classList.remove('open');
    state.editingGoalId = null;
  }

  function saveGoalFromForm(e) {
    e.preventDefault();
    const title = DOM.goalTitleInput.value.trim();
    if (!title) {
      showToast('Vui lòng nhập tên mục tiêu!');
      return;
    }

    const goals = Storage.getGoals();
    const count = Math.max(1, parseInt(DOM.goalCountInput.value) || 1);
    const unit = DOM.goalUnitInput.value.trim() || 'lần';
    const desc = DOM.goalDescInput.value.trim();
    const category = DOM.goalCategorySelect.value;

    if (state.editingGoalId) {
      // Update existing
      const idx = goals.findIndex(g => g.id === state.editingGoalId);
      if (idx !== -1) {
        goals[idx] = {
          ...goals[idx],
          title,
          description: desc,
          category,
          color: state.selectedColor,
          targetCount: count,
          unit,
          weekdays: state.selectedWeekdays
        };
        Storage.saveGoals(goals);
        showToast('Đã cập nhật mục tiêu thành công!');
      }
    } else {
      // Create new
      const newGoal = {
        id: 'goal_' + Date.now(),
        title,
        description: desc,
        category,
        color: state.selectedColor,
        targetFrequency: state.selectedWeekdays.length === 7 ? 'all' : 'custom',
        weekdays: state.selectedWeekdays,
        targetCount: count,
        unit,
        createdAt: new Date().toISOString()
      };
      goals.push(newGoal);
      Storage.saveGoals(goals);
      showToast('Đã thêm mục tiêu mới!');
    }

    closeGoalModal();
    renderTodayTab();
    renderGoalsTab();
    renderCalendarTab();
  }

  function confirmDeleteGoal(goalId) {
    if (confirm('Bạn có chắc chắn muốn xóa mục tiêu này không? Lịch sử ghi chép vẫn được lưu.')) {
      let goals = Storage.getGoals();
      goals = goals.filter(g => g.id !== goalId);
      Storage.saveGoals(goals);
      showToast('Đã xóa mục tiêu.');
      closeGoalModal();
      renderTodayTab();
      renderGoalsTab();
      renderCalendarTab();
    }
  }

  function renderColorPicker() {
    DOM.colorPickerContainer.innerHTML = '';
    COLOR_PALETTE.forEach(color => {
      const dot = document.createElement('div');
      dot.className = `color-option ${state.selectedColor === color ? 'selected' : ''}`;
      dot.style.backgroundColor = color;
      dot.addEventListener('click', () => {
        state.selectedColor = color;
        renderColorPicker();
      });
      DOM.colorPickerContainer.appendChild(dot);
    });
  }

  function renderWeekdayPicker() {
    DOM.weekdayContainer.innerHTML = '';
    const dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    dayNames.forEach((name, idx) => {
      const pill = document.createElement('div');
      const isSelected = state.selectedWeekdays.includes(idx);
      pill.className = `day-pill ${isSelected ? 'selected' : ''}`;
      pill.textContent = name;
      pill.addEventListener('click', () => {
        if (state.selectedWeekdays.includes(idx)) {
          if (state.selectedWeekdays.length > 1) {
            state.selectedWeekdays = state.selectedWeekdays.filter(d => d !== idx);
          }
        } else {
          state.selectedWeekdays.push(idx);
          state.selectedWeekdays.sort();
        }
        renderWeekdayPicker();
      });
      DOM.weekdayContainer.appendChild(pill);
    });
  }

  // Note Modal Handlers
  function openNoteModal(goalId, dateStr) {
    const goals = Storage.getGoals();
    const goal = goals.find(g => g.id === goalId);
    if (!goal) return;

    state.editingNoteGoalId = goalId;
    state.editingNoteDateStr = dateStr;

    const friendly = getFriendlyDateString(dateStr);
    DOM.noteGoalTitle.textContent = goal.title;
    DOM.noteDateDisplay.textContent = `Ngày: ${friendly.full}`;

    const rec = getRecord(goalId, dateStr);
    DOM.noteTextarea.value = rec.note || '';

    DOM.modalNote.classList.add('open');
    DOM.noteTextarea.focus();
  }

  function closeNoteModal() {
    DOM.modalNote.classList.remove('open');
    state.editingNoteGoalId = null;
    state.editingNoteDateStr = null;
  }

  function saveNote() {
    if (!state.editingNoteGoalId || !state.editingNoteDateStr) return;
    const rec = getRecord(state.editingNoteGoalId, state.editingNoteDateStr);
    rec.note = DOM.noteTextarea.value.trim();
    saveRecord(rec);

    showToast('Đã lưu ghi chú cho nhiệm vụ!');
    closeNoteModal();
    renderTodayTab();
    renderCalendarTab();
  }

  // Navigation Tabs Switcher
  function switchTab(targetTabId) {
    state.activeTab = targetTabId;

    DOM.navItems.forEach(item => {
      if (item.dataset.tab === targetTabId) {
        item.classList.add('active');
      } else {
        item.classList.remove('active');
      }
    });

    DOM.tabPanels.forEach(panel => {
      if (panel.id === targetTabId) {
        panel.classList.add('active');
      } else {
        panel.classList.remove('active');
      }
    });

    // Control FAB visibility
    if (targetTabId === 'tab-today' || targetTabId === 'tab-goals') {
      DOM.fabAddGoal.style.display = 'flex';
    } else {
      DOM.fabAddGoal.style.display = 'none';
    }

    if (targetTabId === 'tab-today') renderTodayTab();
    if (targetTabId === 'tab-calendar') renderCalendarTab();
    if (targetTabId === 'tab-goals') renderGoalsTab();
  }

  // Data Export / Import
  function exportData() {
    const data = {
      version: '1.0',
      exportedAt: new Date().toISOString(),
      goals: Storage.getGoals(),
      records: Storage.getRecords()
    };
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `HabitTracker_Backup_${formatDate(new Date())}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    showToast('Đã xuất file dữ liệu dự phòng thành công!');
  }

  function importData(e) {
    const file = e.target.files[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = function (event) {
      try {
        const json = JSON.parse(event.target.result);
        if (json.goals && json.records) {
          Storage.saveGoals(json.goals);
          Storage.saveRecords(json.records);
          showToast('Đã khôi phục dữ liệu thành công!');
          renderTodayTab();
          renderGoalsTab();
          renderCalendarTab();
        } else {
          showToast('Tệp sao lưu không đúng định dạng!');
        }
      } catch (err) {
        showToast('Lỗi đọc tệp JSON: ' + err.message);
      }
    };
    reader.readAsText(file);
    e.target.value = '';
  }

  function resetAllData() {
    if (confirm('CẢNH BÁO: Thao tác này sẽ xóa toàn bộ mục tiêu và lịch sử ghi chép. Bạn có chắc không?')) {
      localStorage.removeItem(STORAGE_KEYS.GOALS);
      localStorage.removeItem(STORAGE_KEYS.RECORDS);
      showToast('Đã đặt lại toàn bộ dữ liệu.');
      renderTodayTab();
      renderGoalsTab();
      renderCalendarTab();
    }
  }

  function loadSampleData() {
    localStorage.removeItem(STORAGE_KEYS.GOALS);
    localStorage.removeItem(STORAGE_KEYS.RECORDS);
    Storage.initSampleDataIfEmpty();
    showToast('Đã nạp dữ liệu mẫu!');
    renderTodayTab();
    renderGoalsTab();
    renderCalendarTab();
  }

  // Category helpers
  function getCategoryName(catId) {
    const cat = CATEGORIES.find(c => c.id === catId);
    return cat ? cat.name : 'Chung';
  }

  function getCategoryColor(catId) {
    const cat = CATEGORIES.find(c => c.id === catId);
    return cat ? cat.color : '#64748B';
  }

  function getCategoryBg(catId) {
    const cat = CATEGORIES.find(c => c.id === catId);
    return cat ? `${cat.color}18` : '#F1F5F9';
  }

  function getFrequencyText(goal) {
    if (!goal.weekdays || goal.weekdays.length === 7) return 'Hằng ngày';
    if (goal.weekdays.length === 5 && !goal.weekdays.includes(0) && !goal.weekdays.includes(6)) {
      return 'Thứ 2 - Thứ 6';
    }
    const dayNames = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return goal.weekdays.map(d => dayNames[d]).join(', ');
  }

  function escapeHTML(str) {
    if (!str) return '';
    return str
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#039;');
  }

  // --- Attach Event Listeners ---
  function setupEventListeners() {
    // Navigation
    DOM.navItems.forEach(item => {
      item.addEventListener('click', () => {
        switchTab(item.dataset.tab);
      });
    });

    // Date nav
    DOM.btnPrevDate.addEventListener('click', () => {
      const d = parseDate(state.currentDateStr);
      d.setDate(d.getDate() - 1);
      state.currentDateStr = formatDate(d);
      renderTodayTab();
    });

    DOM.btnNextDate.addEventListener('click', () => {
      const d = parseDate(state.currentDateStr);
      d.setDate(d.getDate() + 1);
      state.currentDateStr = formatDate(d);
      renderTodayTab();
    });

    // Calendar month nav
    DOM.calPrevMonth.addEventListener('click', () => {
      state.calendarMonth--;
      if (state.calendarMonth < 0) {
        state.calendarMonth = 11;
        state.calendarYear--;
      }
      renderCalendarGrid();
    });

    DOM.calNextMonth.addEventListener('click', () => {
      state.calendarMonth++;
      if (state.calendarMonth > 11) {
        state.calendarMonth = 0;
        state.calendarYear++;
      }
      renderCalendarGrid();
    });

    // FAB & Add Goal
    DOM.fabAddGoal.addEventListener('click', () => openGoalModal());
    DOM.btnOpenAddGoal.addEventListener('click', () => openGoalModal());
    window.appOpenAddGoal = () => openGoalModal();

    // Goal Form
    DOM.formGoal.addEventListener('submit', saveGoalFromForm);
    DOM.btnCloseGoalModal.addEventListener('click', closeGoalModal);
    DOM.btnDeleteGoal.addEventListener('click', () => {
      if (state.editingGoalId) confirmDeleteGoal(state.editingGoalId);
    });

    // Note Modal
    DOM.btnSaveNote.addEventListener('click', saveNote);
    DOM.btnCloseNoteModal.addEventListener('click', closeNoteModal);

    // Calendar Day Checkin Modal
    if (DOM.btnOpenDayCheckinModal) {
      DOM.btnOpenDayCheckinModal.addEventListener('click', () => {
        openDayCheckinModal(state.selectedCalendarDateStr);
      });
    }
    if (DOM.calSelectedDayBanner) {
      DOM.calSelectedDayBanner.addEventListener('click', (e) => {
        if (!e.target.closest('#btnOpenDayCheckinModal')) {
          openDayCheckinModal(state.selectedCalendarDateStr);
        }
      });
    }
    if (DOM.btnCloseDayCheckinModal) {
      DOM.btnCloseDayCheckinModal.addEventListener('click', closeDayCheckinModal);
    }
    if (DOM.btnDoneDayCheckin) {
      DOM.btnDoneDayCheckin.addEventListener('click', closeDayCheckinModal);
    }

    // Settings
    DOM.btnExportData.addEventListener('click', exportData);
    DOM.btnImportData.addEventListener('click', () => DOM.fileImport.click());
    DOM.fileImport.addEventListener('change', importData);
    DOM.btnResetData.addEventListener('click', resetAllData);
    DOM.btnLoadSampleData.addEventListener('click', loadSampleData);

    // Click date-display to jump back to today
    if (DOM.dateDisplay) {
      DOM.dateDisplay.addEventListener('click', () => {
        state.currentDateStr = formatDate(new Date());
        renderTodayTab();
        showToast('Đã quay về hôm nay');
      });
    }

    // Close modal on click outside
    window.addEventListener('click', (e) => {
      if (e.target === DOM.modalGoal) closeGoalModal();
      if (e.target === DOM.modalNote) closeNoteModal();
      if (e.target === DOM.modalDayCheckin) closeDayCheckinModal();
    });

    // Close modal on Escape key
    window.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        closeGoalModal();
        closeNoteModal();
        closeDayCheckinModal();
      }
    });

    // Window resize for chart
    window.addEventListener('resize', () => {
      if (state.activeTab === 'tab-calendar') renderChart();
    });
  }

  // --- App Initialization ---
  function init() {
    initDOMElements();
    Storage.initSampleDataIfEmpty();
    setupEventListeners();
    renderTodayTab();
    renderGoalsTab();
    renderCalendarTab();
  }

  // Run when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
