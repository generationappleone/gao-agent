---
name: Consent Management
description: Skill for implementing consent management UI and backend — cookie consent banners, granular consent toggles, consent API, audit trails, GTM consent mode, age verification, and UU PDP compliance.
---

# Consent Management Skill

## Overview
Consent management is the technical implementation of user privacy preferences. Under UU PDP, consent must be **explicit, specific, informed, freely given, and withdrawable**. This skill covers both frontend (consent UI) and backend (consent storage, audit, enforcement).

---

## 1. Cookie Consent Banner (Frontend)

### React Component
```tsx
import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface ConsentPreferences {
  necessary: boolean;     // Always true, cannot be disabled
  analytics: boolean;
  marketing: boolean;
  personalization: boolean;
}

const DEFAULT_PREFERENCES: ConsentPreferences = {
  necessary: true,
  analytics: false,
  marketing: false,
  personalization: false,
};

export function CookieConsentBanner() {
  const [isVisible, setIsVisible] = useState(false);
  const [showDetails, setShowDetails] = useState(false);
  const [preferences, setPreferences] = useState<ConsentPreferences>(DEFAULT_PREFERENCES);

  useEffect(() => {
    const stored = localStorage.getItem('consent_preferences');
    if (!stored) {
      setIsVisible(true);
    } else {
      setPreferences(JSON.parse(stored));
    }
  }, []);

  const handleAcceptAll = () => {
    const all: ConsentPreferences = {
      necessary: true, analytics: true, marketing: true, personalization: true,
    };
    saveConsent(all);
  };

  const handleRejectAll = () => {
    const minimal: ConsentPreferences = {
      necessary: true, analytics: false, marketing: false, personalization: false,
    };
    saveConsent(minimal);
  };

  const handleSavePreferences = () => {
    saveConsent(preferences);
  };

  const saveConsent = async (prefs: ConsentPreferences) => {
    localStorage.setItem('consent_preferences', JSON.stringify(prefs));
    localStorage.setItem('consent_timestamp', new Date().toISOString());
    setPreferences(prefs);
    setIsVisible(false);

    // Send to backend for audit trail
    await fetch('/api/v1/consent', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        preferences: prefs,
        policyVersion: CURRENT_POLICY_VERSION,
      }),
    });

    // Update GTM consent mode
    updateGTMConsent(prefs);
  };

  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          initial={{ y: 100, opacity: 0 }}
          animate={{ y: 0, opacity: 1 }}
          exit={{ y: 100, opacity: 0 }}
          className="consent-banner"
          role="dialog"
          aria-label="Cookie consent"
          aria-describedby="consent-description"
        >
          <div className="consent-banner__content">
            <h3 className="consent-banner__title">🍪 Privacy & Cookie Policy</h3>
            <p id="consent-description" className="consent-banner__text">
              We use cookies to improve your experience. In accordance with
              Indonesia's Personal Data Protection Law (UU No. 27/2022), we require your consent
              before processing personal data for specific purposes.
            </p>

            {showDetails && (
              <div className="consent-banner__details">
                <ConsentToggle
                  label="Necessary"
                  description="Cookies required for basic site functionality"
                  checked={true}
                  disabled={true}
                />
                <ConsentToggle
                  label="Analytics"
                  description="Helps us understand site usage (Google Analytics)"
                  checked={preferences.analytics}
                  onChange={(v) => setPreferences({ ...preferences, analytics: v })}
                />
                <ConsentToggle
                  label="Marketing"
                  description="Cookies for relevant advertising (Meta Pixel, TikTok)"
                  checked={preferences.marketing}
                  onChange={(v) => setPreferences({ ...preferences, marketing: v })}
                />
                <ConsentToggle
                  label="Personalization"
                  description="Customizes content based on your preferences"
                  checked={preferences.personalization}
                  onChange={(v) => setPreferences({ ...preferences, personalization: v })}
                />
              </div>
            )}

            <div className="consent-banner__actions">
              <button onClick={handleRejectAll} className="btn-ghost">
                Reject All
              </button>
              <button onClick={() => setShowDetails(!showDetails)} className="btn-outline">
                {showDetails ? 'Hide' : 'Manage Preferences'}
              </button>
              {showDetails ? (
                <button onClick={handleSavePreferences} className="btn-primary">
                  Save Preferences
                </button>
              ) : (
                <button onClick={handleAcceptAll} className="btn-primary">
                  Accept All
                </button>
              )}
            </div>

            <p className="consent-banner__link">
              Read more in our <a href="/privacy-policy">Privacy Policy</a>.
            </p>
          </div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

### Consent Toggle Component
```tsx
interface ConsentToggleProps {
  label: string;
  description: string;
  checked: boolean;
  disabled?: boolean;
  onChange?: (value: boolean) => void;
}

