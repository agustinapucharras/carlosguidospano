
import './App.css'
import Navv from './components/layout/Navv'
import ButtonShowcase from './components/ui/Botones';

function App() {


  return (
    <>
    <Navv/>
    <ButtonShowcase/>
    
<div className="card">
          <div className="card-body">
            <h5 className="card-title">Gestión de Usuarios</h5>
            <p className="card-text">PRUEBA DE BOTONES .</p>
            <div className="d-flex gap-2">
              <button className="btn btn-primary">
                <i className="fas fa-user-plus"></i>
                Agregar Usuario
              </button>
              <button className="btn btn-secondary">
                <i className="fas fa-edit"></i>
                Editar
              </button>
              <button className="btn btn-danger">
                <i className="fas fa-trash"></i>
                Eliminar
              </button>
              <button className="btn btn-success">
                <i className="fas fa-check"></i>
                Guardar
              </button>
            </div>
          </div>
</div>
    </>
  )
}

export default App
