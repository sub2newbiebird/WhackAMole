import SwiftUI

struct ContentView: View {
    // 遊戲狀態變數
    @State private var score = 0
    @State private var timeLeft = 30
    @State private var isActive = false
    @State private var molePosition = -1 // -1 代表地鼠沒有出現，0~8 代表出現在哪個洞
    
    // 定時器：每 0.8 秒改變一次地鼠位置
    @State private var gameTimer: Timer?
    // 定時器：每 1 秒減少倒數時間
    @State private var countdownTimer: Timer?
    
    // 網格佈局：3x3
    let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 3)
    
    var body: some View {
        VStack(spacing: 30) {
            // 頂部資訊欄
            HStack {
                Text("得分: \(score)")
                    .font(.title)
                    .bold()
                Spacer()
                Text("時間: \(timeLeft)s")
                    .font(.title)
                    .bold()
                    .foregroundColor(timeLeft <= 5 ? .red : .primary)
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            
            Spacer()
            
            // 3x3 打地鼠遊戲盤
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(0..<9) { index in
                    ZStack {
                        // 地鼠洞（改成相容舊版的灰色與陰影）
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 90)
                            .shadow(radius: 3, x: 0, y: 3)
                        
                        // 地鼠本體
                        if molePosition == index {
                            Button(action: {
                                whackMole(at: index)
                            }) {
                                Text("🐹")
                                    .font(.system(size: 60))
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .frame(height: 100)
                }
            }
            .padding(20)
            .background(Color.gray.opacity(0.1)) // 改成相容舊版的背景色
            .cornerRadius(20)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // 控制按鈕
            if !isActive {
                Button(action: startGame) {
                    Text(timeLeft == 30 ? "開始遊戲" : "再玩一次")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .padding(.horizontal, 40)
                }
            } else {
                Text("點擊地鼠得分！")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .italic()
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - 遊戲邏輯函數
    
    /// 開始遊戲
    func startGame() {
        score = 0
        timeLeft = 30
        isActive = true
        nextMole()
        
        // 啟動地鼠隨機跳動計時器 (每 0.8 秒換位置)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            nextMole()
        }
        
        // 啟動倒數計時器 (每 1 秒減 1)
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeLeft > 0 {
                timeLeft -= 1
            } else {
                endGame()
            }
        }
    }
    
    /// 隨機決定下一個地鼠出現的位置
    func nextMole() {
        withAnimation(.easeOut(duration: 0.1)) {
            var newPosition = Int.random(in: 0..<9)
            // 避免地鼠連續出現在同一個洞
            while newPosition == molePosition {
                newPosition = Int.random(in: 0..<9)
            }
            molePosition = newPosition
        }
    }
    
    /// 玩家打到地鼠
    func whackMole(at index: Int) {
        guard isActive else { return }
        
        // 加分
        score += 10
        
        // 打中後地鼠立刻消失，並快速前往下一格
        molePosition = -1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.isActive {
                self.nextMole()
            }
        }
    }
    
    /// 結束遊戲
    func endGame() {
        isActive = false
        molePosition = -1
        gameTimer?.invalidate()
        countdownTimer?.invalidate()
        gameTimer = nil
        countdownTimer = nil
    }
}

#Preview {
    ContentView()
}