function ConsentToggle({ label, description, checked, disabled, onChange }: ConsentToggleProps) {
  return (
    <div className="consent-toggle">
      <div className="consent-toggle__info">
        <span className="consent-toggle__label">{label}</span>
        <span className="consent-toggle__desc">{description}</span>
      </div>
      <label className="toggle-switch">
        <input
          type="checkbox"
          checked={checked}
          disabled={disabled}
          onChange={(e) => onChange?.(e.target.checked)}
          aria-label={`${label}: ${description}`}
        />
        <span className="toggle-switch__slider" />
      </label>
    </div>
  );
}
```

### CSS Styling
```css
/* ✅ Premium consent banner styling */
.consent-banner {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 9999;
  padding: var(--space-6);
  background: rgba(15, 23, 42, 0.97);
  backdrop-filter: blur(16px);
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  color: #f1f5f9;
}

.consent-banner__content {
  max-width: 960px;
  margin: 0 auto;
}

.consent-banner__title {
  font-size: 1.125rem;
  font-weight: 700;
  margin-bottom: var(--space-2);
}

.consent-banner__text {
  font-size: 0.875rem;
  color: #94a3b8;
  line-height: 1.6;
  margin-bottom: var(--space-4);
}

.consent-banner__actions {
  display: flex;
  gap: var(--space-3);
  flex-wrap: wrap;
}

.consent-banner__details {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);
  padding: var(--space-4);
  margin-bottom: var(--space-4);
  background: rgba(255, 255, 255, 0.05);
  border-radius: var(--radius-lg);
  border: 1px solid rgba(255, 255, 255, 0.08);
}

.consent-toggle {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-4);
}

.consent-toggle__label {
  font-size: 0.875rem;
  font-weight: 600;
  display: block;
}

.consent-toggle__desc {
  font-size: 0.75rem;
  color: #94a3b8;
  display: block;
  margin-top: 2px;
}

.consent-banner__link {
  font-size: 0.75rem;
  color: #64748b;
  margin-top: var(--space-3);
}

.consent-banner__link a {
  color: #818cf8;
  text-decoration: underline;
}
```

---

## 2. Google Tag Manager Consent Mode

```typescript
// ✅ REQUIRED: GTM Consent Mode v2
declare global {
  interface Window {
    dataLayer: Record<string, unknown>[];
    gtag: (...args: unknown[]) => void;
  }
}

// Initialize with denied by default
function initGTMConsent(): void {
  window.dataLayer = window.dataLayer || [];
  window.gtag = function gtag() {
    window.dataLayer.push(arguments as unknown as Record<string, unknown>);
  };

  // Default: deny all until user consents
  window.gtag('consent', 'default', {
    analytics_storage: 'denied',
    ad_storage: 'denied',
    ad_user_data: 'denied',
    ad_personalization: 'denied',
    functionality_storage: 'granted',    // necessary
    security_storage: 'granted',         // necessary
    wait_for_update: 500,
  });
}

// Update consent based on user preferences
function updateGTMConsent(prefs: ConsentPreferences): void {
  window.gtag('consent', 'update', {
    analytics_storage: prefs.analytics ? 'granted' : 'denied',
    ad_storage: prefs.marketing ? 'granted' : 'denied',
    ad_user_data: prefs.marketing ? 'granted' : 'denied',
    ad_personalization: prefs.personalization ? 'granted' : 'denied',
  });
}
```

---

## 3. Third-Party Script Control

```typescript
// ✅ REQUIRED: Block/unblock third-party scripts based on consent

function loadConditionalScripts(preferences: ConsentPreferences): void {
  // Google Analytics — requires analytics consent
  if (preferences.analytics) {
    loadScript('https://www.googletagmanager.com/gtag/js?id=G-XXXXXXX');
  }

  // Meta Pixel — requires marketing consent
  if (preferences.marketing) {
    loadScript('https://connect.facebook.net/en_US/fbevents.js');
  }

  // TikTok Pixel — requires marketing consent
  if (preferences.marketing) {
    loadScript('https://analytics.tiktok.com/i18n/pixel/events.js');
  }
}

function loadScript(src: string): void {
  const script = document.createElement('script');
  script.src = src;
  script.async = true;
  document.head.appendChild(script);
}

// Remove scripts when consent is withdrawn
function removeTrackers(): void {
  // Clear GA cookies
  document.cookie.split(';').forEach((c) => {
    const name = c.trim().split('=')[0];
    if (name.startsWith('_ga') || name.startsWith('_gid')) {
      document.cookie = `${name}=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/`;
    }
  });
}
```

---

## 4. Backend Consent API

```typescript
// ✅ REQUIRED: Consent CRUD endpoints

// POST /api/v1/consent
interface GrantConsentBody {
  preferences: {
    analytics: boolean;
    marketing: boolean;
    personalization: boolean;
  };
  policyVersion: string;
}

