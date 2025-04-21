RoundedRectangle(cornerRadius: 20)
                        .fill(Color.darkPurple)
                        .frame(width: 360, height: 80)
                    HStack {
                        ZStack {
                            Circle()
                                .stroke()
                                .fill(Color.gray)
                                .frame(height: 70)
                            
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.nude)
                        }
                    }