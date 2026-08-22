import React, { useEffect, useMemo, useState } from 'react';
import {
  addDoc,
  collection,
  collectionGroup,
  doc,
  getDoc,
  onSnapshot,
  orderBy,
  query,
  serverTimestamp,
  updateDoc,
} from 'firebase/firestore';
import { getToken } from 'firebase/messaging';
import { httpsCallable } from 'firebase/functions';
import {
  Activity,
  AlertCircle,
  Bell,
  Building2,
  CalendarCheck,
  Check,
  ChevronRight,
  Droplet,
  Eye,
  EyeOff,
  HelpCircle,
  LayoutDashboard,
  LogOut,
  MapPin,
  Megaphone,
  Phone,
  Plus,
  RefreshCw,
  Search,
  Settings,
  ShieldCheck,
  UserRound,
  UsersRound,
  X,
} from 'lucide-react';
import { onAuthStateChanged, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import { auth, db, functions, messagingPromise } from './firebase';

const bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
const districts = [
  'All Districts',
  'Ampara',
  'Anuradhapura',
  'Badulla',
  'Batticaloa',
  'Colombo',
  'Galle',
  'Gampaha',
  'Hambantota',
  'Jaffna',
  'Kalutara',
  'Kandy',
  'Kegalle',
  'Kilinochchi',
  'Kurunegala',
  'Mannar',
  'Matale',
  'Matara',
  'Monaragala',
  'Mullaitivu',
  'Nuwara Eliya',
  'Polonnaruwa',
  'Puttalam',
  'Ratnapura',
  'Trincomalee',
  'Vavuniya',
];

const tabs = [
  { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
  { id: 'post', label: 'Post Request', icon: Plus },
  { id: 'requests', label: 'Requests', icon: MapPin },
  { id: 'donors', label: 'Donors', icon: UsersRound },
  { id: 'alerts', label: 'Group Alerts', icon: Bell },
  { id: 'centers', label: 'Donation Centers', icon: Building2 },
  { id: 'eligibility', label: 'Eligibility', icon: CalendarCheck },
  { id: 'summary', label: 'Blood Summary', icon: Droplet },
  { id: 'settings', label: 'Settings', icon: Settings },
  { id: 'help', label: 'Help Center', icon: HelpCircle },
];

function toDate(value) {
  if (!value) return null;
  if (typeof value.toDate === 'function') return value.toDate();
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

function formatDate(value) {
  const date = toDate(value);
  if (!date) return 'Not set';
  return new Intl.DateTimeFormat('en-LK', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  }).format(date);
}

function formatDateTime(value) {
  const date = toDate(value);
  if (!date) return 'Just now';
  return new Intl.DateTimeFormat('en-LK', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date);
}

function normalize(value) {
  return (value || '').toString().trim().toLowerCase();
}

function useCollection(path, sortField = null, sortDirection = 'desc') {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    const ref = collection(db, path);
    const q = sortField ? query(ref, orderBy(sortField, sortDirection)) : ref;
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        setItems(snapshot.docs.map((item) => ({ id: item.id, ...item.data() })));
        setLoading(false);
        setError('');
      },
      (err) => {
        setError(err.message);
        setLoading(false);
      },
    );

    return unsubscribe;
  }, [path, sortDirection, sortField]);

  return { items, loading, error };
}

function useDonationUnits() {
  const [units, setUnits] = useState(0);

  useEffect(() => {
    const unsubscribe = onSnapshot(collectionGroup(db, 'donations'), (snapshot) => {
      const total = snapshot.docs.reduce((sum, item) => {
        const value = Number(item.data().patientCount || 0);
        return sum + (Number.isFinite(value) ? value : 0);
      }, 0);
      setUnits(total);
    });

    return unsubscribe;
  }, []);

  return units;
}

