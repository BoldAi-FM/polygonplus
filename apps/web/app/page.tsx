export default function Home() {
  return (
    <main className="wrap">
      <div className="badge">Fase 0 · Cascarón</div>
      <h1>
        Polygon<span>Plus</span>
      </h1>
      <p className="lead">Ecosistema operativo automatizado para Polygon.</p>
      <p className="principle">
        No robotizamos la agencia. Liberamos a las mentes creativas para que
        creen y decidan.
      </p>

      <div className="grid">
        <div className="card">
          <h3>Capa 1 · Operativa</h3>
          <p>Planeación, coordinación y dashboards por marca.</p>
        </div>
        <div className="card">
          <h3>Núcleo de conocimiento</h3>
          <p>Procesos y clientes documentados. Cero dependencia de personas clave.</p>
        </div>
        <div className="card">
          <h3>Agentes</h3>
          <p>Lo repetitivo lo hacen los agentes; las personas dirigen.</p>
        </div>
      </div>

      <footer>Vercel · Supabase · Railway · GitHub — v0.0.1</footer>
    </main>
  );
}
