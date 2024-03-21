import SwiftUI

enum MessageAction {
	case resend(String, String)
	case delete(Message)
}

struct MessageView: View {
	@Dependency private var client: RocketChatClientProtocol
	
	@ObservedObject private var viewModel: MessageViewModel
	
	@State private var message: Message?
	
	private let action: (MessageAction) -> Void
	
	init(viewModel: MessageViewModel, action: @escaping (MessageAction) -> Void) {
		self.action = action
		self.viewModel = viewModel
	}
	
	@ViewBuilder
	private var unreadSeparator: some View {
		HStack(alignment: .center) {
			Text("Unread messages")
				.lineLimit(1)
				.font(.footnote)
				.foregroundStyle(.red)
				.layoutPriority(1)
			VStack(alignment: .center) {
				Divider()
					.overlay(.red)
			}
		}
	}
	
	@ViewBuilder
	private var dateSeparator: some View {
		HStack(alignment: .center) {
			VStack(alignment: .center) {
				Divider()
					.overlay(.secondary)
			}
			Text(viewModel.date ?? "")
				.lineLimit(1)
				.font(.footnote)
				.foregroundStyle(.secondary)
				.layoutPriority(1)
			VStack(alignment: .center) {
				Divider()
					.overlay(.secondary)
			}
		}
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			if viewModel.hasDateSeparator {
				dateSeparator
			} else if viewModel.hasUnreadSeparator {
				unreadSeparator
			}
			if viewModel.isHeader {
				HStack(alignment: .center) {
					Text(viewModel.sender ?? "")
						.lineLimit(1)
						.font(.caption.bold())
						.foregroundStyle(Color.default)
					Text(viewModel.time ?? "")
						.lineLimit(1)
						.font(.footnote)
						.foregroundStyle(.secondary)
					if viewModel.message.editedAt != nil {
						Image(systemName: "pencil")
							.font(.caption)
							.foregroundStyle(.secondary)
					}
				}
				.padding(.bottom, 4)
			}
			if let text = viewModel.info {
				(Text("\(viewModel.sender ?? "") ").font(.caption.bold().italic()) + Text(text).font(.caption.italic()))
					.foregroundStyle(Color.default)
			} else if let text = viewModel.message.msg {
				HStack(alignment: .top) {
					Text(text)
						.font(.caption)
						.foregroundStyle(viewModel.message.status == "temp" ? Color.secondaryInfo : Color.default)
					
					if viewModel.message.status == "error" {
						Button(
							action: {
								message = viewModel.message
							},
							label: {
								Image(systemName: "exclamationmark.circle")
									.font(.caption)
									.foregroundStyle(.red)
							}
						)
						.buttonStyle(PlainButtonStyle())
					}
					
					if viewModel.message.editedAt != nil && !viewModel.isHeader {
						Image(systemName: "pencil")
							.font(.caption)
							.foregroundStyle(.secondary)
					}
				}
			}
			if let attachments = viewModel.message.attachments?.allObjects as? Array<Attachment> {
				ForEach(attachments) { attachment in
					AttachmentView(attachment: attachment)
				}
			}
		}
		.padding(.top, 8)
		.sheet(item: $message) { message in
			MessageActionView(
				message: message,
				action: action
			)
		}
	}
}