export default function App() {
  const [user, setUser] = useState(null);
  const [checkingUser, setCheckingUser] = useState(true);
  const [activeTab, setActiveTab] = useState('dashboard');
  const [toast, setToast] = useState(null);

  const donors = useCollection('donors', 'registeredAt', 'desc');
  const requests = useCollection('emergency_request', 'createdAt', 'desc');
  const centers = useCollection('donation_center', 'centerName', 'asc');
  const units = useDonationUnits();

  useEffect(() => {
    return onAuthStateChanged(auth, async (currentUser) => {
      if (!currentUser) {
        setUser(null);
        setCheckingUser(false);
        return;
      }

      const roleDoc = await getDoc(doc(db, 'users', currentUser.uid));
      const role = normalize(roleDoc.data()?.role);
      if (role !== 'admin') {
        await signOut(auth);
        setUser(null);
        setToast({ type: 'error', message: 'Access denied. Admin role required.' });
      } else {
        setUser(currentUser);
      }
      setCheckingUser(false);
    });
  }, []);

  const stats = useMemo(
    () => ({
      requests: requests.items.length,
      donors: donors.items.length,
      units,
      centers: centers.items.length,
      openRequests: requests.items.filter((item) => item.status !== 'closed').length,
    }),
    [centers.items.length, donors.items.length, requests.items, units],
  );

  if (checkingUser) {
    return <Splash />;
  }

  if (!user) {
    return <LoginScreen setToast={setToast} toast={toast} />;
  }

  const shared = { donors, requests, centers, units, stats, setToast, setActiveTab };
  return (
    <div className="app-shell">
      <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} />
      <main className="main-panel">
        <Header user={user} stats={stats} setToast={setToast} />
        <section className="content">
          {activeTab === 'dashboard' && <Dashboard {...shared} />}
          {activeTab === 'post' && <PostRequest setToast={setToast} />}
          {activeTab === 'requests' && <RequestsView requests={requests} setToast={setToast} />}
          {activeTab === 'donors' && <DonorsView donors={donors} />}
          {activeTab === 'alerts' && <GroupAlerts setToast={setToast} />}
          {activeTab === 'centers' && <CentersView centers={centers} setToast={setToast} />}
          {activeTab === 'eligibility' && <EligibilityView donors={donors} />}
          {activeTab === 'summary' && <BloodSummary donors={donors} units={units} requests={requests} />}
          {activeTab === 'settings' && <SettingsView user={user} setToast={setToast} />}
          {activeTab === 'help' && <HelpView setActiveTab={setActiveTab} />}
        </section>
      </main>
      {toast && <Toast toast={toast} onClose={() => setToast(null)} />}
    </div>
  );
}

function Splash() {
  return (
    <div className="splash">
      <img src="/blood-lk-logo.png" alt="BloodLK" />
      <p>Loading admin panel...</p>
    </div>
  );
}

