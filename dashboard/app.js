document.addEventListener('DOMContentLoaded', () => {
    const kpiCalls = document.getElementById('kpi-calls');
    let calls = 1245302;
    
    // Simulate real-time data updates
    setInterval(() => {
        calls += Math.floor(Math.random() * 10);
        kpiCalls.innerText = calls.toLocaleString();
        
        // Randomly animate bars
        document.querySelectorAll('.bar').forEach(bar => {
            const newHeight = 30 + Math.random() * 70;
            bar.style.height = newHeight + '%';
        });
    }, 2000);

    // Environment toggle
    document.getElementById('envSelect').addEventListener('change', (e) => {
        const env = e.target.value;
        if(env === 'PROD') {
            document.documentElement.style.setProperty('--bg-color', '#050714');
        } else if (env === 'STAGING') {
            document.documentElement.style.setProperty('--bg-color', '#1a1025');
        } else {
            document.documentElement.style.setProperty('--bg-color', '#0a0e27');
        }
    });
});