async function grantConsent(userId: string, body: GrantConsentBody): Promise<void> {
  const { preferences, policyVersion } = body;

  for (const [type, granted] of Object.entries(preferences)) {
    await db.execute(`
      INSERT INTO consent_records (user_id, consent_type, purpose, granted, consent_version, granted_at, ip_address, user_agent)
      VALUES ($1, $2, $3, $4, $5, NOW(), $6, $7)
    `, [
      userId,
      type,
      CONSENT_PURPOSES[type],
      granted,
      policyVersion,
      req.ip,
      req.headers['user-agent'],
    ]);
  }
}

// GET /api/v1/consent
async function getConsentStatus(userId: string): Promise<ConsentStatus[]> {
  const records = await db.query<ConsentRecord[]>(`
    SELECT DISTINCT ON (consent_type) *
    FROM consent_records
    WHERE user_id = $1
    ORDER BY consent_type, created_at DESC
  `, [userId]);

  return records.map((r) => ({
    type: r.consent_type,
    purpose: r.purpose,
    granted: r.granted,
    grantedAt: r.granted_at?.toISOString() || null,
    policyVersion: r.consent_version,
  }));
}

// DELETE /api/v1/consent/:type
async function withdrawConsent(userId: string, type: string): Promise<void> {
  await db.execute(`
    INSERT INTO consent_records (user_id, consent_type, purpose, granted, consent_version, withdrawn_at, ip_address, user_agent)
    VALUES ($1, $2, $3, false, $4, NOW(), $5, $6)
  `, [userId, type, CONSENT_PURPOSES[type], CURRENT_POLICY_VERSION, req.ip, req.headers['user-agent']]);

  // Immediately stop processing for this type
  await disableProcessing(userId, type);
}

// GET /api/v1/consent/history
async function getConsentHistory(userId: string): Promise<ConsentRecord[]> {
  return db.query<ConsentRecord[]>(`
    SELECT consent_type, granted, consent_version, granted_at, withdrawn_at, created_at
    FROM consent_records
    WHERE user_id = $1
    ORDER BY created_at DESC
    LIMIT 100
  `, [userId]);
}
```

---

## 5. Age Verification (Data Anak — Pasal 25 UU PDP)

```
Rule: Processing personal data of children (< 18 years) requires:
      1. Age verification gate BEFORE data collection
      2. Parental/guardian consent
      3. Additional safeguards for data storage
      4. Limited data collection (strict minimization)
```

### Age Gate Component
```tsx
function AgeGate({ onVerified }: { onVerified: (isAdult: boolean) => void }) {
  const [birthDate, setBirthDate] = useState('');

  const handleVerify = () => {
    const age = calculateAge(new Date(birthDate));
    if (age >= 18) {
      onVerified(true);
    } else {
      // Show parental consent flow
      onVerified(false);
    }
  };

  return (
    <div className="age-gate" role="dialog" aria-label="Age verification">
      <h2>Age Verification</h2>
      <p>In accordance with the Personal Data Protection Law, we need to verify your age.</p>
      <label htmlFor="birthdate">Date of Birth</label>
      <input
        type="date"
        id="birthdate"
        value={birthDate}
        onChange={(e) => setBirthDate(e.target.value)}
        max={new Date().toISOString().split('T')[0]}
        required
      />
      <button onClick={handleVerify} className="btn-primary">Verify</button>
    </div>
  );
}

function calculateAge(birthDate: Date): number {
  const today = new Date();
  let age = today.getFullYear() - birthDate.getFullYear();
  const monthDiff = today.getMonth() - birthDate.getMonth();
  if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
}
```

---

## 6. Privacy Settings Page

### ✅ REQUIRED: Accessible Privacy Center

Every application MUST have a privacy settings page where users can:
1. View current consent status
2. Modify consent preferences
3. Request data export
4. Request data deletion
5. View privacy policy
6. Contact DPO

```
Route: /settings/privacy or /settings/privasi
```

---

## Best Practices

1. **Consent BEFORE processing** — never fire analytics before consent is granted
2. **Default to denied** — GTM consent mode default must be `denied`
3. **Bilingual UI** — provide consent UI in Bahasa Indonesia AND English
4. **Easy withdrawal** — withdrawing consent must be as easy as granting it
5. **Version tracking** — track which policy version the user consented to
6. **Re-consent on changes** — if privacy policy changes, request consent again
7. **Audit everything** — every consent action must be immutably logged
8. **Test consent flows** — include consent flows in E2E testing
9. **Mobile-friendly** — consent banner must work on all screen sizes
10. **No dark patterns** — "Reject All" must be as prominent as "Accept All"

## Rules Integration
- **UU PDP Rule**: Core compliance mechanism for consent requirements
- **UI/UX Rule**: Consent banner must follow design system, accessible, responsive
- **Security Rule**: Consent data encrypted, audit trail tamper-proof
- **Frontend Architecture Rule**: Consent state managed properly, not leaked across features