function LoginScreen({ setToast, toast }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  async function submit(event) {
    event.preventDefault();
    setLoading(true);
    try {
      const credential = await signInWithEmailAndPassword(auth, email.trim(), password);
      const roleDoc = await getDoc(doc(db, 'users', credential.user.uid));
      if (normalize(roleDoc.data()?.role) !== 'admin') {
        await signOut(auth);
        throw new Error('Access denied. Admin role required.');
      }
    } catch (error) {
      setToast({ type: 'error', message: error.message || 'Unable to sign in.' });
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="login-screen">
      <section className="login-hero-panel" aria-label="BloodLK admin overview">
        <div className="login-brand-row">
          <img src="/blood-lk-logo.png" alt="BloodLK" />
          <div>
            <strong>BloodLK</strong>
            <span>Admin Operations</span>
          </div>
        </div>
        <div className="login-copy">
          <span className="eyebrow">Secure dashboard</span>
          <h1>Coordinate urgent blood requests with confidence.</h1>
          <p>Manage donors, centers, alerts, and donation records from one protected admin workspace.</p>
        </div>
        <div className="login-feature-grid">
          <span><ShieldCheck size={18} /> Role protected</span>
          <span><Bell size={18} /> Push alerts</span>
          <span><UsersRound size={18} /> Donor records</span>
          <span><Building2 size={18} /> Center data</span>
        </div>
      </section>
      <form className="login-card" onSubmit={submit}>
        <div className="login-card-header">
          <img src="/blood-lk-logo.png" alt="BloodLK" />
          <span>Secure access</span>
        </div>
        <h1>Welcome Back</h1>
        <p>Sign in with your approved administrator account.</p>
        <label>
          Email
          <input value={email} onChange={(event) => setEmail(event.target.value)} type="email" required />
        </label>
        <label>
          Password
          <span className="password-box">
            <input
              value={password}
              onChange={(event) => setPassword(event.target.value)}
              type={showPassword ? 'text' : 'password'}
              required
            />
            <button type="button" onClick={() => setShowPassword((value) => !value)}>
              {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
            </button>
          </span>
        </label>
        <button className="primary-button" disabled={loading} type="submit">
          <ShieldCheck size={18} />
          {loading ? 'Checking...' : 'Sign In'}
        </button>
        <small className="login-note">Only approved administrators can open this panel.</small>
      </form>
      {toast && <Toast toast={toast} onClose={() => setToast(null)} />}
    </div>
  );
}

function Sidebar({ activeTab, setActiveTab }) {
  return (
    <aside className="sidebar">
      <div className="brand">
        <img src="/blood-lk-logo.png" alt="BloodLK" />
        <div>
          <strong>BloodLK</strong>
          <span>Admin Web</span>
        </div>
      </div>
      <nav>
        {tabs.map((tab) => {
          const Icon = tab.icon;
          return (
            <button
              key={tab.id}
              className={activeTab === tab.id ? 'active' : ''}
              onClick={() => setActiveTab(tab.id)}
            >
              <Icon size={19} />
              {tab.label}
            </button>
          );
        })}
      </nav>
    </aside>
  );
}

function Header({ user, stats, setToast }) {
  async function logout() {
    if (!window.confirm('Sign out from the admin panel?')) return;
    await signOut(auth);
    setToast({ type: 'success', message: 'Signed out successfully.' });
  }

  return (
    <header className="hero-header">
      <div>
        <span className="eyebrow">Secure operations</span>
        <h1>Admin Panel</h1>
        <p>Manage donor app operations, requests, alerts, and centers.</p>
        <small>{user.email}</small>
      </div>
      <div className="hero-actions">
        <div className="hero-pill">
          <Activity size={18} />
          {stats.openRequests} open requests
        </div>
        <button className="ghost-button light" onClick={logout}>
          <LogOut size={18} />
          Sign Out
        </button>
      </div>
      <div className="hero-visual" aria-hidden="true">
        <div className="hero-orbit">
          <Droplet size={42} />
        </div>
      </div>
    </header>
  );
}

function Dashboard({ donors, requests, centers, units, stats, setActiveTab }) {
  const latestRequest = requests.items[0];
  const cards = [
    { label: 'Requests', value: stats.requests, icon: Droplet },
    { label: 'Donors', value: stats.donors, icon: UsersRound },
    { label: 'Units', value: units, icon: Droplet },
    { label: 'Centers', value: stats.centers, icon: Building2 },
  ];
  const actions = tabs.filter((tab) => !['dashboard'].includes(tab.id)).slice(0, 9);

  return (
    <div className="page-grid">
      <section className="overview-card">
        <div className="section-title-row">
          <h2>Overview</h2>
          <button onClick={() => setActiveTab('summary')} className="soft-button">
            <Activity size={17} />
            View Reports
          </button>
        </div>
        <div className="stat-grid">
          {cards.map((card) => {
            const Icon = card.icon;
            return (
              <article className="stat-card" key={card.label}>
                <span><Icon size={24} /></span>
                <p>{card.label}</p>
                <strong>{card.value}</strong>
              </article>
            );
          })}
        </div>
      </section>

      <section>
        <h2 className="section-heading">Quick Actions</h2>
        <div className="action-grid">
          {actions.map((action) => {
            const Icon = action.icon;
            return (
              <button key={action.id} className="action-card" onClick={() => setActiveTab(action.id)}>
                <span><Icon size={30} /></span>
                <strong>{action.label}</strong>
              </button>
            );
          })}
        </div>
      </section>

      <button className="recent-card" onClick={() => setActiveTab('requests')}>
        <span><Activity size={26} /></span>
        <div>
          <strong>Recent Activity</strong>
          <p>
            {latestRequest
              ? `New ${latestRequest.bloodGroup || 'blood'} request at ${latestRequest.location || 'unknown location'}`
              : 'No emergency requests yet'}
          </p>
        </div>
        <ChevronRight />
      </button>
    </div>
  );
}

function PostRequest({ setToast }) {
  const [form, setForm] = useState({
    bloodGroup: 'A+',
    patientName: '',
    location: '',
    contactNumber: '',
    note: '',
  });
  const [loading, setLoading] = useState(false);

  function update(key, value) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  async function submit(event) {
    event.preventDefault();
    if (!window.confirm(`Post urgent ${form.bloodGroup} request? Matching donors will be notified.`)) return;
    setLoading(true);
    try {
      await addDoc(collection(db, 'emergency_request'), {
        ...form,
        status: 'open',
        createdAt: serverTimestamp(),
      });
      setForm({ bloodGroup: 'A+', patientName: '', location: '', contactNumber: '', note: '' });
      setToast({ type: 'success', message: 'Emergency request posted successfully.' });
    } catch (error) {
      setToast({ type: 'error', message: error.message });
    } finally {
      setLoading(false);
    }
  }

  return (
    <FormCard title="Post emergency request" icon={Plus} onSubmit={submit}>
      <div className="two-col">
        <label>Blood group<Select value={form.bloodGroup} onChange={(value) => update('bloodGroup', value)} options={bloodGroups} /></label>
        <label>Patient name<input value={form.patientName} onChange={(event) => update('patientName', event.target.value)} required /></label>
      </div>
      <label>Hospital or location<input value={form.location} onChange={(event) => update('location', event.target.value)} required /></label>
      <label>Contact number<input value={form.contactNumber} onChange={(event) => update('contactNumber', event.target.value)} required /></label>
      <label>Note<textarea value={form.note} onChange={(event) => update('note', event.target.value)} rows="4" /></label>
      <button className="primary-button" disabled={loading} type="submit">
        <Megaphone size={18} />
        {loading ? 'Posting...' : 'Post Request'}
      </button>
    </FormCard>
  );
}

function RequestsView({ requests, setToast }) {
  const [filter, setFilter] = useState('All');
  const visible = requests.items.filter((item) => filter === 'All' || item.bloodGroup === filter);

  async function closeRequest(item) {
    if (!window.confirm('Mark this request as closed?')) return;
    await updateDoc(doc(db, 'emergency_request', item.id), { status: 'closed' });
    setToast({ type: 'success', message: 'Request closed.' });
  }

  return (
    <PageCard title="Emergency Requests" icon={MapPin}>
      <Toolbar>
        <Select value={filter} onChange={setFilter} options={['All', ...bloodGroups]} />
      </Toolbar>
      <DataState source={requests} empty="No emergency requests available.">
        <div className="list">
          {visible.map((item) => (
            <article className="list-card" key={item.id}>
              <span className="round-icon"><Droplet size={22} /></span>
              <div>
                <strong>{item.bloodGroup} request for {item.patientName || 'patient'}</strong>
                <p>{item.location || 'No location'} - {item.contactNumber || 'No phone'}</p>
                <small>{item.note || 'No note'} - {formatDateTime(item.createdAt)}</small>
              </div>
              <span className={`status ${item.status === 'closed' ? 'muted' : ''}`}>{item.status || 'open'}</span>
              {item.status !== 'closed' && (
                <button className="icon-button" onClick={() => closeRequest(item)} title="Close request">
                  <Check size={18} />
                </button>
              )}
            </article>
          ))}
        </div>
      </DataState>
    </PageCard>
  );
}

function DonorsView({ donors }) {
  const [search, setSearch] = useState('');
  const [district, setDistrict] = useState('All Districts');
  const visible = donors.items.filter((donor) => {
    const text = `${donor.name} ${donor.phone} ${donor.nic} ${donor.bloodGroup} ${donor.city}`;
    const searchMatch = normalize(text).includes(normalize(search));
    const districtMatch = district === 'All Districts' || normalize(donor.city) === normalize(district);
    return searchMatch && districtMatch;
  });

  return (
    <PageCard title="Donors" icon={UsersRound}>
      <Toolbar>
        <SearchBox value={search} onChange={setSearch} placeholder="Search donor, phone, NIC, blood group..." />
        <Select value={district} onChange={setDistrict} options={districts} />
      </Toolbar>
      <DataState source={donors} empty="No donors available.">
        <div className="list">
          {visible.map((donor) => (
            <article className="list-card" key={donor.id}>
              <span className="round-icon"><UserRound size={22} /></span>
              <div>
                <strong>{donor.name || 'Unnamed donor'}</strong>
                <p>{donor.bloodGroup || 'N/A'} - {donor.city || 'No district'} - Age {donor.age || '-'}</p>
                <small>{donor.phone || 'No phone'} - Last donation: {formatDate(donor.lastDonationDate)}</small>
              </div>
              {donor.phone && (
                <a className="icon-button" href={`tel:${donor.phone}`} title="Call donor">
                  <Phone size={18} />
                </a>
              )}
            </article>
          ))}
        </div>
      </DataState>
    </PageCard>
  );
}

function GroupAlerts({ setToast }) {
  const [selected, setSelected] = useState([]);
  const [message, setMessage] = useState('');
  const [loading, setLoading] = useState(false);

  function toggle(group) {
    setSelected((current) =>
      current.includes(group) ? current.filter((item) => item !== group) : [...current, group],
    );
  }

  async function send() {
    if (selected.length === 0) {
      setToast({ type: 'error', message: 'Select at least one blood group.' });
      return;
    }
    if (!window.confirm(`Send group alert to ${selected.join(', ')} donors?`)) return;
    setLoading(true);
    try {
      const callable = httpsCallable(functions, 'sendGroupNotification');
      const results = [];
      for (const group of selected) {
        const response = await callable({ bloodType: group, messageContent: message.trim() });
        results.push(`${group}: ${response.data?.count || 0}`);
      }
      setToast({ type: 'success', message: `Alerts sent. ${results.join(', ')}` });
      setSelected([]);
      setMessage('');
    } catch (error) {
      setToast({ type: 'error', message: error.message });
    } finally {
      setLoading(false);
    }
  }

  return (
    <PageCard title="Group Alerts" icon={Bell}>
      <p className="muted-text">Choose one or more blood groups, confirm, and send urgent push alerts.</p>
      <div className="chip-grid">
        {bloodGroups.map((group) => (
          <button key={group} className={selected.includes(group) ? 'chip selected' : 'chip'} onClick={() => toggle(group)}>
            {group}
          </button>
        ))}
      </div>
      <label className="wide-label">Alert message<textarea rows="4" value={message} onChange={(event) => setMessage(event.target.value)} placeholder="Urgent blood request. Please contact the hospital if you can help." /></label>
      <button className="primary-button" disabled={loading} onClick={send}>
        <Bell size={18} />
        {loading ? 'Sending...' : 'Send Alert'}
      </button>
    </PageCard>
  );
}

function CentersView({ centers, setToast }) {
  const [search, setSearch] = useState('');
  const [district, setDistrict] = useState('All Districts');
  const [form, setForm] = useState({ centerName: '', contactNumber: '', address: '', district: 'Badulla' });
  const [loading, setLoading] = useState(false);
  const visible = centers.items.filter((center) => {
    const name = center.centerName || center.name || center.title || '';
    const phone = center.contactNumber || center.phone || center.mobile || '';
    const address = center.address || center.centerAddress || center.location || '';
    const area = center.district || center.city || '';
    const text = `${name} ${phone} ${address} ${area}`;
    return normalize(text).includes(normalize(search)) &&
      (district === 'All Districts' || normalize(area) === normalize(district));
  });

  async function submit(event) {
    event.preventDefault();
    setLoading(true);
    try {
      await addDoc(collection(db, 'donation_center'), {
        ...form,
        createdAt: serverTimestamp(),
      });
      setForm({ centerName: '', contactNumber: '', address: '', district: 'Badulla' });
      setToast({ type: 'success', message: 'Donation center saved.' });
    } catch (error) {
      setToast({ type: 'error', message: error.message });
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="split-grid">
      <FormCard title="Add Donation Center" icon={Building2} onSubmit={submit}>
        <label>Center name<input value={form.centerName} onChange={(event) => setForm({ ...form, centerName: event.target.value })} required /></label>
        <label>Contact number<input value={form.contactNumber} onChange={(event) => setForm({ ...form, contactNumber: event.target.value })} required /></label>
        <label>Address<textarea rows="3" value={form.address} onChange={(event) => setForm({ ...form, address: event.target.value })} required /></label>
        <label>District<Select value={form.district} onChange={(value) => setForm({ ...form, district: value })} options={districts.filter((item) => item !== 'All Districts')} /></label>
        <button className="primary-button" disabled={loading} type="submit">
          <Plus size={18} />
          {loading ? 'Saving...' : 'Save Center'}
        </button>
      </FormCard>
      <PageCard title="Center Directory" icon={Building2}>
        <Toolbar>
          <SearchBox value={search} onChange={setSearch} placeholder="Search center..." />
          <Select value={district} onChange={setDistrict} options={districts} />
        </Toolbar>
        <DataState source={centers} empty="No donation centers available.">
          <div className="list">
            {visible.map((center) => {
              const name = center.centerName || center.name || center.title || 'Unnamed center';
              const phone = center.contactNumber || center.phone || center.mobile || '';
              const address = center.address || center.centerAddress || center.location || '';
              const area = center.district || center.city || '';
              return (
                <article className="list-card" key={center.id}>
                  <span className="round-icon"><Building2 size={22} /></span>
                  <div>
                    <strong>{name}</strong>
                    <p>{address || 'No address'}</p>
                    <small>{area || 'No district'} - {phone || 'No phone'}</small>
                  </div>
                  {phone && <a className="icon-button" href={`tel:${phone}`}><Phone size={18} /></a>}
                </article>
              );
            })}
          </div>
        </DataState>
      </PageCard>
    </div>
  );
}

function EligibilityView({ donors }) {
  const eligibleDate = (lastDate) => {
    const date = toDate(lastDate);
    if (!date) return new Date();
    const next = new Date(date);
    next.setDate(next.getDate() + 150);
    return next;
  };

  const rows = donors.items
    .map((donor) => ({ ...donor, nextEligible: eligibleDate(donor.lastDonationDate) }))
    .sort((a, b) => a.nextEligible - b.nextEligible);

  return (
    <PageCard title="Eligibility" icon={CalendarCheck}>
      <div className="list">
        {rows.map((donor) => {
          const ready = donor.nextEligible <= new Date();
          return (
            <article className="list-card" key={donor.id}>
              <span className="round-icon"><CalendarCheck size={22} /></span>
              <div>
                <strong>{donor.name || 'Unnamed donor'}</strong>
                <p>{donor.bloodGroup || 'N/A'} - {donor.city || 'No district'}</p>
                <small>Next eligible: {formatDate(donor.nextEligible)}</small>
              </div>
              <span className={`status ${ready ? '' : 'muted'}`}>{ready ? 'Ready' : 'Waiting'}</span>
            </article>
          );
        })}
      </div>
    </PageCard>
  );
}

function BloodSummary({ donors, units, requests }) {
  const byGroup = bloodGroups.map((group) => ({
    group,
    donors: donors.items.filter((item) => item.bloodGroup === group).length,
    requests: requests.items.filter((item) => item.bloodGroup === group).length,
  }));

  return (
    <PageCard title="Blood Summary" icon={Droplet}>
      <div className="summary-banner">
        <strong>{units}</strong>
        <span>Total donated units recorded from donor history.</span>
      </div>
      <div className="blood-grid">
        {byGroup.map((item) => (
          <article className="blood-card" key={item.group}>
            <strong>{item.group}</strong>
            <p>{item.donors} donors</p>
            <span>{item.requests} requests</span>
          </article>
        ))}
      </div>
    </PageCard>
  );
}

function SettingsView({ user, setToast }) {
  const [permission, setPermission] = useState(Notification.permission || 'default');

  async function requestPermission() {
    const result = await Notification.requestPermission();
    setPermission(result);
    setToast({ type: result === 'granted' ? 'success' : 'error', message: `Notification permission: ${result}` });
  }

  async function copyToken() {
    try {
      const messaging = await messagingPromise;
      if (!messaging) throw new Error('Messaging is not supported in this browser.');
      const vapidKey = import.meta.env.VITE_FIREBASE_VAPID_KEY;
      if (!vapidKey) throw new Error('Add VITE_FIREBASE_VAPID_KEY to enable web FCM token generation.');
      const token = await getToken(messaging, { vapidKey });
      await navigator.clipboard.writeText(token);
      setToast({ type: 'success', message: 'Admin device FCM token copied.' });
    } catch (error) {
      setToast({ type: 'error', message: error.message });
    }
  }

  return (
    <PageCard title="Settings" icon={Settings}>
      <div className="settings-list">
        <SettingRow icon={ShieldCheck} title="Signed in admin" value={user.email} />
        <SettingRow icon={Bell} title="Notification permission" value={permission}>
          <button className="soft-button" onClick={requestPermission}><RefreshCw size={16} /> Check</button>
        </SettingRow>
        <SettingRow icon={Megaphone} title="Web FCM token" value="Requires VITE_FIREBASE_VAPID_KEY">
          <button className="soft-button" onClick={copyToken}>Copy Token</button>
        </SettingRow>
        <SettingRow icon={Building2} title="System data" value="Donors, requests, centers, settings, and notification records" />
      </div>
    </PageCard>
  );
}

function HelpView({ setActiveTab }) {
  const items = [
    ['Emergency requests', 'Post only verified hospital or patient requests.', 'requests', MapPin],
    ['Group alerts', 'Send alerts after confirming blood group and request details.', 'alerts', Bell],
    ['Donation centers', 'Keep center phone numbers, addresses, and districts updated.', 'centers', Building2],
    ['Donor data', 'Use donor records only for blood donation coordination.', 'donors', UsersRound],
    ['Settings', 'Check notification and system details.', 'settings', Settings],
  ];

  return (
    <PageCard title="Help Center" icon={HelpCircle}>
      <div className="help-list">
        {items.map(([title, text, tab, Icon]) => (
          <button key={title} className="help-item" onClick={() => setActiveTab(tab)}>
            <span className="round-icon"><Icon size={22} /></span>
            <div>
              <strong>{title}</strong>
              <p>{text}</p>
            </div>
            <ChevronRight />
          </button>
        ))}
      </div>
    </PageCard>
  );
}

function PageCard({ title, icon: Icon, children }) {
  return (
    <section className="panel-card">
      <div className="page-title">
        <span><Icon size={24} /></span>
        <h2>{title}</h2>
      </div>
      {children}
    </section>
  );
}

function FormCard({ title, icon: Icon, onSubmit, children }) {
  return (
    <form className="panel-card form-card" onSubmit={onSubmit}>
      <div className="page-title">
        <span><Icon size={24} /></span>
        <h2>{title}</h2>
      </div>
      {children}
    </form>
  );
}

function DataState({ source, empty, children }) {
  if (source.loading) return <EmptyState icon={RefreshCw} title="Loading..." message="Getting the latest records." />;
  if (source.error) return <EmptyState icon={AlertCircle} title="Unable to load" message={source.error} />;
  if (source.items.length === 0) return <EmptyState icon={AlertCircle} title={empty} message="New records will appear here automatically." />;
  return children;
}

function EmptyState({ icon: Icon, title, message }) {
  return (
    <div className="empty-state">
      <span><Icon size={28} /></span>
      <strong>{title}</strong>
      <p>{message}</p>
    </div>
  );
}

function Toolbar({ children }) {
  return <div className="toolbar">{children}</div>;
}

function SearchBox({ value, onChange, placeholder }) {
  return (
    <label className="search-box">
      <Search size={18} />
      <input value={value} onChange={(event) => onChange(event.target.value)} placeholder={placeholder} />
    </label>
  );
}

function Select({ value, onChange, options }) {
  return (
    <select value={value} onChange={(event) => onChange(event.target.value)}>
      {options.map((option) => <option key={option} value={option}>{option}</option>)}
    </select>
  );
}

function SettingRow({ icon: Icon, title, value, children }) {
  return (
    <article className="setting-row">
      <span className="round-icon"><Icon size={22} /></span>
      <div>
        <strong>{title}</strong>
        <p>{value}</p>
      </div>
      {children}
    </article>
  );
}

function Toast({ toast, onClose }) {
  useEffect(() => {
    const timer = window.setTimeout(onClose, 4200);
    return () => window.clearTimeout(timer);
  }, [onClose]);

  return (
    <div className={`toast ${toast.type}`}>
      <span>{toast.type === 'success' ? <Check size={18} /> : <AlertCircle size={18} />}</span>
      {toast.message}
      <button onClick={onClose}><X size={16} /></button>
    </div>
  );
}

