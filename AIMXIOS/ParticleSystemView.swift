import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var speedY: CGFloat
    var speedX: CGFloat
    var opacity: Double
    var color: Color
}

struct ParticleSystemView: View {
    let particleCount: Int
    let baseColor: Color
    
    @State private var particles: [Particle] = []
    @State private var timer = Timer.publish(every: 0.04, on: .main, in: .common).autoconnect()

    init(count: Int = 35, color: Color = Color(red: 0.0, green: 1.0, blue: 0.8)) {
        self.particleCount = count
        self.baseColor = color
    }

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.x * size.width,
                        y: particle.y * size.height,
                        width: particle.scale * 12,
                        height: particle.scale * 12
                    )
                    var contextCopy = context
                    contextCopy.opacity = particle.opacity
                    contextCopy.addFilter(.blur(radius: particle.scale * 1.5))
                    contextCopy.fill(Path(ellipseIn: rect), with: .color(particle.color))
                }
            }
            .onAppear {
                createParticles()
            }
            .onReceive(timer) { _ in
                updateParticles()
            }
        }
        .ignoresSafeArea()
    }

    private func createParticles() {
        var newParticles: [Particle] = []
        let colors: [Color] = [
            baseColor,
            Color(red: 0.0, green: 0.9, blue: 1.0),
            Color(red: 0.6, green: 0.2, blue: 1.0),
            Color(red: 0.2, green: 1.0, blue: 0.5)
        ]

        for _ in 0..<particleCount {
            let p = Particle(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                scale: CGFloat.random(in: 0.3...1.8),
                speedY: CGFloat.random(in: -0.003...(-0.0008)),
                speedX: CGFloat.random(in: -0.001...0.001),
                opacity: Double.random(in: 0.25...0.85),
                color: colors.randomElement() ?? baseColor
            )
            newParticles.append(p)
        }
        self.particles = newParticles
    }

    private func updateParticles() {
        for i in 0..<particles.count {
            particles[i].y += particles[i].speedY
            particles[i].x += particles[i].speedX
            
            if particles[i].y < -0.05 {
                particles[i].y = 1.05
                particles[i].x = CGFloat.random(in: 0...1)
            }
            if particles[i].x < -0.05 { particles[i].x = 1.05 }
            if particles[i].x > 1.05 { particles[i].x = -0.05 }
        }
    }
}

