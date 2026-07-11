import { useEffect, useState } from "react";
import api from "../services/api";

function Dashboard({ setToken }) {
  const [files, setFiles] = useState([]);
  const [fileName, setFileName] = useState("");
  const [category, setCategory] = useState("");
  const [size, setSize] = useState("");
  const [loading, setLoading] = useState(false);

  const currentUser = localStorage.getItem("user");

  useEffect(() => {
    loadFiles();
  }, []);

  async function loadFiles() {
    try {
      setLoading(true);
      const response = await api.get("/files");
      setFiles(response.data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  }

  async function createFile() {
    if (!fileName || !category || !size) {
      alert("Todos los campos son obligatorios");
      return;
    }
    try {
      await api.post("/files", { fileName, category, size });
      setFileName("");
      setCategory("");
      setSize("");
      // Lab 9: mensaje encolado, esperar un momento antes de recargar
      setTimeout(() => loadFiles(), 2000);
    } catch (error) {
      console.error(error);
      alert("Error creando archivo");
    }
  }

  async function deleteFile(id) {
    try {
      await api.delete(`/files/${id}`);
      loadFiles();
    } catch (error) {
      console.error(error);
      alert("Error eliminando archivo");
    }
  }

  function logout() {
    localStorage.clear();
    setToken(null);
  }

  const totalFiles = files.length;
  const totalPdf = files.filter((f) => f.category === "PDF").length;
  const totalImages = files.filter((f) => f.category === "Imagen").length;
  const totalSize = files.reduce((acc, f) => acc + Number(f.size || 0), 0);

  return (
    <div className="container mt-4">
      <div className="d-flex justify-content-between align-items-center mb-4">
        <div>
          <h1>CloudBox Enterprise</h1>
          <p>
            Bienvenido: <strong>{currentUser}</strong>
          </p>
        </div>
        <button className="btn btn-danger" onClick={logout}>
          Cerrar Sesión
        </button>
      </div>

      {/* Métricas */}
      <div className="row mb-4">
        {[
          { label: "Total Archivos", value: totalFiles },
          { label: "PDFs", value: totalPdf },
          { label: "Imágenes", value: totalImages },
          { label: "Tamaño Total", value: totalSize }
        ].map((m) => (
          <div className="col-md-3" key={m.label}>
            <div className="card metric-card p-3">
              <h6>{m.label}</h6>
              <h2>{m.value}</h2>
            </div>
          </div>
        ))}
      </div>

      {/* Formulario de registro */}
      <div className="card p-4 mb-4">
        <h4>Registrar Documento</h4>
        <div className="row">
          <div className="col-md-4">
            <input
              className="form-control"
              placeholder="Nombre"
              value={fileName}
              onChange={(e) => setFileName(e.target.value)}
            />
          </div>
          <div className="col-md-4">
            <input
              className="form-control"
              placeholder="Categoría"
              value={category}
              onChange={(e) => setCategory(e.target.value)}
            />
          </div>
          <div className="col-md-2">
            <input
              className="form-control"
              placeholder="Tamaño"
              value={size}
              onChange={(e) => setSize(e.target.value)}
            />
          </div>
          <div className="col-md-2">
            <button className="btn btn-success w-100" onClick={createFile}>
              Guardar
            </button>
          </div>
        </div>
      </div>

      {/* Inventario */}
      <div className="card p-4">
        <h4>Inventario Documental</h4>
        {loading ? (
          <p>Cargando...</p>
        ) : (
          <table className="table table-striped table-hover">
            <thead>
              <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>Categoría</th>
                <th>Tamaño</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              {files.map((file) => (
                <tr key={file.fileId}>
                  <td>{file.fileId}</td>
                  <td>{file.fileName}</td>
                  <td>{file.category}</td>
                  <td>{file.size}</td>
                  <td>
                    <button
                      className="btn btn-danger btn-sm"
                      onClick={() => deleteFile(file.fileId)}
                    >
                      Eliminar
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

export default Dashboard;
